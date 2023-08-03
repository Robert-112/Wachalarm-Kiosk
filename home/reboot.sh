#!/bin/bash

day=$(date +%u)

# Einstellungen einlesen
if [ -f /boot/wachalarm_einstellungen.txt ]; then
    source /boot/wachalarm_einstellungen.txt
fi

#Reboot jeden Tag
if [[ "$restart_type" == *"t"* ]]; then
    sudo reboot;
#Reboot falls heute Montag ist
elif [[ "$restart_type" == *"w"* ]]; then
    if [[ "$day" == *"1"* ]]; then
	sudo reboot;
    fi	
#Reboot falls heute Dienstag oder Freitag ist    
elif [[ "$restart_type" == *"z"* ]]; then
    if [[ "$day" == *"2"* ]] || [[ "$day" == *"5"* ]]; then
        sudo reboot;
    fi
#kein Reboot
elif [[ "$restart_type" == *"0"* ]]; then
    # nichts unternehmen
fi
