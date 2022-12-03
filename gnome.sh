#!/bin/bash

sudo timedatectl set-ntp true
sudo hwclock --systohc

sudo reflector --verbose --latest 5 --sort rate --save /etc/pacman.d/mirrorlist
sudo pacman -Syyuu

sudo pacman -S --noconfirm xorg wayland gnome-shell gnome-control-center gnome-tweak-tool gnome-tweaks gnome-shell-extensions gdm libva-intel-driver libva-utils intel-gpu-tools nvidia nvidia-utils nvidia-settings opencl-nvidia nvidia-prime nautilus gnome-terminal file-roller gnome-calculator gnome-system-monitor evince gnome-backgrounds gnome-user-share gedit neofetch firefox helvum blender gimp mpv vlc transmission-gtk zsh zsh-theme-powerlevel10k jdk-openjdk android-tools android-udev flameshot

sudo systemctl enable gdm

sudo pacman -S flatpak
flatpak install -y spotify androidstudio onlyoffice obsproject teams pycharm-community steam heroic telegram discordapp flatseal

git clone https://aur.archlinux.org/paru.git
cd paru
makepkg -si

paru gnome-browser-connector-git packettracer ttf-meslo-nerd-font-powerlevel10k rtl8821cu-morrownr-dkms-git

# Configuração zsh
echo 'source /usr/share/zsh-theme-powerlevel10k/powerlevel10k.zsh-theme' >>~/.zshrc
git clone https://github.com/zsh-users/zsh-autosuggestions ~/.zsh/zsh-autosuggestions
source ~/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh
git clone https://github.com/zsh-users/zsh-completions.git
fpath=(path/to/zsh-completions/src $fpath)
rm -f ~/.zcompdump; compinit
sudo pacman -S zsh-history-substring-search
echo 'source /usr/local/share/zsh-history-substring-search/zsh-history-substring-search.zsh' >> ~/.zshrc
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git
echo "source ${(q-)PWD}/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" >> ${ZDOTDIR:-$HOME}/.zshrc
chsh -s $(which zsh)

print "Reinicie o sistema"
