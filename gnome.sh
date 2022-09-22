#!/bin/bash

sudo timedatectl set-ntp true
sudo hwclock --systohc

sudo reflector --verbose --latest 5 --sort rate --save /etc/pacman.d/mirrorlist
sudo pacman -Syyuu

sudo pacman -S --noconfirm base-devel xorg xorg-server wayland xorg-xwayland gnome-shell nautilus gnome-terminal gnome-tweak-tool gnome-control-center xdg-user-dirs xdg-desktop-portal gdm gnome-tweaks gnome-shell-extensions intel-media-driver libva-intel-driver libva-utils intel-gpu-tools nvidia nvidia-utils nvidia-settings nvidia-prime
sudo pacman -S neofetch firefox helvum blender gimp mpv transmission-gtk smplayer zsh papirus-icon-theme jdk-openjdk virtualbox android-tools android-udev

sudo pacman -S flatpak
sudo flatpak install -y com.spotify.Client com.google.AndroidStudio org.onlyoffice.desktopeditors com.obsproject.Studio com.microsoft.Teams

git clone https://aur.archlinux.org/paru.git
cd paru
makepkg -si

paru gnome-browser-connector-git virtualbox-ext-oracle adw-gtk-theme

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
print "Reinicie o sistema"
