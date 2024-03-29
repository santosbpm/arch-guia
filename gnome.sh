#!/bin/bash

sudo timedatectl set-ntp true
sudo hwclock --systohc

sudo reflector --verbose --latest 20 --sort rate --country Brazil,US --save /etc/pacman.d/mirrorlist
sudo pacman -Syu

sudo umount /.snapshots
sudo rm -r /.snapshots
sudo snapper -c root create-config /
sudo btrfs subvolume delete /.snapshots/
sudo mkdir /.snapshots
sudo mount -a
sudo chmod 750 /.snapshots
sudo snapper -c root create --description "### Configuration Base Arch ###"

sudo pacman -S wayland gnome-shell gnome-control-center gnome-tweak-tool gnome-shell-extensions gdm bluez bluez-utils alsa-utils pipewire pipewire-alsa pipewire-pulse pipewire-jack wireplumber libva-intel-driver libva-utils intel-gpu-tools mesa mesa-utils vulkan-headers vulkan-tools xdg-desktop-portal-gnome nautilus file-roller gnome-console gnome-calculator htop eog gnome-disk-utility dosfstools exfat-utils gvfs-mtp mtpfs neovim neofetch firefox helvum gimp mpv yt-dlp transmission-gtk android-tools android-udev wget networkmanager-openvpn virt-manager qemu-desktop dnsmasq iptables-nft docker docker-compose noto-fonts ttf-hack-nerd ttf-liberation papirus-icon-theme git
sudo systemctl enable bluetooth
sudo systemctl enable gdm
# sudo systemctl enable libvirtd
# sudo systemctl enable docker
sudo systemctl enable snapper-timeline.timer
sudo systemctl enable snapper-cleanup.timer

sudo pacman -S nvidia nvidia-utils nvidia-settings nvidia-prime nvtop

sudo echo "options nvidia_drm modeset=1" >> /etc/etc/modprobe.d/nvidia.conf

sudo printf "blacklist iTCO_wdt\nblacklist iTCO_vendor_support" >> /etc/modprobe.d/watchdog.conf

sudo vim /etc/mkinitcpio.conf

sudo systemctl enable nvidia-suspend.service
sudo systemctl enable nvidia-hibernate.service

sudo mkinitcpio -p linux
sbctl sign-all

sudo pacman -S flaptak
flatpak install obsidian spotify libreoffice obsproject pycharm-community steam telegram flatseal

git clone https://aur.archlinux.org/paru.git
cd paru
makepkg -si

paru -S gnome-browser-connector-git inxi-git asdf-vm ventoy-bin paru-bin

sudo pacman -S zsh

sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-history-substring-search ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-history-substring-search
git clone https://github.com/zsh-users/zsh-completions.git ~/.zsh/zsh-completions
echo 'fpath=(~/.zsh/zsh-completions/src $fpath)' >> ~/.zshrc

vim ~/.zshrc
echo '' >> ~/.zshrc
echo '# Aliases ZSH' >> ~/.zshrc
echo 'alias pf="paru && flatpak update"' >> ~/.zshrc
echo 'alias mu="sudo reflector --verbose --latest 20 --sort rate --country Brazil,US,UK --save /etc/pacman.d/mirrorlist && sudo pacman -Syu"' >> ~/.zshrc
echo 'alias intel="sudo intel_gpu_top"' >> ~/.zshrc

echo '' >> ~/.zshrc
echo '# PATH' >>~/.zshrc
echo '. /opt/asdf-vm/asdf.sh\nexport PATH=/home/santosbpm/.local/bin:$PATH' >> ~/.zshrc

chsh -s $(which zsh)

LV_BRANCH='release-1.2/neovim-0.8' bash <(curl -s https://raw.githubusercontent.com/lunarvim/lunarvim/master/utils/installer/install.sh)

echo "Finalizado!!!"
