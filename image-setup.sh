#!/bin/bash

# Original: https://github.com/jareware/chilipie-kiosk/blob/master/docs/image-setup.sh
# Anpassung: Robert Richter, 12/2022

# exit on error; treat unset variables as errors; exit on errors in piped commands
set -euo pipefail

# Ensure we operate from consistent pwd for the rest of the script
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )" # Figure out the ABSOLUTE PATH of this script without relying on the realpath command, which may not always be available
cd "$DIR"

SSH_CONNECT_TIMEOUT=30

# Funktionen fuer das Skript
function echo-bold {
  echo -e "$(tput -Txterm-256color bold)$1$(tput -Txterm-256color sgr 0)" # https://unix.stackexchange.com/a/269085; the -T arg accounts for $ENV not being set
}
function working {
  echo-bold "\n[WORKING] $1"
}
function question {
  echo-bold "\n[QUESTION] $1"
}
function ssh {
  /usr/bin/ssh -o LogLevel=ERROR -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o ConnectTimeout="$SSH_CONNECT_TIMEOUT" "pi@$IP" "$1"
}

question "Skript zum erstellen eines aktuellen Raspberry-Images fuer einen Wachalarm-Monitor"
echo "Benoetigt:"
echo "* einen Raspberry Pi oder Linux-Debian-System auf dem dieses Skript ausgefuehrt wird"
echo "* einen weiteren Raspberry Pi mit SD-Karte und Internet-Zugriff (selbes Netzwerk)"
echo ""

question "Vorbereiten der SD-Karte"
echo "* Nutzen Sie die Software \"Raspberry Pi Imager\" z.B. unter Windows"
echo "* waehlen Sie das aktuelle Betriebssystem \"Raspberry Pi OS Lite\" fuer die SD-Karte"
echo "* setzen Sie vor dem Beschreiben der SD-Karte folgende Einstellungen:"
echo "*** hostname (z.B. \"wachalarm.local\""
echo "*** SSH aktivieren, Passwort zur Authentifizierung verwendung"
echo "*** Benutzer und Kennwort festlegen (z.B. \"pi\" / \"wachalarm\")"
echo "*** Zeitzone auf Berlin festlegen"
echo "* SD-Karte schreiben"
echo "* nach Fertigstellung die SD-Karte unter diesem Linux-System einbinden und mounten:"
echo "*** z.B. mit: sudo mount /dev/sda1 /media/sdkarte"
echo "* Pfad der eingbunden SD-Karte merken (z.B. \"/media/sdkarte\")"
echo "(Bereit? dann weiter mit ENTER)"
read

question "Mount-Verzeichnis der SD-Karte"
echo "geben Sie den Pfad zur SD-Karte an (z.B. \"/media/sdkarte\")"
read mount_path

# Variablen
MOUNTED_BOOT_VOLUME="$mount_path"
BOOT_CMDLINE_TXT="$MOUNTED_BOOT_VOLUME/cmdline.txt"
BOOT_CONFIG_TXT="$MOUNTED_BOOT_VOLUME/config.txt"

#LOCALE="en_US.UTF-8 UTF-8" # or e.g. "fi_FI.UTF-8 UTF-8" for Finland
LOCALE="de_DE.UTF-8 UTF-8"
#LANGUAGE="en_US.UTF-8" # should match above
LANGUAGE="de_DE.UTF-8"
#KEYBOARD="us" # or e.g. "fi" for Finnish
KEYBOARD="de"
#TIMEZONE="Etc/UTC" # or e.g. "Europe/Helsinki"; see https://en.wikipedia.org/wiki/List_of_tz_database_time_zones
TIMEZONE="Europe/Berlin"

working "Backup der Original Boot-Dateien erstellen"
cp -v "$BOOT_CMDLINE_TXT" "$BOOT_CMDLINE_TXT.backup"
cp -v "$BOOT_CONFIG_TXT" "$BOOT_CONFIG_TXT.backup"

working "Wachalarm-Einstellungsdatei hinterlegen"
cp -v "home/wachalarm_einstellungen.txt" "$MOUNTED_BOOT_VOLUME/wachalarm_einstellungen.txt"

working "Automatische Expansion der root-Partition deaktivieren"
echo "Updating: $BOOT_CMDLINE_TXT"
cat "$BOOT_CMDLINE_TXT" | sed "s#init=/usr/lib/raspi-config/init_resize.sh##" > temp
mv temp "$BOOT_CMDLINE_TXT"

working "SSH aktivieren"
# https://www.raspberrypi.org/documentation/remote-access/ssh/
touch "$MOUNTED_BOOT_VOLUME/ssh"

working "Making boot quieter (part 1)" # https://scribles.net/customizing-boot-up-screen-on-raspberry-pi/
echo "Updating: $BOOT_CONFIG_TXT"
perl -i -p0e "s/#disable_overscan=1/disable_overscan=1/g" "$BOOT_CONFIG_TXT" # "perl" is more cross-platform than "sed -i"
echo -e "\ndisable_splash=1" >> "$BOOT_CONFIG_TXT"

#2023-08 dtparam=audio=on aktiviert lassen 
#working "Sound auf HDMI aktiveren (klappt nicht immer)"
#perl -i -p0e "s/dtparam=audio=on/#dtparam=audio=on/g" "$BOOT_CONFIG_TXT"

#working "Making boot quieter (part 2)" # https://scribles.net/customizing-boot-up-screen-on-raspberry-pi/
#echo "You may want to revert these changes if you ever need to debug the startup process"
#echo "Updating: $BOOT_CMDLINE_TXT"
#cat "$BOOT_CMDLINE_TXT" \
#  | sed 's/console=tty1/console=tty3/' \
#  | sed 's/$/ splash plymouth.ignore-serial-consoles logo.nologo vt.global_cursor_default=0/' \
#  > temp
#mv temp "$BOOT_CMDLINE_TXT"

working "SD-Karte wird ausgeworfen"
sudo umount "$mount_path"


question "Raspberry Pi starten:"
echo "* SD-Karte auswerfen & in Pi einsetzen (ggf. zuvor \"umount /media/sdkarte\""
echo "* Raspberry Pi mit Netzwerk verbinden"
echo "* Pi booten / starten"
echo "* es folgen viele Password-Abfragen fuer den SSH-Zugriff auf den Raspberry"
echo "IP-Adresse eingeben:"
read IP

#working "Setting locale"
# We want to do this as early as possible, so perl et al won't complain about misconfigured locales for the rest of the image prep
ssh "echo $LOCALE | sudo tee /etc/locale.gen"
ssh "sudo locale-gen"
ssh "echo -e \"LANGUAGE=$LANGUAGE\nLC_ALL=$LANGUAGE\" | sudo tee /etc/environment"

#working "hostname festlegen"
# We want to do this right before reboot, so we don't get a lot of unnecessary complaints about "sudo: unable to resolve host chilipie-kiosk" (https://askubuntu.com/a/59517)
ssh "sudo hostnamectl set-hostname wachalarm"
ssh "sudo perl -i -p0e 's/raspberrypi/wachalarm/g' /etc/hosts" # "perl" is more cross-platform than "sed -i"

# From now on, some ssh commands will exit non-0, which should be fine
set +e

# From raspi-config: https://github.com/RPi-Distro/raspi-config/blob/d98686647ced7c0c0490dc123432834735d1c13d/raspi-config#L1313-L1321
# See also: https://github.com/futurice/chilipie-kiosk/issues/61#issuecomment-524622522
working "auto-login aktiverento CLI"
ssh "sudo systemctl set-default multi-user.target"
ssh "sudo ln -fs /lib/systemd/system/getty@.service /etc/systemd/system/getty.target.wants/getty@tty1.service"
ssh "sudo mkdir -p /etc/systemd/system/getty@tty1.service.d"
ssh "echo -e '[Service]\nExecStart=\nExecStart=-/sbin/agetty --autologin pi --noclear %I \$TERM\n' | sudo tee /etc/systemd/system/getty@tty1.service.d/autologin.conf"

#working "Setting timezone"
ssh "(echo '$TIMEZONE' | sudo tee /etc/timezone) && sudo dpkg-reconfigure --frontend noninteractive tzdata"

#working "Setting keyboard layout"
#ssh "(echo -e 'XKBMODEL="pc105"\nXKBLAYOUT="$KEYBOARD"\nXKBVARIANT=""\nXKBOPTIONS=""\nBACKSPACE="guess"\n' | sudo tee /etc/default/keyboard) && sudo dpkg-reconfigure --frontend noninteractive keyboard-configuration"

working "Silencing console logins" # this is to avoid a brief flash of the console login before X comes up
ssh "sudo rm /etc/profile.d/sshpwd.sh /etc/profile.d/wifi-check.sh" # remove warnings about default password and WiFi country (https://raspberrypi.stackexchange.com/a/105234)
ssh "touch .hushlogin" # https://scribles.net/silent-boot-on-raspbian-stretch-in-console-mode/
ssh "sudo perl -i -p0e 's#--autologin pi#--skip-login --noissue --login-options \"-f pi\"#g' /etc/systemd/system/getty@tty1.service.d/autologin.conf" # "perl" is more cross-platform than "sed -i"

working "Installing packages"
ssh "sudo apt-get update && sudo apt-get -y upgrade && DEBIAN_FRONTEND=noninteractive sudo apt-get install -y vim matchbox-window-manager unclutter mailutils nitrogen jq chromium-browser xserver-xorg xinit rpd-plym-splash xdotool rng-tools xinput-calibrator cec-utils realvnc-vnc-server unattended-upgrades npm nodejs lshw xfonts-encodings"
# We install mailutils just so that you can check "mail" for cronjob output

working "Setting home directory default content"
scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -rp "home" "pi@$IP:/home/pi/"
ssh "mv /home/pi/home/* /home/pi/"
ssh "mv /home/pi/home/.matchbox* /home/pi/"
ssh "rm -r /home/pi/home"

working "Skripts ausfuehrbar machen"
ssh "chmod +x *.sh && chmod +x .xsession"

working "Setting splash screen background"
ssh "sudo rm /usr/share/plymouth/themes/pix/splash.png && sudo ln -s /home/pi/background.png /usr/share/plymouth/themes/pix/splash.png"

working "Installing default crontab"
ssh "crontab /home/pi/crontab.example"

working "VNC-Service einrichten (Kennwort \"wachalarm\")"
ssh "sudo cp /home/pi/vncserver-x11 /root/.vnc/config.d/vncserver-x11"
ssh "sudo systemctl enable vncserver-x11-serviced.service && sudo systemctl start vncserver-x11-serviced.service"

working "Zeiteinstellungen fuer NTP setzen"
ssh "sudo timedatectl set-ntp 1 && sudo timedatectl set-local-rtc 0"
#ssh "sudo systemctl restart systemd-timesyncd.service"

working "Automatische Sicherheitsupdates einrichten"
ssh "sudo dpkg-reconfigure -pmedium unattended-upgrades"
ssh "sudo cp /home/pi/50unattended-upgrades /etc/apt/apt.conf.d/50unattended-upgrades"

working "VNC- und SSH-Zugang einschraenken"
ssh "sudo cp /home/pi/hosts.deny /etc/hosts.deny && sudo cp /home/pi/hosts.allow /etc/hosts.allow"
#ssh "sudo service sshd restart"

working "Waip-Standby-Skript installieren"
ssh "(cd /home/pi && npm install)"

working "Rebooting the Pi"
ssh "sudo reboot"

echo "Waiting for host to come back up..."
until SSH_CONNECT_TIMEOUT=5 ssh "echo OK"
do
  sleep 1
done

question "Sobald der Pi mit Chromium neugestartet hat:"
echo "* Tell Chromium we don't want to sign in"
echo "* Configure Chromium to start \"where you left off\""
echo "  * F11 to exit full screen"
echo "  * Alt + F, then S to go to Settings"
echo "  * Type \"continue\" to filter the options"
echo "  * Tab to select \"Continue where you left off\""
echo "  * (or in German \"Zuletzt angesehene Seite oeffnen\")"
echo "  * "
echo "* Alle Tabs schließen und Raspberry neu Starten"
echo "(press enter when ready)"
read



# weitere Einstellungen

# remove all known wifis

# sudo raspi-config -> System -> Audio auf HDMI ändern
# image shrink

# TV
# Einrichutng -> "Mute" 1 1 9 "Enter"
# Menu OSD -> Menu Display -> off

# Raspberry an TV HDMI 1 
# Raspberry HDMI 0 (Neben USB-C-Stromanschluss)
# lautsprecher tv auf 25

# Konfiguration direkt auf SD-Karte
# ip per einstellungen txt setzen
# wlan per wpa_supplicant