#!/bin/bash

# Einstellungen einlesen
if [ -f /boot/wachalarm_einstellungen.txt ]; then
    source /boot/wachalarm_einstellungen.txt
fi

echo "$screen_type";

if [[ $screen_type == *"m"* ]]; then
    echo "display off";
    sudo vcgencmd display_power 0 > /dev/null
elif [[ $screen_type == *"t"* ]]; then
    echo "hdmi off";
    echo 'standby 0' | cec-client -s > /dev/null
fi
