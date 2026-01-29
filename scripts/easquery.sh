#!/usr/bin/env bash
set -euo pipefail

# easquery.sh
# Usage:
#   ./easquery.sh example.com
#   ./easquery.sh --file domains.txt
#
# In --file mode, a per-domain report file is generated and a CSV summary is written.

usage() {
  cat <<EOF
Usage:
  $0 <domain>
  $0 --file <domains.txt>

Notes:
  - Input lines may be domains or URLs; blank lines and lines starting with # are ignored.
  - Produces <domain>_recon_<YYYYmmdd_HHMMSS>.txt for each domain.
  - In --file mode, also produces recon_summary_<YYYYmmdd_HHMMSS>.csv.
EOF
}

trim() {
  local s="${1:-}"
  printf '%s' "$s" | sed 's/^[[:space:]]*//; s/[[:space:]]*$//'
}

normalize_domain() {
  local s
  s="$(trim "${1:-}")"
  [[ -z "$s" ]] && return 0

  # Strip inline comments.
  s="${s%%#*}"
  s="$(trim "$s")"
  [[ -z "$s" ]] && return 0

  # Strip scheme/path if user pasted a URL.
  s="${s#http://}"
  s="${s#https://}"
  s="${s%%/*}"
  s="$(trim "$s")"
  [[ -z "$s" ]] && return 0

  printf '%s' "$s" | tr '[:upper:]' '[:lower:]'
}

csv_escape() {
  # Prints a CSV-safe field (quoted, with quotes doubled, newlines flattened)
  local s="${1-}"
  s="${s//$'\r'/}"
  # Replace embedded newlines with a delimiter to keep CSV rows single-line.
  s="$(printf '%s' "$s" | tr '\n' '\t')"
  s="${s//$'\t'/; }"
  s="${s//\"/\"\"}"
  printf '"%s"' "$s"
}

join_multiline() {
  # Join non-empty lines into a single '; '-separated string.
  local s="${1-}"
  local out=""
  local line
  while IFS= read -r line; do
    [[ -z "${line// }" ]] && continue
    if [[ -z "$out" ]]; then
      out="$line"
    else
      out+="; $line"
    fi
  done <<< "$s"
  printf '%s' "$out"
}

write_csv_header() {
  local csv="$1"
  printf '%s\n' 'domain,report_file,timestamp,cname_targets,ip_addresses,cloudflare_ns_delegated,nameservers,http_to_https_redirect_missing,http_redirect_details,tls_subject,tls_sans,tls_hostname_mismatch,open_tcp_ports_by_ip' > "$csv"
}

write_csv_row() {
  local csv="$1"
  shift
  local first=true
  {
    for field in "$@"; do
      if $first; then
        first=false
      else
        printf ','
      fi
      csv_escape "$field"
    done
    printf '\n'
  } >> "$csv"
}

need_cmd() {
  command -v "$1" >/dev/null 2>&1 || return 1
}

if ! need_cmd dig; then
  echo "ERROR: Required dependency not found: dig"
  echo "Install:"
  echo "  - macOS (Homebrew): brew install bind"
  echo "  - Ubuntu/Debian: sudo apt-get install dnsutils"
  exit 1
fi

dns_tool="dig"

# Prefer the real nmap binary (bypasses aliases/functions like `alias nmap='sudo ...'`).
nmap_bin="$(type -P nmap 2>/dev/null || true)"

section() {
  echo
  echo "-------------------- $1 --------------------"
}

safe_run() {
  # run a command and never fail the whole script
  echo "+ $*"
  "$@" || echo "(command failed: $*)"
}

dns_query() {
  # $1 = record type
  local rtype="$1"
  dig +nocmd "$domain" "$rtype" +noall +answer +comments
}

resolve_cnames() {
  # returns CNAME targets (one per line)
  dig +short "$domain" CNAME || true
}

resolve_ips() {
  # returns A and AAAA IPs (one per line)
  { dig +short "$domain" A; dig +short "$domain" AAAA; } | sed '/^$/d' || true
}

resolve_nameservers() {
  # returns NS targets (one per line)
  dig +short "$domain" NS \
    | sed 's/\.$//' \
    | tr '[:upper:]' '[:lower:]' \
    | sed '/^$/d' \
    || true
}

reverse_dns() {
  local ip="$1"
  dig +short -x "$ip" PTR || true
}

tls_name_matches() {
  # $1 = hostname, $2 = cert name (CN or SAN entry)
  # Supports exact match and leading-wildcard (*.example.com).
  local hostname="$1"
  local cert_name="$2"

  cert_name="$(printf '%s' "$cert_name" | sed 's/\.$//' | tr '[:upper:]' '[:lower:]')"
  hostname="$(printf '%s' "$hostname" | sed 's/\.$//' | tr '[:upper:]' '[:lower:]')"

  [[ -z "${cert_name// }" ]] && return 1
  [[ -z "${hostname// }" ]] && return 1

  if [[ "$cert_name" == "$hostname" ]]; then
    return 0
  fi

  if [[ "$cert_name" == "*."* ]]; then
    local suffix="${cert_name#*.}"
    [[ -z "${suffix// }" ]] && return 1
    if [[ "$hostname" == *".$suffix" ]] && [[ "$hostname" != "$suffix" ]]; then
      return 0
    fi
  fi

  return 1
}

scan_common_tcp_ports() {
  # $1 = host/ip
  # Uses nmap TCP connect scan on a common port list.
  local host="$1"
  local ports_csv="21,22,23,25,53,80,110,143,443,445,465,587,993,995,1433,1521,2049,3306,3389,5432,5900,6379,8080,8443,9200,27017"
  local -a nmap_args=( -Pn -n -sT --open -p "$ports_csv" )

  [[ -z "${nmap_bin// }" ]] && return 0

  if [[ "$host" == *:* ]]; then
    nmap_args=( -6 "${nmap_args[@]}" )
  fi

  # Grepable output is easier to parse across nmap versions.
  "$nmap_bin" "${nmap_args[@]}" "$host" -oG - 2>/dev/null \
    | awk -F'Ports: ' '/Ports:/{print $2}' \
    | tr ',' '\n' \
    | awk -F'/' '{gsub(/^[[:space:]]+|[[:space:]]+$/, "", $0); if ($2=="open" && $3=="tcp") print $1}' \
    | sed '/^$/d' \
    || true
}

recon_one() {
  local input_domain="$1"
  local summary_csv="${2:-}"

  domain="$(normalize_domain "$input_domain")"
  if [[ -z "${domain// }" ]]; then
    echo "Skipping empty/invalid domain line: $input_domain" >&2
    return 0
  fi

  ts="$(date +%Y%m%d_%H%M%S)"
  outfile="${domain}_recon_${ts}.txt"

  # Tee everything to console + file (scoped to this subshell via caller).
  exec > >(tee -a "$outfile") 2>&1

  echo "============================================================"
  echo "Recon report for: $domain"
  echo "Timestamp: $(date -Iseconds)"
  echo "Output file: $outfile"
  echo "============================================================"
  echo

  section "Tooling"
  echo "Using DNS tool: $dns_tool"
  for c in whois curl openssl; do
    if need_cmd "$c"; then
      echo "Found: $c"
    else
      echo "Missing: $c (some checks will be skipped)"
    fi
  done

  if [[ -n "${nmap_bin// }" ]]; then
    echo "Found: nmap (used for port scan)"
  else
    echo "Missing: nmap (port scan will be skipped)"
  fi

  section "DNS: CNAME / A / AAAA"
  safe_run dns_query CNAME
  safe_run dns_query A
  safe_run dns_query AAAA

  cnames="$(resolve_cnames | sed 's/\.$//' | uniq || true)"
  ips="$(resolve_ips | uniq || true)"
  nameservers="$(resolve_nameservers | uniq || true)"

  hosts_to_check=("$domain")
  if [[ "$domain" != www.* ]]; then
    hosts_to_check+=("www.$domain")
  fi

  cloudflare_delegated="no"
  if [[ -n "${nameservers// }" ]] && echo "$nameservers" | grep -Eq '\.ns\.cloudflare\.com$'; then
    cloudflare_delegated="yes"
  fi

  http_redirect_issues=""
  if need_cmd curl; then
    for host in "${hosts_to_check[@]}"; do
      effective_url="$(curl -sS -L --connect-timeout 5 --max-time 15 -o /dev/null -w '%{url_effective}' "http://$host" 2>/dev/null || true)"
      if [[ -n "${effective_url// }" ]] && [[ "$effective_url" != https://* ]]; then
        http_redirect_issues+=$'\n'
        http_redirect_issues+="http://$host -> $effective_url"
      fi
    done
  fi

  echo
  echo "CNAME targets:"
  if [[ -n "${cnames// }" ]]; then
    echo "$cnames"
  else
    echo "(none)"
  fi

  echo
  echo "Resolved IPs (A/AAAA):"
  if [[ -n "${ips// }" ]]; then
    echo "$ips"
  else
    echo "(none)"
  fi

  section "DNS: NS / SOA / MX / TXT"
  safe_run dns_query NS
  safe_run dns_query SOA
  safe_run dns_query MX
  safe_run dns_query TXT

  section "Reverse DNS (PTR) for resolved IPs"
  if [[ -n "${ips// }" ]]; then
    while IFS= read -r ip; do
      [[ -z "$ip" ]] && continue
      echo
      echo "IP: $ip"
      echo "PTR:"
      reverse_dns "$ip" | sed '/^$/d' || echo "(none)"
    done <<< "$ips"
  else
    echo "(no IPs to reverse)"
  fi

  section "Ports: common TCP (best-effort)"
  ports_summary=""
  if [[ -n "${ips// }" ]]; then
    if [[ -n "${nmap_bin// }" ]]; then
      while IFS= read -r ip; do
        [[ -z "$ip" ]] && continue
        echo
        echo "IP: $ip"
        echo "Open TCP ports (connect scan):"
        open_ports="$(scan_common_tcp_ports "$ip" 1 | tr '\n' ' ' | sed 's/[[:space:]]*$//')"
        if [[ -n "${open_ports// }" ]]; then
          echo "$open_ports"
        else
          echo "(none detected)"
        fi
        ports_summary+=$'\n'
        ports_summary+="$ip: ${open_ports:-none}"
      done <<< "$ips"
    else
      echo "(nmap required for port scan)"
    fi
  else
    echo "(no IPs to scan)"
  fi

  section "WHOIS: Domain"
  if need_cmd whois; then
    safe_run whois "$domain"
  else
    echo "(whois not installed)"
  fi

  section "HTTP(S) quick checks"
  if need_cmd curl; then
    # Try both bare domain and www, follow redirects, capture final URL and headers
    for host in "${hosts_to_check[@]}"; do
      echo
      echo "== Headers for https://$host =="
      safe_run curl -sS -I -L --max-time 15 "https://$host"

      echo
      echo "== Headers for http://$host =="
      safe_run curl -sS -I -L --max-time 15 "http://$host"
    done
  else
    echo "(curl not installed)"
  fi

  section "TLS certificate summary (SNI)"
  tls_subject_line=""
  tls_sans=""
  tls_domain_covered=""
  if need_cmd openssl; then
    # Pull cert from 443 and summarize issuer/subject/san/dates
    # Note: some hosts block/timeout; keep it short.
    echo "+ openssl s_client -connect $domain:443 -servername $domain"
    tls_x509="$(echo | openssl s_client -connect "$domain:443" -servername "$domain" -showcerts 2>/dev/null \
      | openssl x509 -noout -subject -issuer -dates -ext subjectAltName 2>/dev/null || true)"

    if [[ -n "${tls_x509// }" ]]; then
      printf '%s\n' "$tls_x509"

      tls_subject_line="$(printf '%s\n' "$tls_x509" | awk '/^subject=/{sub(/^subject=/, "", $0); print; exit}')"

      tls_sans="$(
        printf '%s\n' "$tls_x509" \
          | awk '
              /Subject Alternative Name/ {insans=1; next}
              insans && /^[[:space:]]/ {print; next}
              insans {exit}
            ' \
          | sed 's/^[[:space:]]*//' \
          | tr ',' '\n' \
          | sed -n 's/^[[:space:]]*DNS://p' \
          | sed 's/^[[:space:]]*//; s/[[:space:]]*$//' \
          | tr '[:upper:]' '[:lower:]' \
          | sed '/^$/d' \
          | sort -u || true
      )"

      tls_domain_covered="no"
      if tls_name_matches "$domain" "$(printf '%s\n' "$tls_subject_line" | sed -n 's/.*CN[[:space:]]*=[[:space:]]*\([^,/]*\).*/\1/p' | head -n 1)"; then
        tls_domain_covered="yes"
      elif [[ -n "${tls_sans// }" ]]; then
        while IFS= read -r san; do
          [[ -z "$san" ]] && continue
          if tls_name_matches "$domain" "$san"; then
            tls_domain_covered="yes"
            break
          fi
        done <<< "$tls_sans"
      fi
    else
      echo "(TLS check failed or no cert)"
    fi
  else
    echo "(openssl not installed)"
  fi

  section "Summary"
  echo "Domain: $domain"
  if [[ -n "${cnames// }" ]]; then
    echo "CNAME(s):"
    echo "$cnames" | sed 's/^/  - /'
  else
    echo "CNAME(s): (none)"
  fi
  if [[ -n "${ips// }" ]]; then
    echo "IP(s):"
    echo "$ips" | sed 's/^/  - /'
  else
    echo "IP(s): (none)"
  fi

  echo "Cloudflare NS delegation: $cloudflare_delegated"
  if [[ -n "${nameservers// }" ]]; then
    echo "Nameserver(s):"
    echo "$nameservers" | sed 's/^/  - /'
  fi

  if [[ -n "${http_redirect_issues// }" ]]; then
    echo "HTTP→HTTPS redirect missing:"
    echo "$http_redirect_issues" | sed '/^$/d' | sed 's/^/  - /'
  fi

  if [[ -n "${tls_subject_line// }" ]]; then
    echo "TLS subject: $tls_subject_line"
  fi
  if [[ -n "${tls_sans// }" ]]; then
    echo "TLS subjectAltName(s):"
    echo "$tls_sans" | sed 's/^/  - /'
  fi
  if [[ "$tls_domain_covered" == "no" ]] && [[ -n "${tls_subject_line// }${tls_sans// }" ]]; then
    echo "TLS hostname mismatch: $domain not in subject/SAN"
  fi

  if [[ -n "${ports_summary// }" ]]; then
    echo "Open TCP ports (by IP):"
    echo "$ports_summary" | sed '/^$/d' | sed 's/^/  - /'
  fi

  if [[ -n "${summary_csv// }" ]]; then
    http_missing="no"
    if [[ -n "${http_redirect_issues// }" ]]; then
      http_missing="yes"
    fi

    tls_mismatch="no"
    if [[ "$tls_domain_covered" == "no" ]] && [[ -n "${tls_subject_line// }${tls_sans// }" ]]; then
      tls_mismatch="yes"
    fi

    write_csv_row "$summary_csv" \
      "$domain" \
      "$outfile" \
      "$ts" \
      "$(join_multiline "$cnames")" \
      "$(join_multiline "$ips")" \
      "$cloudflare_delegated" \
      "$(join_multiline "$nameservers")" \
      "$http_missing" \
      "$(join_multiline "$http_redirect_issues")" \
      "$tls_subject_line" \
      "$(join_multiline "$tls_sans")" \
      "$tls_mismatch" \
      "$(join_multiline "$ports_summary")"
  fi

  echo
  echo "Done. Report saved to: $outfile"
}

domains_file=""
domain_arg=""
while [[ $# -gt 0 ]]; do
  case "$1" in
    -f|--file|--domains-file)
      domains_file="${2:-}"
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    --)
      shift
      break
      ;;
    -*)
      echo "Unknown option: $1" >&2
      usage >&2
      exit 1
      ;;
    *)
      domain_arg="$1"
      shift
      ;;
  esac
done

if [[ -n "${domains_file// }" ]]; then
  if [[ -n "${domain_arg// }" ]]; then
    echo "ERROR: Provide either a single domain OR --file, not both." >&2
    usage >&2
    exit 1
  fi
  if [[ ! -f "$domains_file" ]]; then
    echo "ERROR: Domains file not found: $domains_file" >&2
    exit 1
  fi

  batch_ts="$(date +%Y%m%d_%H%M%S)"
  summary_csv="recon_summary_${batch_ts}.csv"
  write_csv_header "$summary_csv"

  while IFS= read -r line || [[ -n "$line" ]]; do
    line="$(trim "$line")"
    [[ -z "$line" ]] && continue
    [[ "$line" == \#* ]] && continue
    ( recon_one "$line" "$summary_csv" ) || echo "(domain failed: $line)" >&2
  done < "$domains_file"

  echo
  echo "Batch summary CSV saved to: $summary_csv"
  exit 0
fi

if [[ -z "${domain_arg// }" ]]; then
  usage >&2
  exit 1
fi

( recon_one "$domain_arg" "" )
