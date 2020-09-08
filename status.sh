#!/bin/bash
echo ">>> Running Services"
systemctl list-units --type=service --state=running

echo ">>> RAID"
cat /proc/mdstat

echo ">>> Failed Services"
systemctl list-units --state=failed

# Need to detect running services: TLP, bluetooth, printer, smartctl, sensors
