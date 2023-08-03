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

Die wichtigsten Einstellungen lassen sich ohne vorkenntnisse (von z.B. Linux) direkt mit einem normalen PC anpassen.

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
- m = Typ "Monitor", nutzt den Befehlssatz `vcgencmd display_power` um einen PC-Monitor ein- oder auszuschalten

```
screen_type=t
```

#### Standby - Websocket-URL
*(gilt nur wenn die Standby-Funktion aktiviert wurde)*

Dieser Wert sollte normalerweise nicht geändert werden. Es handelt sich um die URL des Wachalarm-Servers, über welche die Websocket-Befehle empfangen und verarbeitet werden. Nur mit dieser URL kann das Standby-Signal korrekt ausgewertet werden.


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

## Bekannte Fehler

### kein Ton über HDMI (Raspberry Pi 4)
- stellen Sie sicher das sie das HDMI-Kabel am HDMI-Port 0 des Raspberrys angeschlossen haben (direkt neben dem USB-C-Stromanschluss)
- prüfen Sie ob der Monitor / Fernseher über den angeschlossenen HDMI-Port auch wirklich einen Ton ausgegeben kann
- prüfen Sie mittels `sudo raspi-config` ob HDMI als Audio-Ausgabequelle eingestellt wurde

### ich benötige ein anderes Kennwort
- öffnen Sie die Eingabekonsole am Raspberry Pi
- `sudo raspi-config`
- Navigieren Sie zu `Change User Password`
- geben Sie ein neues Passwort ein und bestätigen Sie es
- das eingegebene Kennwort gilt für den Benutzer `pi`

### Monitor / Fernseher aus Standby erwecken

- Wenn die Standby-Funktion aktiviert wurde, schaltet sich der angeschlossene Monitor oder Fernseher aus, solange kein Alarm angezeigt wird
- Mit einer Tastutur kann der Monitor durch folgende Tastenkombinationen ein- und ausgeschaltet werden:
  - `STRG` + `i` -> schaltet den Monitor ein
  - `STRG` + `o` -> schaltet den Monitor aus

## Sonstiges

Dieses Projekt ist ein Fork von [chilipie-kiosk](https://github.com/jareware/chilipie-kiosk). Dort finden sich weitere Informationen und Antworten zu vielen Detailfragen.
