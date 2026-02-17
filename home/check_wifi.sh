#!/bin/bash

# Einstellungen einlesen
if [ -f /boot/firmware/wachalarm_einstellungen.txt ]; then
    source /boot/firmware/wachalarm_einstellungen.txt
fi

# Pr�ft ob der WLAN-Check aktiviert ist
# wenn aktiviert, wird das Gateway angepingt und bei Bedarf ein Neustart durchgef�hrt
if [[ "$check_wifi" == *"1"* ]]; then

  # Datei zum Speichern der Anzahl der fehlgeschlagenen Versuche
  FAIL_COUNT_FILE="/home/pi/gateway_fail_count.txt"

  # Ermitteln des Standard-Gateways (unabh�ngig vom Interface)
  GATEWAY=$(ip route | grep default | awk '{print $3}' | head -n 1)

  # Anzahl der maximal erlaubten fehlgeschlagenen Versuche
  MAX_FAILS=5

  # �berpr�fen, ob die Datei existiert, und den Z�hler initialisieren
  if [ ! -f "$FAIL_COUNT_FILE" ]; then
    echo 0 > "$FAIL_COUNT_FILE"
  fi

  # Aktuellen Z�hlerwert lesen
  FAIL_COUNT=$(cat "$FAIL_COUNT_FILE")

  # �berpr�fen, ob ein Gateway gefunden wurde und erreichbar ist
  if [[ -n "$GATEWAY" ]] && ping -c 1 "$GATEWAY" > /dev/null 2>&1; then
    # Gateway erreichbar, Z�hler zur�cksetzen
    FAIL_COUNT=0
  else
    # Kein Gateway gefunden oder nicht erreichbar, Z�hler erh�hen
    FAIL_COUNT=$((FAIL_COUNT + 1))
  fi

  # Z�hlerwert speichern
  echo "$FAIL_COUNT" > "$FAIL_COUNT_FILE"

  # �berpr�fen, ob die maximale Anzahl der fehlgeschlagenen Versuche erreicht wurde
  if [ "$FAIL_COUNT" -ge "$MAX_FAILS" ]; then
    # Fehlerz�hler zur�cksetzen
    echo 0 > "$FAIL_COUNT_FILE"
    # Neustart durchf�hren
    sudo reboot
  fi
fi
# nichts unternehmen, wenn WLAN-Check deaktiviert ist
