# Wachalarm-Kiosk

Hier finden Sie ein einfach zu nutzendes SD-Karten-Image für einen **Raspberry Pi**, mit dem der Wachalarm (oder eine andere Webseite) direkt im Vollbild z.B. auf einem Monitor anzeigt werden kann. 

## Beispielfoto

![Wachalarm FF Elsterwerda](https://user-images.githubusercontent.com/19272095/89555705-ae166100-d810-11ea-99d6-089c08687a14.png)

## Funktionen

- **Startet unmittelbar im Vollbild** - Chromium Web-Browser mit allen wichtigen Funktionen
- **Automatatische Sicherheitsupdates** - wichtige Updates werden automatisch installiert, bei Bedarf erfolgt in der Nacht ein automatischer Neustart
- **Automatische Wiederherstellung** - bei Neustart oder Stromausfall startet das System im vorherigen Zustand eigenständig neu
- *Optional:* **Stromsparfunktion** - mittels HDMI-CEC kann der Monitor ausgeschaltet werden, sofern kein Einsatz anliegt
- **Maus wird ausgeblendet** - sofern eine Maus angeschlossen ist, wird diese nach inaktivität ausgeblendet

## Inbetriebnahme

1. Benötigt wird ein Raspberry Pi ([kompatible Hardware](#hardware)).
2. [Aktuelles Image](https://github.com/Robert-112/Wachalarm-Kiosk/releases) herunterladen.
3. Dateien entpacken.
4. Image auf eine SD-Karate schreiben. Hierzu kann unter Windows die Anwendung [Win32 Disk Imager](https://sourceforge.net/projects/win32diskimager/) genutzt werden.
5. [Webseite und weitere Optionen festlegen](#konfigurations-datei)
6. *optional*: automatische [WLAN-Verbindung](#wlan-setup) einstellen
7. *optional*: [feste IP-Adresse](#ip-adresse) hinterlegen
8. *optional*: [Passwort](#passwort-ändern) für den Benutzer `pi` ändern
9. SD-Karte in den Raspberry Pi einsetzen und starten.

## Einstellungen

### Konfigurations-Datei

1. SD-Karte in einen PC einlgen (z.B. per USB-Adapter).
2. Unter der Partition "Boot" der SD-Karte findet sich die Datei *[wachalarm_einstellungen.txt](https://github.com/Robert-112/Wachalarm-Kiosk/blob/custom/home/wachalarm_einstellungen.txt)*.
3. folgende Einstellungen können gesetzt werden:


#### Webseite beim Start
Webseite, die beim Start geöffnet werden soll, z.B. https://wachalarm.leitstelle-lausitz.de/waip/520101
```
startup_url=https://wachalarm.leitstelle-lausitz.de/waip/520101
```

#### Standby aktivieren
Automatisches Ausschalten des Bildschirms aktivieren, sofern kein Einsatz anliegt

1 == an, 0 == aus
```
standby_enable=1
```

#### Standby - Alarmmonitore-URL
*(gilt nur wenn Standby aktiv)*

URL zur auswahl der Alarmmonitore, z.B. https://wachalarm.leitstelle-lausitz.de/waip/ .

Die URL ist notwendig damit das Standby-Signal per Websocket korrekt ausgewertet werden kann.
(! dies ist nicht die URL des einzelnen Alarmmonitors !)
```
standby_waipurl=https://wachalarm.leitstelle-lausitz.de/waip
```

#### Standby - Wachennummer
*(gilt nur wenn Standby aktiv)*

Nummer der Wache, für die bei Alarmen der Monitor angeschaltet werden soll, z.B. 520101 für CB FW Cottbus
```
standby_wachennr=520101
```

#### System-Statusmeldungen aktivieren
Automatisches senden von Status-Meldungen des Systems aktivieren. 

Es handelt sich um allgemeine Systeminforamtionen wie z.B. Kernel-Version, Hardwaremerkmale & Udpatestatus. Personenbezogene Daten werden nicht ermittelt.

1 == an, 0 == aus
```
report_enable=1
```

#### System-Statusmeldungen - Status-URL
*(gilt nur wenn System-Statusmeldungen aktiv)*

URL an die Status-Meldungen durch das System gesendet werden.
```
report_url=https://wachalarm.leitstelle-lausitz.de/client_statusmessage
```

### WLAN Setup

#### Variante 1 - Datei wpa_supplicant.conf

WLAN-Verbindungen lassen Sich beim Raspberry über eine spezielle Datei vorgeben.

1. SD-Karte in PC einsetzen.
2. In der Boot-Partition eine Datei mit dem Namen `wpa_supplicant.conf` erstellen.
3. Eine fertige Vorlage findet sich hier: [wpa_supplicant.conf](https://github.com/Robert-112/Wachalarm-Kiosk/blob/custom/optional_boot_config/wpa_supplicant.conf) 
4. Ersetzen Sie `Name-des-WLANs` und `ganz-geheimes-kennwort` mit Ihren eigenen WLAN-Einstellungen.
5. Datei speichern und SD-Karte wieder in den Raspberry Pi einsetzen. Er sollte sich jetzt eigenständig mit dem WLAN verbinden.

#### Variante 2 - raspi-config

Alternativ lässt sich das WLAN auch direkt am Raspberry einrichten. 

1. Hierzu diesen starten und warten bis er vollständig hochgefahren ist (ggf. Monitor wieder einschalten, falls automatisch ausgeschaltet).
2. Mittels der Tastenkombination `STRG` + `ALT` + `F2` in die Konsole wechseln
3. Anmelden (Standardbenutzer: `pi`; Standardkennwort: `wachalarm` (beides kann bei Ihnen anders lauten))
4. Es öffnet sich eine blaue Oberfläche (lässt sich alternativ mit dem Befehl `sudo raspi-config` starten)
5. `1 System Options` öffnen
6. `S1 Wireless LAN` auswählen
7. SSID des WLANs eingeben
8. Kennwort des WLANs eingeben
9. im Anschluss mit `Finish` die Oberfläche verlassen
10. Raspberry Pi neustarten (Strom aus/ein, oder `sudo reboot`)

#### Beispiel wpa_supplicant.conf für WLAN _mit Kennwort_
```
country=DE
update_config=1
ctrl_interface=DIR=/var/run/wpa_supplicant GROUP=netdev
network={
  key_mgmt=WPA-PSK
  ssid="Name-des-WLANs"
  psk="ganz-geheimes-kennwort"
}
```

#### Beispiel wpa_supplicant.conf für WLAN _ohne Kennwort_
```
country=DE
update_config=1
ctrl_interface=DIR=/var/run/wpa_supplicant GROUP=netdev
network={
   ssid="Name-des-WLANs"
   key_mgmt=NONE
}
```

## Standardeinstellungen per Script anpassen

Mittels Anpassung der Datei `cmdline.txt` kann beim Start des Raspberry ein Script ausgeführt werden werden.
Über dieses Script können verschiedene Einstellungen individuell angepasst werden.

1. SD-Karte in PC einsetzen.
2. In der Boot-Partition die Datei `cmdline.txt` finden und mit einem Editor öffnen.
3. Am ende der ersten Zeile ein Leerzeichen und folgenden Text hinzufügen (keine neue Ziele):

```systemd.run=/boot/firstrun.sh systemd.run_success_action=reboot systemd.unit=kernel-command-line.target```

(eine bereits angepasste `cmdline.txt`-Dateien finden Sie hier: [optional_boot_config](https://github.com/Robert-112/Wachalarm-Kiosk/blob/custom/optional_boot_config))

Die Änderung der `cmdline.txt` führt dazu, dass beim nächsten Start das Script `/boot/firstrun.sh` einmalig ausgeführt wird. Nach Ausführung entfernt sich das Script selbstständig aus dem Ordner `/boot/` und auch die Anpassung der `cmdline.txt` wird wieder rückgängig gemacht. 

### IP-Adresse

Über das Script `firstrun.sh` lässt sich die Datei `/etc/dhcpcd.conf` so bearbeiten, dass die IP-Adresse für LAN und/oder WLAN fest hinterlegt werden.

Ein Beispiel in dem die Netzwerk-Adpater `eth0` und `wlan0` angepasst werden finden sie hier: [firstrun.sh](https://github.com/Robert-112/Wachalarm-Kiosk/blob/custom/optional_boot_config/firstrun.sh)

### Passwort ändern

Mit dem Script `firstrun.sh` lässt sich auch das Passwort des Benutzers `pi` ändern.
Dies erfolgt über nachfolgenden Aufruf:

```echo "pi:ganz_geheim" | sudo chpasswd```

Damit wird der Befehl `chpasswd` ausgeführt und für den Benutzer `pi` als neues Passwort `ganz_geheim` festgelegt.
Ein Beispiel finden sie hier: [firstrun.sh](https://github.com/Robert-112/Wachalarm-Kiosk/blob/custom/optional_boot_config/firstrun.sh)

## Hardware

Dieses Image sollte mit allen [Raspberry Pi's](https://www.raspberrypi.org/products/) funktionieren. Die Versionen 3 und 4 werden empfohlen, weil die kleinen Varianten zu wenig Leistung bieten. 3 und 4 haben zudem ein eingebautes WLAN-Modul.

Stellen Sie sicher, dass Sie eine [kompatible SD-Karte](http://elinux.org/RPi_SD_cards) verwenden (mind. 4 GB). `Class 10`-Karten sollten in jedem Fall funktionieren.

Ein Raspberry Pi benötigt ein [2.5 A USB-Netzteil](https://www.raspberrypi.org/documentation/hardware/raspberrypi/power/README.md). 

## Bekannte Fehler

### Kein Ton über HDMI (Raspberry Pi 4)
- stellen Sie sicher das sie das HDMI-Kabel am HDMI-Port 0 des Raspberrys angeschlossen haben (direkt neben dem USB-C-Stromanschluss)
- prüfen Sie ob der Monitor / Fernseher über den angeschlossenen HDMI-Port auch wirklich einen Ton ausgegeben kann
- prüfen Sie mittels `sudo raspi-config` ob HDMI als Audio-Ausgabequelle eingestellt wurde
- mit dem Befehlt `speaker-test` lässt sich die Sound-Ausgabe über die Konsole prüfen (Aufruf der Konsole muss am angeschlossenen Monitor erfolgen, nicht remote per SSH)

### ich benötige ein anderes Kennwort
- öffnen Sie die Eingabekonsole
- `sudo raspi-config`
- Navigieren Sie zu `Change User Password`
- geben Sie ein neues Passwort ein und bestätigen Sie es
- das eingegebene Kennwort gilt für den Benutzer `pi`

## Sonstiges

Dieses Projekt ist ein Fork von [chilipie-kiosk](https://github.com/jareware/chilipie-kiosk). Dort finden sich weitere Informationen und Antworten zu vielen Detailfragen.
