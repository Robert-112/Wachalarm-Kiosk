#!/bin/bash

# Einstellungen einlesen
if [ -f /boot/firmware/wachalarm_einstellungen.txt ]; then
    source /boot/firmware/wachalarm_einstellungen.txt
fi

# Prüft ob der WLAN-Check aktiviert ist
# wenn aktiviert, wird das Gateway angepingt und bei Bedarf ein Neustart durchgeführt
if [[ "$check_wifi" == *"1"* ]]; then
  
  # Datei zum Speichern der Anzahl der fehlgeschlagenen Versuche
  FAIL_COUNT_FILE="/home/pi/gateway_fail_count.txt"

  # WLAN-Interface (ändern Sie dies entsprechend Ihrer Konfiguration)
  WLAN_INTERFACE="wlan0"

  # Ermitteln des aktuellen Gateways
  GATEWAY=$(ip route | grep default | grep "$WLAN_INTERFACE" | awk '{print $3}')

  # Anzahl der maximal erlaubten fehlgeschlagenen Versuche
  MAX_FAILS=5

  # Überprüfen, ob die Datei existiert, und den Zähler initialisieren
  if [ ! -f "$FAIL_COUNT_FILE" ]; then
    echo 0 > "$FAIL_COUNT_FILE"
  fi

  # Aktuellen Zählerwert lesen
  FAIL_COUNT=$(cat "$FAIL_COUNT_FILE")

  # Überprüfen, ob das Gateway eine gültige IP-Adresse ist und dann anpingen
  if [[ $GATEWAY =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    ping -c 1 "$GATEWAY" > /dev/null 2>&1

    if [ $? -ne 0 ]; then
      # Ping fehlgeschlagen, Zähler erhöhen
      FAIL_COUNT=$((FAIL_COUNT + 1))
    else
      # Ping erfolgreich, Zähler zurücksetzen
      FAIL_COUNT=0
    fi

    # Zählerwert speichern
    echo "$FAIL_COUNT" > "$FAIL_COUNT_FILE"

    # Überprüfen, ob die maximale Anzahl der fehlgeschlagenen Versuche erreicht wurde
    if [ "$FAIL_COUNT" -ge "$MAX_FAILS" ]; then
      # Fehlerzähler zurücksetzen
      echo 0 > "$FAIL_COUNT_FILE"
      # Neustart durchführen
      sudo reboot
    fi
  fi  
fi
# nichts unternehmen, wenn WLAN-Check deaktiviert ist
