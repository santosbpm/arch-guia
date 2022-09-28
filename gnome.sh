#!/bin/bash

sudo timedatectl set-ntp true
sudo hwclock --systohc

sudo reflector --verbose --latest 5 --sort rate --save /etc/pacman.d/mirrorlist
sudo pacman -Syyuu

sudo pacman -S --noconfirm xorg xorg-server wayland xorg-xwayland gnome-shell nautilus gnome-terminal gnome-tweak-tool gnome-control-center xdg-user-dirs xdg-desktop-portal xdg-desktop-portal-gtk gdm gnome-tweaks gnome-shell-extensions intel-media-driver libva-intel-driver libva-utils intel-gpu-tools nvidia nvidia-utils nvidia-settings nvidia-prime
sudo pacman -S neofetch firefox helvum blender gimp mpv smplayer vlc transmission-gtk zsh papirus-icon-theme jdk-openjdk virtualbox android-tools android-udev flameshot
suco pacman -S file-roller gnome-calculator gnome-system-monitor evince gnome-backgrounds gnome-remote-desktop gnome-menus gnome-user-share gedit

sudo pacman -S flatpak
sudo flatpak install -y com.spotify.Client com.google.AndroidStudio org.onlyoffice.desktopeditors com.obsproject.Studio com.microsoft.Teams com.jetbrains.PyCharm-Community com.visualstudio.code

git clone https://aur.archlinux.org/paru.git
cd paru
makepkg -si

paru gnome-browser-connector-git virtualbox-ext-oracle packettracer timeshift timeshift-autosnap

# Configuração zsh
# chsh -s $(which zsh)
sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
sudo pacman -S powerline zsh-autosuggestions zsh-completions zsh-history-substring-search zsh-syntax-highlighting zsh-theme-powerlevel10k
git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf && ~/.fzf/install

# Configuração virtualbox
sudo gpasswd -a $USER vboxusers
sudo modprobe vboxguest vboxvideo vboxsf

sudo systemctl enable gdm
print "Reinicie o sistema"
