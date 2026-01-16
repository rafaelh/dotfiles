"""
Script to set up archlinux, with functions to be split out into a library eventually.

TODO:
- check for the installation of sudo, and yay or pacman
- set default package manager on import of module
- update functions to allow passing preferred package manager
"""

import argparse
import json

import arch_setup_functions as setup_utils

# ==== Main Script =================================================================================

def setup() -> None:
    setup_utils.require_root()

    # Bluetooth setup
    print("🔵 Checking Bluetooth")
    bluetooth_packages = ["bluez",
                          "bluez-utils",
                          "bluez-qt",
                          "bluez-cups", # Required for printing over bluetooth
                         ]
    setup_utils.install_packages(setup_utils.check_for_missing_packages(bluetooth_packages))

    print("🔵 Checking Reflector Service")
    if not setup_utils.is_service_running("reflector.timer"):
        setup_utils.activate_service("reflector.timer")
    print("🔵 Checking Thunderbolt")
    thunderbolt_packages = ["bolt",
                            "plasma-thunderbolt",
                           ]
    setup_utils.install_packages(setup_utils.check_for_missing_packages(thunderbolt_packages))

    print("🔵 Checking Power & Thermals")
    power_thermal_packages = ["lm_sensors",
                             "power-profiles-daemon",
                             "thermald",
                            ]
    setup_utils.install_packages(setup_utils.check_for_missing_packages(power_thermal_packages))

    setup_utils.run_command(["sensors-detect", "--auto"])
    for package in power_thermal_packages:
        if setup_utils.is_service_running(f"{package}.service"):
            setup_utils.activate_service(f"{package}.service")

    print("🔵 Checking Utilities")
    utility_packages = ["fwupd",
                        "ethtool",
                        ]
    setup_utils.install_packages(setup_utils.check_for_missing_packages(utility_packages))


    print("🔵 Checking NVMe SSD Tools")
    nvme_packages = ["nvme-cli", "smartmontools", "util-linux"]
    setup_utils.install_packages(setup_utils.check_for_missing_packages(nvme_packages))

    for package in nvme_packages:
        if not setup_utils.is_service_running("smartd.service"):
            setup_utils.activate_service("smartd.service")
        if not setup_utils.is_service_running("fstrim.timer"):
            setup_utils.activate_service("fstrim.timer")

    print("🔵 Checking Wireless Regulatory Database")
    wifi_packages = ["wireless-regdb"]
    setup_utils.install_packages(setup_utils.check_for_missing_packages(wifi_packages))

    setup_utils.set_config_line(
        "/etc/conf.d/wireless-regdom",
        '#WIRELESS_REGDOM="AU"',
        'WIRELESS_REGDOM="AU"')

    print("🔵 Checking Console Font")
    setup_utils.install_packages(setup_utils.check_for_missing_packages(["terminus-font"]))
    setup_utils.set_config_line("/etc/vconsole.conf", new_line="KEYMAP=us")
    setup_utils.set_config_line("/etc/vconsole.conf", new_line="FONT=ter-v20n")

    # GPD win specific setup
    # install iio-sensor-proxy for automatic screen rotation
    # Optionally install gpd-win-kbd for keyboard backlight control
    # if os.path.exists("/sys/bus/iio/devices/iio:device0/in_accel_x_raw"):
    #     print("🔵 Detected GPD Win device - installing specific packages")


    #     gpd_packages = ["iio-sensor-proxy",
    #                     #"gpd-win-kbd", # Uncomment to install keyboard backlight control
    #                    ]
    #     setup_utils.check_for_missing_packages(gpd_packages)
    #     setup_utils.install_packages(setup_utils.check_for_missing_packages(gpd_packages))

    """
    fwupdmgr get-devices # show supported devices
    fwupdmgr refresh     # download the latest metadata
    fwupdmgr get-updates # list available updates
    fwupdmgr update      # apply updates
    """

    # ==== Example Usage ===========================================================================

    # Example usage
    # missing = setup_utils.check_for_missing_packages(["git", "neofetch", "nonexistent-package"])
    # print("Missing packages:", missing)

    # try:
    #     setup_utils.install_packages(missing)
    #     print("Packages installed successfully.")
    # except RuntimeError as e:
    #     print(e)

    # service = "ssh"
    # if not setup_utils.is_service_running(service):
    #     try:
    #         setup_utils.activate_service(service)
    #         print(f"Service '{service}' activated successfully.")
    #     except RuntimeError as e:
    #         print(e)
    # else:
    #     print(f"Service '{service}' is already running.")

    # config_file = "/etc/example.conf"
    # try:
    #     setup_utils.update_INI_config(config_file, "ExampleSection", "ExampleKey", "NewValue")
    #     print(f"Config file '{config_file}' updated successfully.")
    # except RuntimeError as e:
    #     print(e)


def print_hardware_details() -> None:
    """
    Print hardware details gathered from inxi, if available.
    """
    try:
        details = setup_utils.get_hardware_details()
    except RuntimeError as e:
        print(e)
        return

    if not details:
        print("ℹ️ inxi is not installed; skipping hardware detail output.")
        return

    if isinstance(details, dict):
        # Pretty-print dict for readability
        print(json.dumps(details, indent=2, sort_keys=True))
    else:
        print(details)


def main():
    parser = argparse.ArgumentParser(description="Arch Linux setup helper.")
    parser.add_argument(
        "--hardware",
        action="store_true",
        help="Print hardware details (requires inxi).",
    )
    parser.add_argument(
        "--setup",
        action="store_true",
        help="Run the Arch Linux setup.",
    )

    args = parser.parse_args()

    if args.hardware:
        print_hardware_details()
    if args.setup:
        setup()
    if not args.hardware and not args.setup:
        parser.print_help()


if __name__ == "__main__":
    main()
