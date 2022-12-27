#!/bin/bash

export DISPLAY=:0.0

# Click on web page to activate webaudio auto-play
monitor_x="$(fbset -s | awk '$1 == "geometry" { print $2 }')"
sub_x=100
monitor_y="$(fbset -s | awk '$1 == "geometry" { print $3 }')"
sub_y=50
buttom_x=$(expr $monitor_x - $sub_x)
buttom_y=$(expr $monitor_y - $sub_y)
xdotool mousemove $buttom_x $buttom_y
sleep 1
xdotool click 1
sleep 1
xdotool mousemove 200 200
sleep 1
xdotool click 1
sleep 1
unclutter -idle 1 -root
