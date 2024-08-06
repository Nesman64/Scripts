#!/bin/bash
# This script will unmount every partition it can find, excluding partitions on the smallest drive.
# This script is meant to be used on a bootable Linux usb drive to keep the OS from mounting a drive while it's being cloned.

# Get a list of all available storage devices and sort them by size
devices=$(lsblk -d -n -o NAME,SIZE |grep -v loop| sort -k 2 -hr)

# Unmount all partitions on every device except the smallest one
smallest_device=$(echo "$devices" | tail -n 1 | awk '{print $1}')

for device in $(echo "$devices" | awk '{print $1}' | grep -v "$smallest_device" ); do
    echo "Unmounting partitions on $device"
done

while true; do
for device in $(echo "$devices" | awk '{print $1}' | grep -v "$smallest_device" ); do

    umount /dev/${device}* 2>/dev/null
done
done
