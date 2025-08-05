#!/bin/bash

export DISPLAY=:0.0

# Einstellungen einlesen

if [ -f /boot/firmware/wachalarm_einstellungen.txt ]; then
    source /boot/firmware/wachalarm_einstellungen.txt
fi

#Standby-Script ausfuehren
if [[ "$standby_enable" == *"1"* ]]; then
    echo "Stromsparmodus"
    xmessage -center -timeout 9 -font -adobe-*-*-r-*--100-100-*-*-p-*-*-* -bg orange -buttons x:1 -file /home/pi/xmessage_standby.txt
    sleep 1
    (cd /home/pi && npm run start --waipurl=$standby_waipurl --wachennr=$standby_wachennr &)
    exit 0
fi

if [ -n "${custom_standby_url}" ]; then
    echo "URL-Modus"
    xmessage -center -timeout 9 -font -adobe-*-*-r-*--100-100-*-*-p-*-*-* -bg white -buttons x:1 -file /home/pi/xmessage_url.txt
    sleep 1
    (cd /home/pi && npm run start --waipurl=$standby_waipurl --wachennr=$standby_wachennr --standbyurl=$custom_standby_url &)
    exit 0
fi

echo "kein Standby"
