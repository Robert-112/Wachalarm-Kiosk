#!/bin/bash

export DISPLAY=:0.0

# Start cursor at the top-left corner, as opposed to the default of dead-center
# (so it doesn't accidentally trigger hover styles on elements on the page)
xdotool mousemove 0 0

# Set some useful X preferences
xset s off # don't activate screensaver
xset -dpms # disable DPMS (Energy Star) features.
xset s noblank # don't blank the video device

# Set X screen background
sudo nitrogen --set-centered background.png

# Hide cursor afer 5 seconds of inactivity
unclutter -idle 5 -root &

#Set CrProfile to the value of your startup profile's config folder
CrProfile="Default"

HomeFolder="/home/pi"

# Remove notes of previous sessions, if any
find .config/chromium/ -name "Last *" -exec rm {} +

#Delete SingletonLock
rm -f $HomeFolder/.config/chromium/SingletonLock
rm -f $HomeFolder/.cache/chromium

#Clean up the randomly-named file(s)
for i in $HomeFolder/.config/chromium/$CrProfile/.org.chromium.Chromium.*; do
    sed -i 's/"exited_cleanly": false/"exited_cleanly": true/' $i
    sed -i 's/"exit_state": "Crashed"/"exit_state": "Normal"/' $i
    sed -i 's/"exit_type":"Crashed"/"exit_type":"Normal"/' $i
done

#Clean up Preferences
sed -i 's/"exited_cleanly": false/"exited_cleanly": true/' $HomeFolder/.config/chromium/$CrProfile/Preferences
sed -i 's/"exit_state": "Crashed"/"exit_state": "Normal"/' $HomeFolder/.config/chromium/$CrProfile/Preferences
sed -i 's/"exit_type":"Crashed"/"exit_type":"Normal"/' $HomeFolder/.config/chromium/$CrProfile/Preferences

#Clean up Local State
sed -i 's/"exited_cleanly": false/"exited_cleanly": true/' $HomeFolder/.config/chromium/"Local State"

# Get URL from file (if set)
URL="file:///home/pi/LICENSE.html"
standby_enable=0
if [ -f /boot/firmware/wachalarm_einstellungen.txt ]; then
    source /boot/firmware/wachalarm_einstellungen.txt
    URL=$startup_url
fi

# Start and detach Chromium
# http://peter.sh/experiments/chromium-command-line-switches/
# Note that under matchbox, starting in full-screen without a window size doesn't behave well when you try to exit full screen (see https://unix.stackexchange.com/q/273989)
chromium-browser \
  --start-fullscreen \
  --window-position=9000,9000 \
  --disable-infobars \
  --check-for-update-interval=604800 \
  $URL &
# See https://github.com/futurice/chilipie-kiosk/issues/99#issuecomment-597119842 for the need for the fishy-sounding "--check-for-update-interval=1 --simulate-critical-update" switches; TODO: remove when not needed

# Hide Chromium while it's starting/loading the page
wid=`xdotool search --sync --onlyvisible --class chromium`
xdotool windowunmap $wid
sleep 10 # give the web page time to load
xdotool windowmap $wid

# Finally, switch process to our window manager
exec matchbox-window-manager -use_titlebar no
