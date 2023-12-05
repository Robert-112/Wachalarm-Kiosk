# Wachalarm-Kiosk

Hier finden Sie ein einfach zu nutzendes SD-Karten-Image für einen **Raspberry Pi**, mit dem der Wachalarm (oder eine andere Webseite) direkt im Vollbild z.B. auf einem Monitor anzeigt werden kann. 

## Beispielfoto

![Wachalarm FF Elsterwerda](https://user-images.githubusercontent.com/19272095/89555705-ae166100-d810-11ea-99d6-089c08687a14.png)

## Funktionen

- **Startet unmittelbar im Vollbild** - Chromium Web-Browser mit allen wichtigen Funktionen
- **Automatatische Sicherheitsupdates** - wichtige Updates werden automatisch installiert, bei Bedarf erfolgt in der Nacht ein automatischer Neustart
- **Automatische Wiederherstellung** - bei Neustart oder Stromausfall startet das System im vorherigen Zustand eigenständig neu
- *Optional:* **Stromsparfunktion** - liegt kein Alarm an, kann der Monitor ausgeschaltet werden
- **Maus wird ausgeblendet** - sofern eine Maus angeschlossen ist, wird diese nach inaktivität ausgeblendet

---

## Inbetriebnahme

> **Hinweis**
>
> Benötigt wird ein Raspberry Pi ([kompatible Hardware](#hardware)).

1. Laden Sie das [aktuelle Image](https://github.com/Robert-112/Wachalarm-Kiosk/releases) aus dem Release-Bereich herunter.
2. Entpacken Sie die komprimierte Datei auf Ihrem Computer (z.B. dem Programm [7Zip](https://7-zip.de/index.html)).
3. Schreiben Sie das Image mit Hilfe eines SD-Karten-Lesegeräts auf eine SD-Karte. Hierzu kann unter Windows die Anwendung [Win32 Disk Imager](https://sourceforge.net/projects/win32diskimager/) genutzt werden.
4. Legen Sie die anzuzeigende [Webseite und die weitere Optionen fest](#konfigurations-datei).
5. *Optional*: Legen Sie fest, ob der Raspberry Pi sich automatisch mit einem [WLAN verbinden](#wlan-setup) soll.
6. *Optional*: Setzen Sie eine [feste IP-Adresse](#ip-adresse) für das System.
7. Setzen Sie die SD-Karte in den Raspberry Pi. Verbinden Sie Ihn mit dem Monitor und dem Internet (Netzwerkkabel oder WLAN). Starten Sie das Gerät.

---

## Einstellungen

### Konfigurations-Datei

Die wichtigsten Einstellungen lassen sich ohne Vorkenntnisse (von z.B. Linux) direkt mit einem normalen PC anpassen.

Benötigt wird ein SD-Karten-Lesegerät und ein Text-Editor. 

1. Schließen Sie die zuvor mit dem Image beschriebene SD-Karte an ihren PC an (z.B. per USB-Adapter).
2. Im Datei-Explorer sollte jetzt ein neues Laufwerk erscheinen. In der Partition "Boot" der SD-Karte findet sich die Datei *[wachalarm_einstellungen.txt](https://github.com/Robert-112/Wachalarm-Kiosk/blob/custom/home/wachalarm_einstellungen.txt)*.
3. folgende Einstellungen können gesetzt werden:


#### Webseite beim Start

Legt fest, welche Webseite beim Start geöffnet werden soll. Wollen Sie den Wachalarm für die Feuerwehr Cottbus anzeigen wäre dies z.B. die Adresse https://wachalarm.leitstelle-lausitz.de/waip/520101

```
startup_url=https://wachalarm.leitstelle-lausitz.de/waip/520101
```

#### Standby - Funktion ein-/ausschalten

Legt fest ob der Bildschirm automatisch ausgeschaltet werden soll, wenn kein Einsatz anliegt.

Es gibt folgende Optionen:
- 1 = aktiviert diese Funktion (Monitor geht aus sobald kein Alarm mehr angzeigt wird)
- 0 = deaktivert diese Funktion (Monitor bleibt immer an)

```
standby_enable=1
```

#### Standby - Art des Monitors festlegen
*(gilt nur wenn die Standby-Funktion aktiviert wurde)*

Legt fest, was für ein Monitor verwendet wird. Je nach Typ (PC-Monitor oder Fernseher mit HDMI-CEC), sind unterschiedliche Befehle notwendig um den Monitor ein- oder auszuschalten.

Es gibt folgende Optionen:
- t = Typ "TV", nutzt [CEC-Befehle](https://de.wikipedia.org/wiki/Consumer_Electronics_Control) um den Fernseher ein- oder auszuschalten
- m = Typ "Monitor", nutzt den Befehlssatz `xrandr --output HDMI-*` um einen PC-Monitor ein- oder auszuschalten

```
screen_type=t
```

> Achtung!
>
> Wird ein PC-Monitor verwendet, kann es zu Problemen bei der Sound-Ausgabe kommen. Lösungsansätze finden Sie im Abschnitt ["Bekannte Fehler"](#kein-ton-über-hdmi-raspberry-pi-4)

#### Standby - Websocket-URL
*(gilt nur wenn die Standby-Funktion aktiviert wurde)*

Dieser Wert sollte normalerweise nicht geändert werden. Es handelt sich um die URL des Wachalarm-Servers, über welche Websocket-Befehle empfangen und verarbeitet werden. Nur mit dieser URL kann das Standby-Signal korrekt ausgewertet werden.


```
standby_waipurl=https://wachalarm.leitstelle-lausitz.de/waip
```

> **Achtung!**
>
> Es handelt sich hierbei nicht die URL des einzelnen Alarmmonitors!

#### Standby - Wachennummer
*(gilt nur wenn die Standby-Funktion aktiviert wurde)*

Nummer der Wache, für die bei Alarmen der Monitor angeschaltet werden soll, z.B. 520101 für CB FW Cottbus

```
standby_wachennr=520101
```

> **Achtung!**
>
> Hier sollte im Normalfall immer die gleiche Nummer des aufgerufenen Alarmmonitors hinterlegt werden (siehe Parameter `startup_url`).

#### System-Statusmeldungen aktivieren

Hiermit kann ein automatisches Senden von Status-Meldungen aktiviert werden. 

Es handelt sich um allgemeine Systeminforamtionen wie z.B. Kernel-Version, Hardwaremerkmale & Udpatestatus. Personenbezogene Daten werden nicht verarbeitet.

- 1 = an
- 0 = aus

```
report_enable=1
```

#### System-Statusmeldungen - Status-URL
*(gilt nur wenn System-Statusmeldungen aktiviert wurden)*

URL an welche Status-Meldungen durch das System gesendet werden.

```
report_url=https://wachalarm.leitstelle-lausitz.de/client_statusmessage
```

#### automatische Neustarts

Legt fest, ob und wenn ja wann, ein automatischer Neustart des Raspberry Pi erfolgen soll. Diese Funktion ist hilfreich um z.B. bei schlechten WLAN-Verbindungen das System automatisch neuzustarten.

Es gibt folgende Optionen:
- 0 = automatischer Neustart ist deaktiviert.
- w = Neustart jeden Montag um 3:00 Uhr.
- z = Neustart jeden Dienstag und jeden Freitag um 3:00 Uhr.
- t = Neustart jeden Tag um 3:00 Uhr.

```
restart_type=w
```

---

### WLAN einstellen

WLAN-Verbindungen lassen Sich beim Raspberry über eine spezielle Datei vorgeben, ohne weitere Einstellungen am System zu tätigen. Gehen Sie wie folgt vor, um WLAN zu aktivieren:

1. Schließen Sie die zuvor mit dem Image beschriebene SD-Karte an ihren PC an (z.B. per USB-Adapter).
2. Im Datei-Explorer sollte jetzt ein neues Laufwerk erscheinen. In der Partition "Boot" der SD-Karte erstellen Sie eine Datei mit dem Namen `wpa_supplicant.conf`.
3. Eine fertige Vorlage findet sich hier: [wpa_supplicant.conf](https://github.com/Robert-112/Wachalarm-Kiosk/blob/custom/optional_boot_config/wpa_supplicant.conf) 
4. Ersetzen Sie `Name-des-WLANs` und `ganz-geheimes-kennwort` mit Ihren eigenen WLAN-Einstellungen.
5. Speichern Sie die Datei auf der SD-Karte und setzen Sie diese wieder in den Raspberry Pi ein. Nach Abschluss des Startvorgangs sollte sich das Gerät eigenständig mit dem WLAN verbinden.

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

---

### IP-Adresse vorgeben

Mittels der Datei `cmdline.txt` kann direkt eine feste IP-Adresse für den Raspberry Pi vorgegeben werden.

1. SD-Karte in PC einsetzen.
2. In der Boot-Partition die Datei `cmdline.txt` finden und mit einem Editor öffnen.
3. Am ende der ersten Zeile folgenden Text hinzufügen (keine neue Ziele):

```ip=192.168.2.20::192.168.2.1:255.255.255.0:wachalarm:eth0:off:192.168.2.1```

Damit wird die IP-Adresse für die Schnittstelle `eth0` auf 192.168.2.20 festlegt. Einstellungen für das Gateway (`192.168.2.1`), das Subnetz (`255.255.255.0`), den Hostnamen (`wachalarm`) und den DNS-Server (`192.168.2.1`) werden ebenfalls definiert.

Bereits angepasste `cmdline.txt`-Dateien finden Sie hier: [optional_boot_config](https://github.com/Robert-112/Wachalarm-Kiosk/blob/custom/optional_boot_config) 

---

## Hardware

Dieses Image sollte mit allen bekannten [Raspberry Pi's](https://www.raspberrypi.org/products/) funktionieren. Die Versionen 3 und 4 werden empfohlen, da die älteren Varianten zu wenig Leistung bieten. Raspberry 3 und 4 haben zudem ein eingebautes WLAN-Modul.

Stellen Sie sicher, dass Sie eine [kompatible SD-Karte](http://elinux.org/RPi_SD_cards) verwenden (mind. 4 GB). `Class 10`-Karten sollten in jedem Fall funktionieren.

Ein Raspberry Pi benötigt ein [2.5 A USB-Netzteil](https://www.raspberrypi.org/documentation/hardware/raspberrypi/power/README.md). 

---

## Tastenkombinationen

Wenn Sie eine Tastatur (z.B. per USB) angeschlossen haben, stehen folgende Tastenkombination zur Verfügung:
- `STRG` + `i` -> schaltet den Monitor ein (I)
- `STRG` + `o` -> schaltet den Monitor aus (O)
- `STRG` + `ALT` + `r` -> startet den Raspberry Pi neu (`reboot`)
- `STRG` + `ALT` + `F1` -> wechselt zum Webbrowser (Standardansicht ohne Login)
- `STRG` + `ALT` + `F2` -> wechselt zum Konfigutaions-Programm des Raspberry pi (Login notwendig, startet `sudo raspi-config`) 
- `STRG` + `ALT` + `F3` -> wechselt zur Konsole (Login notwendig, Eingabekonsole für Wartung)

---

## Bekannte Fehler

### kein Ton über HDMI (Raspberry Pi 4)
- stellen Sie sicher das sie das HDMI-Kabel am HDMI-Port 0 des Raspberrys angeschlossen haben (direkt neben dem USB-C-Stromanschluss)
- prüfen Sie ob der Monitor / Fernseher über den angeschlossenen HDMI-Port auch wirklich einen Ton ausgegeben kann
- wechseln Sie mit der [Tastenkombination](#tastenkombinationen) `STRG` + `ALT` + `F3` (Login notwendig) in die Wartungskonsole und prüfen Sie mit dem Befehl `speaker-test` ob ein Test-Ton ausgegeben wird

#### Lösungsvariante 1 - Audio-Quelle bei HDMI-Fernseher festlegen
- wechseln Sie mit der [Tastenkombination](#tastenkombinationen) `STRG` + `ALT` + `F2` (Login notwendig) in die Konfigurationsoberfläche des Raspberrys und prüfen Sie ob HDMI-0 als Audio-Ausgabequelle eingestellt wurde
- verlassen Sie die Konfigurationsoberfläche und starten Sie den Raspberry neu (`sudo reboot`)

#### Lösungsvariante 2 - Audio-Quelle bei PC-Monitor mit integrierten Lautsprechern
- wechseln Sie mit der [Tastenkombination](#tastenkombinationen) `STRG` + `ALT` + `F3` (Login notwendig) in die Wartungskonsole
- führen Sie den Befehl `sudo nano /boot/firmware/config.txt` aus umd die Konfigurationsdatei des Raspberrys zu bearbeiten
- aktivieren Sie den Parameter `dtparam=audio=on` indem Sie das `#` davor entfernen
- deaktivieren Sie den Parameter `dtoverlay=vc4-kms-v3d` indem Sie ein `#` davor setzen
- speichern Sie die Datei (`STRG` + `x` und mit `ja` bestätigen) und starten Sie den Raspberry neu (`sudo reboot`)
- öffnen Sie nach dem Neustart erneut die Wartungskonsole (`STRG` + `ALT` + `F3`) und prüfen Sie mit dem Befehl `speaker-test` ob ein Test-Ton ausgegeben wird
- prüfen Sie alternativ noch, welche Audio-Quelle in den Systemeinstellungen gesetzt wurde (siehe [Lösungsvariante 1](#lösungsvariante-1---audio-quelle-bei-hdmi-fernseher-festlegen))

### ich benötige ein anderes Kennwort
- wechseln Sie mit der [Tastenkombination](#tastenkombinationen) `STRG` + `ALT` + `F2` (Login notwendig) in die Konfigurationsoberfläche des Raspberrys
- Navigieren Sie zu `Change User Password`
- geben Sie ein neues Passwort ein und bestätigen Sie es
- das eingegebene Kennwort gilt für den Benutzer `pi`

### Monitor geht nicht in Standby
- stellen Sie sicher das sie das HDMI-Kabel am HDMI-Port 0 des Raspberrys angeschlossen haben (direkt neben dem USB-C-Stromanschluss)
- prüfen Sie ob in den [Standby-Einstellungen zur Art des Monitors](#standby---art-des-monitors-festlegen) der richtige Monitor-Typ hinterlegt wurde (`m` für PC-Monitor, `t` für TV-Gerät)
  - mit den [Tastenkombination](#tastenkombinationen) `STRG` + `I` bzw. `STRG` + `O` kann geprüft werden, ob die Standby-Funktion generell funktioniert
- prüfen Sie ob in den [Standby-Einstellungen zur Wachennummer](#standby---wachennummer) die richtige Wachennummer hinterlegt wurde

### Monitor / Fernseher aus Standby erwecken
- wenn die Standby-Funktion aktiviert wurde, schaltet sich der angeschlossene Monitor oder Fernseher aus, solange kein Alarm angezeigt wird
- mit der beschriebenen [Tastenkombination](#tastenkombinationen) `STRG` + `i` können Sie den Monitor wieder einschalten

---

## Sonstiges

### Image-Erstellung
Mit dem Skript `image-setup.sh` kann eigenständig ein aktuelles Image für den Raspberry Pi erstellt werden. Benötigt wird ein PC mit aktuellem Linux (z.B. Ubuntu, oder zweiter Raspberry Pi).

Das Skript selbst liefert alle notwendigen Informationen. 

Der Linux-PC auf dem das Skript ausgeführt wird (`chmod +x image-setup.sh` und dann `./image-setup.sh`) und der Raspberry Pi welcher konfiguriert werden soll, müssen sich im Netzwerk erreichen können.

### Fork
Dieses Projekt ist ein Fork von [chilipie-kiosk](https://github.com/jareware/chilipie-kiosk). Dort finden sich weitere Informationen und Antworten zu vielen Detailfragen.

