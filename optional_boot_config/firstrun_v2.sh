#!/bin/bash
set +e
# feste IP-Adressen fuer LAN und WLAN hinterlegen
cat > /etc/dhcpcd.conf <<'DHCPCDEOF'
# configuration for dhcpcd.
# See dhcpcd.conf(5) for details.

# Inform the DHCP server of our hostname for DDNS.
hostname

# Use the hardware address of the interface for the Client ID.
clientid
# or
# Use the same DUID + IAID as set in DHCPv6 for DHCPv4 ClientID as per RFC4361.
# Some non-RFC compliant DHCP servers do not reply with this set.
# In this case, comment out duid and enable clientid above.
#duid

# Persist interface configuration when dhcpcd exits.
persistent

# Rapid commit support.
# Safe to enable by default because it requires the equivalent option set
# on the server to actually work.
option rapid_commit

# A list of options to request from the DHCP server.
option domain_name_servers, domain_name, domain_search, host_name
option classless_static_routes
# Respect the network MTU. This is applied to DHCP routes.
option interface_mtu

# Most distributions have NTP support.
#option ntp_servers

# A ServerID is required by RFC2131.
require dhcp_server_identifier

# Generate SLAAC address using the Hardware Address of the interface
#slaac hwaddr
# OR generate Stable Private IPv6 Addresses based from the DUID
slaac private

# static IP configuration:

interface wlan0
static ip_address=192.168.179.123/24
static routers=192.168.179.8
static domain_name_servers=1.1.1.1

DHCPCDEOF
rm -f /boot/firstrun.sh
sed -i 's| systemd.run.*||g' /boot/cmdline.txt
# 3d-Treiber deaktiveren
sed -i 's/dtoverlay=vc4-kms-v3d/#dtoverlay=vc4-kms-v3d/g' /boot/config.txt
# Audio Klinke aktivieren
sed -i 's/#dtparam=audio=on/dtparam=audio=on/g' /boot/config.txt
# display-*.sh statt hdmicec verwenden
sed -i 's/cec-on.sh/display-on.sh/g' /home/pi/waip_standby_websocket.js
sed -i 's/cec-off.sh/display-off.sh/g' /home/pi/waip_standby_websocket.js
# Tastenkuerzel fuer Monitor ein/aus
mkdir /home/pi/.matchbox
touch /home/pi/.matchbox/kbdconfig
cat > /home/pi/.matchbox/kbdconfig <<'KBDCONFIGEOF'
<ctrl>o=!/home/pi/display-off.sh
<ctrl>i=!/home/pi/display-on.sh

KBDCONFIGEOF
# Passwort des Benutzers pi aendern
echo "pi:ganz_geheim" | sudo chpasswd
exit 0