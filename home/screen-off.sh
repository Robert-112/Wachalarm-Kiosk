#!/bin/bash

# Einstellungen einlesen
if [ -f /boot/wachalarm_einstellungen.txt ]; then
    source /boot/wachalarm_einstellungen.txt
fi

echo "$screen_type";

if [[ $screen_type == *"m"* ]]; then
    echo "display off";
    xrandr --output HDMI-1 --off
    xrandr --output HDMI-2 --off
    #veraltete Variante
    #sudo vcgencmd display_power 0 > /dev/null
elif [[ $screen_type == *"t"* ]]; then
    echo "hdmi off";
    echo 'standby 0' | cec-client -s > /dev/null
fi
