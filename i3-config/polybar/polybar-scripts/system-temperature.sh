#!/bin/bash


printf " "
sensors | grep Package | awk '{print substr($4, 2, length($4)-3)}'|cut -f1 -d"." | tr "\\n" " " | sed 's/ /°C  /g' | sed 's/  $//'
printf "         "
nvidia-smi --query-gpu=temperature.gpu --format=csv,noheader | tr "\\n" " " | sed 's/ /°C  /g' | sed 's/  $//'
