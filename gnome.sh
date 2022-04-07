#!/bin/bash

sudo timedatectl set-ntp true
sudo hwclock --systohc

sudo reflector --verbose --latest 5 --sort rate --save /etc/pacman.d/mirrorlist
sudo pacman -Syyuu

sudo pacman -S --noconfirm xorg xorg-server wayland xorg-xwayland xdg-desktop-portal gdm gnome gnome-tweaks gnome-shell-extensions chrome-gnome-shell gnome-bluetooth flatpak firefox chromium evince gparted fragments vim virtualbox timeshift blender gimp mpv smplayer zsh zsh-autosuggestions zsh-completions zsh-history-substring-search zsh-syntax-highlighting zsh-theme-powerlevel10k

sudo flatpak install -y com.spotify.Client com.google.AndroidStudio com.sublimetext.three org.onlyoffice.desktopeditors com.obsproject.Studio com.microsoft.Teams

sudo systemctl enable gdm
/bin/echo -e "\e[1;32mREBOOTING IN 5..4..3..2..1..\e[0m"
sleep 5
sudo reboot
