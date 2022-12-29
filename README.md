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
6. [Webseite und weitere Optionen festlegen](#konfigurations-datei)
7. *Optional*: automatische [WLAN-Verbindung](#wlan-setup) einstellen
8. *Optional*: [feste IP-Adresse](#ip-adresse) hinterlegen
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

WLAN-Verbindungen lassen Sich beim Raspberry über eine spezielle Datei vorgeben.

1. SD-Karte in PC einsetzen.
2. In der Boot-Partition eine Datei mit dem Namen `wpa_supplicant.conf` erstellen.
3. Eine fertige Vorlage findet sich hier: [wpa_supplicant.conf](https://github.com/Robert-112/Wachalarm-Kiosk/blob/custom/optional_boot_config/wpa_supplicant.conf) 
4. Ersetzen Sie `Name-des-WLANs` und `ganz-geheimes-kennwort` mit Ihren eigenen WLAN-Einstellungen.
5. Datei speichern und SD-Karte wieder in den Raspberry Pi einsetzen. Er sollte sich jetzt eigenständig mit dem WLAN verbinden.

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

### IP-Adresse

Mittels der Datei `cmdline.txt` kann direkt eine feste IP-Adresse für den Raspberry vorgegeben werden.

1. SD-Karte in PC einsetzen.
2. In der Boot-Partition die Datei `cmdline.txt` finden und mit einem Editor öffnen.
3. Am ende der ersten Zeile folgenden Text hinzufügen (keine neue Ziele):

```ip=192.168.2.20::192.168.2.1:255.255.255.0:wachalarm:eth0:off:192.168.2.1```

Damit wird die IP-Adresse für die Schnittstelle `eth0` auf 192.168.2.20 festlegt. Einstellungen für das Gateway (`192.168.2.1`), das Subnetz (`255.255.255.0`), den Hostnamen (`wachalarm`) und den DNS-Server (`192.168.2.1`) werden ebenfalls definiert.

Bereits angepasste `cmdline.txt`-Dateien finden Sie hier: [optional_boot_config](https://github.com/Robert-112/Wachalarm-Kiosk/blob/custom/optional_boot_config) 

## Hardware

Dieses Image sollte mit allen [Raspberry Pi's](https://www.raspberrypi.org/products/) funktionieren. Die Versionen 3 und 4 werden empfohlen, weil die kleinen Varianten zu wenig Leistung bieten. 3 und 4 haben zudem ein eingebautes WLAN-Modul.

Stellen Sie sicher, dass Sie eine [kompatible SD-Karte](http://elinux.org/RPi_SD_cards) verwenden (mind. 4 GB). `Class 10`-Karten sollten in jedem Fall funktionieren.

Ein Raspberry Pi benötigt ein [2.5 A USB-Netzteil](https://www.raspberrypi.org/documentation/hardware/raspberrypi/power/README.md). 

## Bekannte Fehler

### Kein Ton über HDMI Raspberry Pi 4
- stellen Sie sicher das sie das HDMI-Kabel am HDMI-Port 0 des Raspberrys angeschlossen (direkt neben dem USB-C-Stromanschluss)
- stellen Sie sicher das der Monitor / Fernseher über den angeschlossenen HDMI-Port auch wirklich einen Ton ausgegeben kann
- prüfen Sie mittels `sudo raspi-config` ob HDMI als Audio-Ausgabequelle eingestellt wurde

### ich benötige ein anderes Kennwort ein meiner Umgebung
- öffnen Sie die Eingabekonsole
- `sudo raspi-config`
- Navigieren Sie zu `Change User Password`
- geben Sie ein neues Passwort ein und bestätigen Sie es

## Sonstiges

Dieses Projekt ist ein Fork von [chilipie-kiosk](https://github.com/jareware/chilipie-kiosk). Dort finden sich weitere Informationen und Antworten zu vielen Detailfragen.
