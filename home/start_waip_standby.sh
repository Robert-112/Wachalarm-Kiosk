#!/bin/bash

export DISPLAY=:0.0

# Einstellungen einlesen

if [ -f /boot/wachalarm_einstellungen.txt ]; then
    source /boot/wachalarm_einstellungen.txt
fi

#Standby-Script ausfuehren
if [[ "$standby_enable" == *"1"* ]]; then
    xmessage -center -timeout 9 -font -misc-*-*-r-*--100-100-*-*-c-*-*-* -bg orange -file ~/standby_message.txt
    sleep 1
    (cd /home/pi && npm run start --waipurl=$standby_waipurl --wachennr=$standby_wachennr &)
fi
