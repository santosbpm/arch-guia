#!/bin/bash

sudo timedatectl set-ntp true
sudo hwclock --systohc
sudo reflector --verbose --latest 5 --sort rate --save /etc/pacman.d/mirrorlist
sudo pacman -Syyuu

# Configuration Snapper
sudo umount /.snapshots
sudo rm -r /.snapshots/
sudo snapper -c root create-config /
sudo btrfs subvolume delete /.snapshots/
sudo mkdir /.snapshots
sudo mount -o subvol=@snapshots /dev/nvme0n1p2 /.snapshots/
sudo mount -a
sudo chmod 750 /.snapshots
sudo snapper -c root create --description "### Configuration Base Arch ###"

# Packets Gnome
sudo pacman -S xorg wayland gnome-shell gnome-control-center gnome-tweak-tool gnome-tweaks gnome-shell-extensions gdm libva-intel-driver libva-utils intel-gpu-tools mesa mesa-utils nvidia nvidia-utils nvidia-settings opencl-nvidia nvidia-prime vulkan-intel vulkan-headers vulkan-tools xdg-desktop-portal-gnome nautilus gnome-terminal file-roller gnome-calculator gnome-system-monitor evince eog gnome-backgrounds gnome-user-share gvfs-mtp mtpfs gedit neovim neofetch firefox helvum gimp mpv vlc transmission-gtk jdk-openjdk android-tools android-udev flameshot wget virt-manager qemu-desktop dnsmasq alacritty iptables-nft noto-fonts ttf-hack-nerd ttf-liberation papirus-icon-theme gnome-themes-extra

sudo systemctl enable gdm
sudo systemctl enable libvirtd
sudo systemctl enable snapper-timeline.timer
sudo systemctl enable snapper-cleanup.timer

sudo pacman -S flatpak
flatpak install -y spotify onlyoffice obsproject teams pycharm-community steam telegram discordapp flatseal

# AUR helper install
git clone https://aur.archlinux.org/paru.git
cd paru
makepkg -si

paru -S gnome-browser-connector-git rtl8821cu-morrownr-dkms-git inxi-git asdf-vm

# ZSH configuration
sudo pacman -S zsh zsh-syntax-highlighting zsh-autosuggestions zsh-history-substring-search zsh-theme-powerlevel10k
echo '\n\n# Plugins ZSH' >>~/.zshrc
echo 'source /usr/share/zsh-theme-powerlevel10k/powerlevel10k.zsh-theme' >>~/.zshrc
echo 'source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh' >> ~/.zshrc
echo 'source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh' >> ~/.zshrc
echo 'source /usr/share/zsh/plugins/zsh-history-substring-search/zsh-history-substring-search.zsh' >> ~/.zshrc
git clone https://github.com/zsh-users/zsh-completions.git ~/.zsh/zsh-completions
echo 'fpath=(~/.zsh/zsh-completions/src $fpath)' >> ~/.zshrc

echo '\n\n# Aliases ZSH' >>~/.zshrc
echo 'alias paru-full="paru && flatpak update"' >>~/.zshrc
echo 'alias mirrors-update="sudo reflector --verbose --latest 5 --sort rate --save /etc/pacman.d/mirrorlist && pacman -Syy"' >>~/.zshrc
echo 'alias intel="sudo intel_gpu_top"' >>~/.zshrc

echo '\n\n# PATH' >>~/.zshrc
echo '. /opt/asdf-vm/asdf.sh\nexport PATH=/home/santosbpm/.local/bin:$PATH' >>~/.zshrc

chsh -s $(which zsh)

LV_BRANCH='release-1.2/neovim-0.8' bash <(curl -s https://raw.githubusercontent.com/lunarvim/lunarvim/master/utils/installer/install.sh)

sudo snapper -c root create --description "### Base Gnome ###"

print "Reinicie o sistema"
