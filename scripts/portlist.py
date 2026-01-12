#!/usr/bin/env python3
"""port_lookup.py

Quickly translate **ports ⇄ services** using a YAML database.

Usage examples (no flags required):

    $ ./port_lookup.py 22 443            # Look up port numbers
    $ ./port_lookup.py ssh smtp           # Search by service keywords (substring)
    $ PORTMAP_FILE=my_ports.yml ./port_lookup.py 3306 mysql

Each positional token is interpreted as follows:
  • **Digits only** → treated as a port number. Valid range: 0‑65535.
    Out‑of‑range values trigger an informative error.
  • **Anything else** → treated as a service keyword (case‑insensitive
    substring search against the port description).

The port database is loaded from a YAML file.  By default it is
``ports.yaml`` in the same directory as this script, but you can override
it with the ``PORTMAP_FILE`` environment variable.
"""

from __future__ import annotations

import os
import sys
from pathlib import Path
from typing import Dict, List

try:
    import yaml  # PyYAML
except ImportError as exc:  # pragma: no cover
    sys.exit(f"PyYAML is required. Install with:  pip install pyyaml\n{exc}")

# ---------------------------------------------------------------------------
# YAML database handling
# ---------------------------------------------------------------------------

def default_db_path() -> Path:
    """Return the default path to the YAML database (./ports.yaml)."""
    return Path(__file__).with_name("ports.yaml")


def load_portlist(path: os.PathLike) -> dict[str, str]:
    """Return a mapping of *str(port)* → *description* loaded from *path*."""
    try:
        with open(path, encoding="utf-8") as fp:
            data = yaml.safe_load(fp)
    except FileNotFoundError:
        sys.exit(f"Port database not found: {path}")
    except yaml.YAMLError as exc:
        sys.exit(f"Failed to parse YAML file {path}: {exc}")

    if not isinstance(data, dict):
        sys.exit("YAML file must contain a mapping of port→description.")

    # Coerce keys to *strings* to simplify look‑ups
    return {str(k): str(v) for k, v in data.items()}

# ---------------------------------------------------------------------------
# Lookup helpers
# ---------------------------------------------------------------------------

def lookup_ports(ports: list[int], portlist: dict[str, str]) -> None:
    """Print the description for each *port* in *ports*."""
    for port in ports:
        desc = portlist.get(str(port))
        if desc:
            print(f"Port {port}: {desc}")
        else:
            print(f"No entry for port {port}")


def search_services(terms: list[str], portlist: dict[str, str]) -> None:
    """Search *portlist* for *terms* (case‑insensitive substring match)."""
    lowered = {p: d.lower() for p, d in portlist.items()}

    for term in terms:
        term_lc = term.lower()
        matches = [p for p, desc in lowered.items() if term_lc in desc]

        if matches:
            for p in matches:
                print(f"Service '{term}' found on port {p}: {portlist[p]}")
        else:
            print(f"No port found for service '{term}'")

# ---------------------------------------------------------------------------
# Main argument handling (flag‑free)
# ---------------------------------------------------------------------------

def parse_arguments(argv: list[str]) -> tuple[list[int], list[str]]:
    """Separate *argv* tokens into (ports, service_terms)."""
    ports: list[int] = []
    services: list[str] = []

    if not argv:
        print(__doc__)
        sys.exit(0)

    for token in argv:
        if token.isdigit():
            # Numeric: treat as port number & validate range
            port = int(token)
            if 0 <= port <= 65535:
                ports.append(port)
            else:
                print(f"Error: {port} is outside valid port range 0‑65535", file=sys.stderr)
        else:
            services.append(token)

    return ports, services

# ---------------------------------------------------------------------------
# Entry‑point
# ---------------------------------------------------------------------------

def main() -> None:
    # Determine YAML database path (env var beats default)
    db_path = Path(os.environ.get("PORTMAP_FILE", default_db_path()))
    portlist = load_portlist(db_path)

    ports, services = parse_arguments(sys.argv[1:])

    if ports:
        lookup_ports(ports, portlist)
    if services:
        search_services(services, portlist)


if __name__ == "__main__":
    main()
