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

1. After flashing remount your SD card.
2. Create a `wpa_supplicant.conf` in your SD cards boot folder
3. Copy the [sample wpa_supplicant.conf](#sample-wpasupplicantconf) file into the boot folder on the SD card.
4. Replace `WiFi-SSID` and `WiFi-PASSWORD` with your WiFi configuration.
5. Optional: Set the country code to your country code e.g. `DE`.

#### Sample wpa_supplicant.conf
```
ctrl_interface=DIR=/var/run/wpa_supplicant GROUP=netdev
update_config=1
country=US

network={
  ssid="WiFi-SSID"
  psk="WiFi-PASSWORD"
  key_mgmt=WPA-PSK
}
```

## Hardware

Works with [all Raspberry Pi versions](https://www.raspberrypi.org/products/). Versions 3 and 4 are recommended, though, since the smaller ones can be a bit underpowered for rendering complex dashboards. The 3 and 4 also come with built-in WiFi, which is convenient (though both [official](https://www.raspberrypi.org/products/raspberry-pi-usb-wifi-dongle/) and [off-the-shelf](https://elinux.org/RPi_USB_Wi-Fi_Adapters) USB WiFi dongles can work equally well).

Make sure you have a [compatible 4+ GB SD card](http://elinux.org/RPi_SD_cards). In general, any Class 10 card will work, as they're fast enough and of high enough quality.

The Pi needs a [2.5 Amp power source](https://www.raspberrypi.org/documentation/hardware/raspberrypi/power/README.md). Most modern USB chargers you'll have laying around will work, but an older/cheaper one may not.

## Common issues

- **I get a kernel panic on boot, or the image keeps crashing.** The Raspberry Pi is somewhat picky about about its SD cards. It's also possible the SD card has a bad sector in a critical place, and `dd` wasn't be able to tell you. Double-check that you're using [a blessed SD card](http://elinux.org/RPi_SD_cards), and try flashing the image again.
- **I see a "rainbow square" or "yellow lightning" in the top right corner of the screen, and the device seems unstable.** This usually means the Pi isn't getting enough amps from your power supply. This is sometimes the case in more exotic setups (e.g. using the USB port of your display to power the Pi) or with cheap power supplies. Try another one.
- **The [display control scripts](home/display-on.sh) don't turn off the display device.** Normal PC displays will usually power down when you cut off the signal, but this is not the case for many TV's. Please check if your TV has an option in its settings for enabling this, as some do. If not, you can [try your luck with HDMI CEC signals](http://raspberrypi.stackexchange.com/questions/9142/commands-for-using-cec-client), but the TV implementations of the spec are notoriously spotty.
- **The MicroSD card isn't flashing correctly, I don't see the boot partition.** This commonly happens on Windows computers and can be fixed by extracting the `chilipie*.img` file from the `tar.gz`. You will need to use an extraction tool that supports both gzip and tar archive formats, such as 7zip. Extract the contents of the `img.tar.gz` file, then extract the contents of the resulting `img.tar` file again. You should be left with an `.img` file, which you can then use with Etcher to flash your SD card.

## Sonstiges

Dieses Projekt ist ein Fork von [chilipie-kiosk](https://github.com/jareware/chilipie-kiosk). Dort finden sich weitere Informationen und Antworten zu vielen Detailfragen.
