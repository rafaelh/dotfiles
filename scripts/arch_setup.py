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

from pygtkcompat import enable

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
    if packages:
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
    Runs a shell command and returns a tuple of (stdout, stderr).
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


# ==== Main Script =================================================================================
if __name__ == "__main__":

    require_root()

    # Bluetooth setup
    print("🔵 Checking Bluetooth")
    bluetooth_packages = ["bluez",
                          "bluez-utils",
                          "bluez-qt",
                          "bluez-cups", # Required for printing over bluetooth
                         ]
    install_packages(check_for_missing_packages(bluetooth_packages))

    print("🔵 Checking Reflector Service")
    if not is_service_running("reflector.timer"):
        activate_service("reflector.timer")

    print("🔵 Checking Thunderbolt")
    thunderbolt_packages = ["bolt",
                            "plasma-thunderbolt",
                           ]
    install_packages(check_for_missing_packages(thunderbolt_packages))

    print("🔵 Checking Power & Thermals")
    power_thermal_packages = ["lm_sensors",
                             "power-profiles-daemon",
                             "thermald",
                            ]
    install_packages(check_for_missing_packages(power_thermal_packages))

    run_command(["sensors-detect", "--auto"])
    for package in power_thermal_packages:
        if is_service_running(f"{package}.service"):
            activate_service(f"{package}.service")


    print("🔵 Checking Utilities")
    utility_packages = ["fwupd",
                        "ethtool",
                        ]
    install_packages(check_for_missing_packages(utility_packages))


    print("🔵 Checking NVMe SSD Tools")
    nvme_packages = ["nvme-cli", "smartmontools", "util-linux"]
    install_packages(check_for_missing_packages(nvme_packages))

    for package in nvme_packages:
        if not is_service_running("smartd.service"):
            activate_service("smartd.service")
        if not is_service_running("fstrim.timer"):
            activate_service("fstrim.timer")

    print("🔵 Checking Wireless Regulatory Database")
    wifi_packages = ["wireless-regdb"]
    install_packages(check_for_missing_packages(wifi_packages))

    set_config_line(
        "/etc/conf.d/wireless-regdom",
        '#WIRELESS_REGDOM="AU"',
        'WIRELESS_REGDOM="AU"')

    print("🔵 Checking Console Font")
    install_packages(check_for_missing_packages(["terminus-font"]))
    set_config_line("/etc/vconsole.conf", new_line="KEYMAP=us")
    set_config_line("/etc/vconsole.conf", new_line="FONT=ter-v20n")


    # GPD win specific setup
    # install iio-sensor-proxy for automatic screen rotation
    # Optionally install gpd-win-kbd for keyboard backlight control
    # if os.path.exists("/sys/bus/iio/devices/iio:device0/in_accel_x_raw"):
    #     print("🔵 Detected GPD Win device - installing specific packages")


    #     gpd_packages = ["iio-sensor-proxy",
    #                     #"gpd-win-kbd", # Uncomment to install keyboard backlight control
    #                    ]
    #     check_for_missing_packages(gpd_packages)
    #     install_packages(check_for_missing_packages(gpd_packages))

    """
    fwupdmgr get-devices # show supported devices
    fwupdmgr refresh     # download the latest metadata
    fwupdmgr get-updates # list available updates
    fwupdmgr update      # apply updates
    """

    # ==== Example Usage ===========================================================================

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
