#!/bin/bash

if [ -f /boot/firmware/wachalarm_einstellungen.txt ]; then
    source /boot/firmware/wachalarm_einstellungen.txt
fi

#Standby-Script ausfuehren
if [[ "$report_enable" == *"1"* ]]; then
    xmldata=$(sudo lshw -xml)
    curl -H "Content-Type: application/xml" -H "Accept: application/xml" -d "$xmldata" -X POST $report_url
fi

