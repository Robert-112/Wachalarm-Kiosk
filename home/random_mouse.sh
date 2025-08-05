#!/bin/bash

export DISPLAY=:0.0

rand_x="$((1 + $RANDOM % 800))"
rand_y="$((1 + $RANDOM % 600))"

xdotool mousemove $rand_x $rand_y
