#!/bin/bash

sudo timedatectl set-ntp true
sudo hwclock --systohc

sudo reflector --verbose --latest 5 --sort rate --save /etc/pacman.d/mirrorlist
sudo pacman -Syyuu

sudo pacman -S --noconfirm xorg wayland gnome-shell gnome-control-center gnome-tweak-tool gnome-tweaks gnome-shell-extensions gdm libva-intel-driver libva-utils intel-gpu-tools mesa mesa-utils nvidia nvidia-utils nvidia-settings opencl-nvidia nvidia-prime vulkan-intel vulkan-headers vulkan-tools nautilus gnome-terminal file-roller gnome-calculator gnome-system-monitor evince eog gnome-backgrounds gnome-user-share gedit neofetch firefox helvum blender gimp mpv vlc transmission-gtk jdk-openjdk android-tools android-udev flameshot wget powerline

sudo systemctl enable gdm
sudo systemctl enable libvirtd
sudo pacman -S flatpak
flatpak install -y spotify androidstudio onlyoffice obsproject teams pycharm-community steam heroic telegram discordapp flatseal

# AUR helper install
git clone https://aur.archlinux.org/paru.git
cd paru
makepkg -si

paru gnome-browser-connector-git ttf-meslo-nerd-font-powerlevel10k rtl8821cu-morrownr-dkms-git inxi-git

# ZSH configuration
sudo pacman -S zsh zsh-syntax-highlighting zsh-autosuggestions zsh-history-substring-search zsh-theme-powerlevel10k zsh-completions
echo 'source /usr/share/zsh-theme-powerlevel10k/powerlevel10k.zsh-theme' >>~/.zshrc
echo 'source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh' >> ~/.zshrc
echo 'source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh' >> ~/.zshrc
echo 'source /usr/share/zsh/plugins/zsh-history-substring-search/zsh-history-substring-search.zsh' >> ~/.zshrc

chsh -s $(which zsh)

print "Reinicie o sistema"
