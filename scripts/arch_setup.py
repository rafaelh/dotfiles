"""
Script to set up archlinux, with functions to be split out into a library eventually.

TODO:
- check for the installation of sudo, and yay or pacman
- set default package manager on import of module
- update functions to allow passing preferred package manager
"""

import os
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


# ==== INI Config File Management ==================================================================

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

    for i, line in enumerate(lines):
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


if __name__ == "__main__":

    # Bluetooth setup
    bluetooth_packages = ["bluez",
                          "bluez-utils",
                          "bluez-qt",
                          "bluez-utils-cups", # Required for printing over bluetooth
                         ]
    check_for_missing_packages(bluetooth_packages)
    install_packages(check_for_missing_packages(bluetooth_packages))

    # Example usage
    # missing = check_for_missing_packages(["git", "neofetch", "nonexistent-package"])
    # print("Missing packages:", missing)

    # try:
    #     install_packages(missing)
    #     print("Packages installed successfully.")
    # except RuntimeError as e:
    #     print(e)

    # service = "ssh"
    # if not is_service_running(service):
    #     try:
    #         activate_service(service)
    #         print(f"Service '{service}' activated successfully.")
    #     except RuntimeError as e:
    #         print(e)
    # else:
    #     print(f"Service '{service}' is already running.")

    # config_file = "/etc/example.conf"
    # try:
    #     update_INI_config(config_file, "ExampleSection", "ExampleKey", "NewValue")
    #     print(f"Config file '{config_file}' updated successfully.")
    # except RuntimeError as e:
    #     print(e)
