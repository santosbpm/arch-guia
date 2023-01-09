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

# Packets i3
sudo pacman -S xorg xorg-server xorg-xinit libva-intel-driver libva-utils intel-gpu-tools mesa mesa-utils nvidia nvidia-utils nvidia-settings opencl-nvidia nvidia-prime vulkan-intel vulkan-headers vulkan-tools i3 i3lock rofi picom nitrogen polybar polkit lxappearance alacritty thunar pamixer pavucontrol network-manager-applet blueman evince eog gvfs-mtp mtpfs neovim neofetch firefox helvum gimp mpv transmission-gtk jdk-openjdk android-tools android-udev flameshot wget virt-manager qemu-desktop libvirt edk2-ovmf dnsmasq iptables-nft noto-fonts ttf-hack-nerd ttf-liberation otf-font-awesome ttf-font-awesome ttf-dejavu ttc-iosevka papirus-icon-theme gnome-themes-extra

sudo systemctl enable libvirtd
sudo systemctl enable snapper-timeline.timer
sudo systemctl enable snapper-cleanup.timer

sudo pacman -S flatpak
flatpak install -y spotify onlyoffice obsproject teams steam telegram discordapp flatseal

# AUR helper install
git clone https://aur.archlinux.org/paru.git
cd paru
makepkg -si

paru -S ttf-font-icons inxi-git asdf-vm indicator-kdeconnect networkmanager-dmenu 

# ZSH configuration
sudo pacman -S zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
git clone https://github.com/zsh-users/zsh-history-substring-search ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-history-substring-search
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-completions ${ZSH_CUSTOM:-${ZSH:-~/.oh-my-zsh}/custom}/plugins/zsh-completions
echo 'fpath=(~/.zsh/zsh-completions/src $fpath)' >> ~/.zshrc
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
chsh -s $(which zsh)

echo '# Aliases ZSH' >>~/.zshrc
echo 'alias paru-full="paru && flatpak update"' >>~/.zshrc
echo 'alias mirrors-update="sudo reflector --verbose --latest 5 --sort rate --save /etc/pacman.d/mirrorlist && pacman -Syy"' >>~/.zshrc
echo 'alias intel="sudo intel_gpu_top"' >>~/.zshrc

echo '# PATH' >>~/.zshrc
echo '. /opt/asdf-vm/asdf.sh\nexport PATH=/home/santosbpm/.local/bin:$PATH' >>~/.zshrc

LV_BRANCH='release-1.2/neovim-0.8' bash <(curl -s https://raw.githubusercontent.com/lunarvim/lunarvim/master/utils/installer/install.sh)

sudo snapper -c root create --description "### Base i3 packages ###"

print "Reinicie o sistema"
