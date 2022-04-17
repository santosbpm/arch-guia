#!/bin/bash

sudo timedatectl set-ntp true
sudo hwclock --systohc

sudo reflector --verbose --latest 5 --sort rate --save /etc/pacman.d/mirrorlist
sudo pacman -Syyuu

sudo pacman -S --noconfirm base-devel xorg xorg-server wayland xorg-xwayland xdg-desktop-portal gdm gnome gnome-tweaks gnome-shell-extensions intel-media-driver libva-intel-driver libva-utils intel-gpu-tools nvidia nvidia-utils nvidia-settings nvidia-prime
sudo pacman -S flatpak firefox chromium blender gimp mpv smplayer zsh gnome-themes-extra gnome-icon-theme-extras adwaita-icon-theme adw-gtk-theme volantes-cursors capitaine-cursors papirus-icon-theme jdk-openjdk virtualbox
sudo pacman -Rns gnome-books gnome-calendar gnome-characters gnome-clocks gnome-contacts gnome-maps gnome-weather gnome-boxes gnome-music totem gnome-software gnome-photos epiphany inskape

sudo flatpak install -y com.spotify.Client com.google.AndroidStudio org.onlyoffice.desktopeditors com.obsproject.Studio com.microsoft.Teams

git clone https://aur.archlinux.org/paru.git
cd paru
makepkg -si

paru install chrome-gnome-shell timeshift virtualbox-ext-oracle

# Configuração zsh
# chsh -s $(which zsh)
sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
git clone https://github.com/zsh-users/zsh-history-substring-search.git ~/.oh-my-zsh/custom/plugins/zsh-history-substring-search
git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf && ~/.fzf/install

# Configuração virtualbox
sudo gpasswd -a $USER vboxusers
sudo modprobe vboxguest vboxvideo vboxsf

sudo systemctl enable gdm
/bin/echo -e "\e[1;32mREBOOTING IN 5..4..3..2..1..\e[0m"
sleep 5
sudo reboot
