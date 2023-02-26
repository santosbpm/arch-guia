#!/bin/sh

VOLUME=$(pamixer --get-volume-human)


case $1 in
    "--up")
	pamixer --sink 56 --increase 10 --set-limit 100
	pamixer --sink 57 --increase 10 --set-limit 100
	pamixer --sink 59 --increase 10 --set-limit 100
        ;;
    "--down")
        pamixer --sink 56 --decrease 10
	pamixer --sink 57 --decrease 10
	pamixer --sink 59 --decrease 10
        ;;
    "--mute")
        pamixer --sink 56 --toggle-mute
	pamixer --sink 57 --toggle-mute
	pamixer --sink 59 --toggle-mute
        ;;
    "--toggle-mic")
	pamixer --source 58 --toggle-mute
	pamixer --source 60 --toggle-mute
	;;
    *)
        echo " ${VOLUME}"
esac
