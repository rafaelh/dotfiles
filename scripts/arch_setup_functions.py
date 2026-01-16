"""Utility functions for Arch Linux setup scripts."""

import os
import shutil
import subprocess
import sys

# ==== Permissions =================================================================================

def file_requires_root(path) -> bool:
    """
    Returns True if a file requires root access to read or write, otherwise false.
    """

    read_access   = os.access(path, os.R_OK)
    write_access  = os.access(path, os.W_OK)
    requires_root = not read_access or not write_access

    return requires_root


def require_root() -> None:
    if os.geteuid() != 0:
        print("ℹ️ This operation requires elevated privileges. Re-launching with sudo...")
        try:
            subprocess.check_call(["sudo", sys.executable] + sys.argv)
        except subprocess.CalledProcessError:
            raise SystemExit("❌ Failed to obtain root privileges.")
        sys.exit() # exit original process

# ==== Package Management ==========================================================================

def check_for_missing_packages(packages: list) -> list:
    """
    Takes a list of Arch Linux package names and returns the ones
    that are NOT currently installed.
    """
    not_installed = []

    for package in packages:
        try:
            # pacman -Q exits 0 if installed, non-zero if not
            subprocess.run(
                ["yay", "-Q", package],
                stdout=subprocess.DEVNULL,
                stderr=subprocess.DEVNULL,
                check=True
            )
        except subprocess.CalledProcessError:
            not_installed.append(package)

    return not_installed


def install_packages(packages: list) -> bool:
    """
    Accepts a list of Arch Linux packages and installs the ones that are not already installed.
    Raises a RuntimeError if any package cannot be installed.
    """
    if not packages:
        print(f"📭 No packages provided to install.")
        return True
    else:
        print(f"📦 Installing packages: {packages}")
    result = subprocess.run(
        ["sudo", "yay", "-S", "--noconfirm"] + packages,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        text=True,
        check=False
    )

    if result.returncode != 0:
        raise RuntimeError(
            f"❌ Failure during installation of {packages}: {result.stderr.strip()}"
        )

    return True


# ==== Systemd Services ============================================================================

def is_service_running(service_name):
    """
    Returns True if the given systemd service is running, otherwise returns False.
    """
    try:
        result = subprocess.run(
            ["sudo", "systemctl", "is-active", service_name],
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            text=True,
            check=False
        )

        return result.stdout.strip() == "active"
    except Exception:
        return False


def activate_service(service_name):
    """
    Starts and enables a systemd service, and returns True on success. Raises RuntimeError if the
    service cannot be started, but not if the service is already started or enabled.
    """
    print(f"⚙️ Activating service: {service_name}")
    result = subprocess.run(
        ["sudo", "systemctl", "enable", "--now", service_name],
        stdout=subprocess.DEVNULL,
        stderr=subprocess.DEVNULL,
        text=True,
        check=False
    )

    # If start failed, systemctl prints an error and returns non-zero
    if result.returncode != 0:
        # If it's already running, don't treat as an error
        status = subprocess.run(
            ["systemctl", "is-active", service_name],
            stdout=subprocess.PIPE,
            text=True
        ).stdout.strip()

        if status != "active":
            raise RuntimeError(
                f"❌ Failed to start service '{service_name}': {result.stderr.strip()}"
            )

    return True


# ==== Config File Management ======================================================================

def update_INI_config(filepath, section, key, new_value, add_if_missing=True) -> bool:
    """
    Updates a key/value inside a given section of an INI config file. If the key or section does
    not exist and add_if_missing=True, it will be added. Success or failure is returned as a
    boolean.

    Example:
        update_config_entry("settings.conf",
                            "KDE",
                            "doubleclickonsingle",
                            "True")

    In this example, settings.conf is reviewed, and if doubleclickonsingle exists in the [KDE]
    section, it updates it. If [KDE] exists, but the key does not, it is added to that section, and
    if [KDE] doesn't exist, both the section and key are added.
    """
    if file_requires_root(filepath):
        require_root()

    try:
        with open(filepath, encoding="utf-8") as f:
            lines = f.readlines()
    except FileNotFoundError:
        raise RuntimeError(f"❌ File not found: {filepath}")

    section_header = f"[{section}]"
    key_prefix = f"{key} ="

    in_section = False
    section_found = False
    key_updated = False
    new_lines = []

    for line in lines:
        stripped = line.strip()

        # Detect section
        if stripped.startswith("[") and stripped.endswith("]"):
            in_section = (stripped == section_header)
            if in_section:
                section_found = True

        # Update key if inside the correct section
        if in_section and stripped.startswith(key_prefix):
            new_lines.append(f"{key} = {new_value}\n")
            key_updated = True
            continue

        new_lines.append(line)

    # If the section exists but the key didn't, append key
    if section_found and not key_updated and add_if_missing:
        new_lines.append(f"{key} = {new_value}\n")

    # If the section doesn't exist at all
    if not section_found and add_if_missing:
        new_lines.append("\n")
        new_lines.append(section_header + "\n")
        new_lines.append(f"{key} = {new_value}\n")

    # Write back
    with open(filepath, "w", encoding="utf-8") as f:
        f.writelines(new_lines)

    return True


def set_config_line(filepath, new_line, search_string=None) -> bool:
    """
    Replace or append a config line, logging only if a real change occurs.
    """

    if file_requires_root(filepath):
        require_root()

    search = search_string if search_string is not None else new_line
    desired = new_line.rstrip() + "\n"

    try:
        with open(filepath, encoding="utf-8") as f:
            original_lines = f.readlines()
    except FileNotFoundError:
        raise RuntimeError(f"❌ File not found: {filepath}")

    new_lines = []
    found = False
    changed = False

    for line in original_lines:
        if search in line:
            if not found:
                found = True
                if line != desired:     # Only change if content differs
                    new_lines.append(desired)
                    changed = True
                else:
                    new_lines.append(line)
            else:
                # drop duplicates (this is a change)
                changed = True
        else:
            new_lines.append(line)

    if not found:
        if new_lines and not new_lines[-1].endswith("\n"):
            new_lines[-1] += "\n"
        new_lines.append(desired)
        changed = True

    # Only write & log if something really changed
    if changed:
        with open(filepath, "w", encoding="utf-8") as f:
            f.writelines(new_lines)
        print(f"🔧 Updated {filepath}: {new_line}")

    return True


# ==== General Functions ===========================================================================

def run_command(command: list) -> str:
    """
    Runs a shell command and returns its stdout as a string.
    Raises RuntimeError if the command fails.
    """
    result = subprocess.run(
        command,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        text=True,
        check=False
    )

    if result.returncode != 0:
        raise RuntimeError(
            f"❌ Command '{' '.join(command)}' failed: {result.stderr.strip()}"
        )

    return (result.stdout.strip())


def get_hardware_details() -> dict:
    """
    Returns a dict mapping each top-level line of `inxi -F` output to its value.
    If inxi is not installed, an empty dict is returned.
    """
    inxi_path = shutil.which("inxi")
    if not inxi_path:
        return {}

    result = subprocess.run(
        [inxi_path, "-F"],
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        text=True,
        check=False,
    )

    if result.returncode != 0:
        raise RuntimeError(f"❌ Failed to run inxi: {result.stderr.strip()}")

    summary = {}
    for raw_line in result.stdout.splitlines():
        line = raw_line.strip()
        if not line or ":" not in line:
            continue
        key, value = line.split(":", 1)
        summary[key.strip()] = value.strip()

    return summary
