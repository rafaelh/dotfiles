#!/bin/bash
echo "\n>>> Running Services\n"
systemctl list-units --type=service --state=running

echo "\n>>> RAID\n"
cat /proc/mdstat

echo "\n>>> Failed Services\n"
systemctl list-units --state=failed


# Need to detect running services: TLP, bluetooth, printer, smartctl, sensors
