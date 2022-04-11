#!/bin/bash

sudo timedatectl set-ntp true
sudo hwclock --systohc

sudo reflector --verbose --latest 5 --sort rate --save /etc/pacman.d/mirrorlist
sudo pacman -Syyuu

git clone https://aur.archlinux.org/paru.git
cd paru
makepkg -si

sudo pacman -S --noconfirm base-devel xorg xorg-server wayland xorg-xwayland xdg-desktop-portal gdm gnome gnome-tweaks gnome-shell-extensions gnome-bluetooth intel-media-driver flatpak firefox chromium evince gparted fragments vim vjre-openjdk-headlessirtualbox blender gimp mpv smplayer zsh zsh-autosuggestions zsh-syntax-highlighting adwaita-icon-theme papirus-icon-theme jre-openjdk 

sudo flatpak install -y com.spotify.Client com.google.AndroidStudio org.onlyoffice.desktopeditors com.obsproject.Studio com.microsoft.Teams org.gtk.Gtk3theme.adw-gtk3-dark org.gtk.Gtk3theme.Breeze

paru install chrome-gnome-shell timeshift timeshift-autosnap 

sudo systemctl enable gdm
/bin/echo -e "\e[1;32mREBOOTING IN 5..4..3..2..1..\e[0m"
sleep 5
sudo reboot
