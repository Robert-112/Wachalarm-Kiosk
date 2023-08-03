#!/bin/bash

# Einstellungen einlesen
if [ -f /boot/wachalarm_einstellungen.txt ]; then
    source /boot/wachalarm_einstellungen.txt
fi

echo "$screen_type";

if [[ "$screen_type" == *"m"* ]]; then
    echo "display on";
    sudo vcgencmd display_power 1 > /dev/null
elif [[ "$screen_type" == *"t"* ]]; then 
    echo "hdmi on";
    echo 'on 0' | cec-client -s > /dev/null
fi

