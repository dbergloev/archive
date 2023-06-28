#!/bin/bash
#
# Monitoring script that checks the current state of a disk/filesystem. 
# If any errors are found with a ZFS pool or from a previous SmartCTL scan, 
# the script will send an alert.
#
#
# This script works in combination with:
#
#   * smartctl@<timer>.sh
#   * zfs_scrub@<timer>.sh
#

timer="$1"

###
#
#
case $timer in
    startup|shutdown) exit 0 ;; # Unused
esac

###
#
#
declare -a devices

for pool in $(zpool list -H -o name); do
    if [[ "$(zpool list -H -o health $pool)" != "ONLINE" ]]; then
        echo "Critical : The zpool '$pool' needs your attention"
        /usr/bin/alert "critical" "ZFS Health Check" "The zpool '$pool' needs your attention"
        
    else
        for device in $(zpool status -PL $pool | grep -oe '/dev/.*$' | awk '{print $1}'); do
            device=$(blksrc $device)                                # Convert something like /dev/dm-1 -> /dev/sdb1
            device=/dev/$(lsblk -no pkname $device | tail -n 1)     # Convert something like /dev/sdb1 -> /dev/sdb
            
            if [[ -n "$device" && -b $device ]]; then
                if [[ ! " ${devices[*]} " =~ " $(basename $device) " ]]; then
                    if /usr/sbin/smartctl -i $device >/dev/null 2>&1; then
                        health="$(smartctl -H $device | tail -n 2)"
                    
                        if grep -q ' result:' <<< "$health" && ! grep -q 'PASSED' <<< "$health"; then
                            devices+=( $(basename $device) )
                            
                            echo "Critical : SmartCTL Health Check" "The device '$device' that belongs to zpool '$pool' is in danger"
                            /usr/bin/alert "critical" "SmartCTL Health Check" "The device '$device' that belongs to zpool '$pool' is in danger"
                        fi
                    fi
                fi
            fi
        done
    fi
done

