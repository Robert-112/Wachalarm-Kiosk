#!/bin/bash

export DISPLAY=:0.0

day=$(date +%u)

param=$1
message="xmessage -center -timeout 9 -font -adobe-*-*-r-*--100-100-*-*-p-*-*-* -bg orange -buttons x:1 -file /home/pi/xmessage_reboot.txt"

if [[ "$param" == *"now"* ]]; then
    $message
    sleep 1
    sudo reboot;
fi


# Einstellungen einlesen
if [ -f /boot/wachalarm_einstellungen.txt ]; then
    source /boot/wachalarm_einstellungen.txt
fi

#Reboot jeden Tag
if [[ "$restart_type" == *"t"* ]]; then
    $message
    sleep 1
    sudo reboot;
#Reboot falls heute Montag ist
elif [[ "$restart_type" == *"w"* ]]; then
    if [[ "$day" == *"1"* ]]; then
        $message
        sleep 1
	    sudo reboot;
    fi	
#Reboot falls heute Dienstag oder Freitag ist    
elif [[ "$restart_type" == *"z"* ]]; then
    if [[ "$day" == *"2"* ]] || [[ "$day" == *"5"* ]]; then
        $message
        sleep 1
        sudo reboot;
    fi
#kein Reboot
elif [[ "$restart_type" == *"0"* ]]; then
    # nichts unternehmen
    :
fi
