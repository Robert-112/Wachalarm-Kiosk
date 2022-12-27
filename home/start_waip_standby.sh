#!/bin/bash

export DISPLAY=:0.0

# Einstellungen einlesen

if [ -f /boot/wachalarm_einstellungen.txt ]; then
    source /boot/wachalarm_einstellungen.txt
fi

#Standby-Script ausfuehren
if [[ "$standby_enable" == *"1"* ]]; then
    xmessage -center -timeout 9 "ACHTUNG: Monitor geht gleich in Standby, sofern kein Einsatz anliegt."
    sleep 1
    (cd /home/pi && npm run start --waipurl=$standby_waipurl --wachennr=$standby_wachennr &)
fi
