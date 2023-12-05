#!/bin/bash

# Einstellungen einlesen
if [ -f /boot/firmware/wachalarm_einstellungen.txt ]; then
    source /boot/firmware/wachalarm_einstellungen.txt
fi

echo "$screen_type";

if [[ "$screen_type" == *"m"* ]]; then
    echo "display on";
    xrandr --output HDMI-1 --auto
    #veraltete Variante
    #sudo vcgencmd display_power 1 > /dev/null
elif [[ "$screen_type" == *"t"* ]]; then 
    echo "hdmi on";
    echo 'on 0' | cec-client -s > /dev/null
fi

