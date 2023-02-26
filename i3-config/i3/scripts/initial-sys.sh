#!/bin/bash

monitors=`xrandr | grep "HDMI-1-0 connected" | awk '{print "1"}'`

if [[ $monitors == "" ]]; then
	setxkbmap -layout us -variant altgr-intl
else
	xrandr --output eDP-1 --mode 1920x1080 --rate 60 --output HDMI-1-0 --mode 1920x1080 --rate 120 --left-of eDP-1
	setxkbmap -layout br
fi
