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

sudo pacman -S xorg xorg-server xorg-xinit libva-intel-driver libva-utils intel-gpu-tools mesa mesa-utils nvidia nvidia-utils nvidia-settings nvidia-prime vulkan-headers vulkan-tools noto-fonts ttf-hack-nerd ttf-liberation otf-font-awesome ttf-font-awesome ttf-dejavu ttc-iosevka

# Packets i3
sudo pacman -S i3 i3lock xdg-user-dirs xdg-utils xdg-desktop-portal xdg-desktop-portal-gtk xautolock xdotool xsel xclip rofi picom nitrogen polybar polkit polkit-gnome lxappearance alacritty thunar thunar-volman pamixer pavucontrol playerctl network-manager-applet blueman light redshift evince eog obsidian gvfs-mtp mtpfs neovim neofetch firefox helvum gimp mpv transmission-gtk jdk-openjdk android-tools android-udev wget virt-manager qemu-desktop libvirt edk2-ovmf dnsmasq iptables-nft papirus-icon-theme gtk-engine-murrine

sudo systemctl enable libvirtd
sudo systemctl enable snapper-timeline.timer
sudo systemctl enable snapper-cleanup.timer

sudo pacman -S flatpak
flatpak remote-add --if-not-exists kdeapps --from https://distribute.kde.org/kdeapps.flatpakrepo
flatpak install -y spotify onlyoffice obsproject teams steam telegram discordapp flatseal Flameshot Kvantum nord kdeconnect

# AUR helper install
git clone https://aur.archlinux.org/paru.git
cd paru
makepkg -si

paru -S ttf-font-icons inxi-git xidlehook

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
echo 'alias pf="paru && flatpak update"' >>~/.zshrc
echo 'alias mu="sudo reflector --verbose --latest 20 --sort rate --country Brazil,US,UK --save /etc/pacman.d/mirrorlist && sudo pacman -Syy"' >>~/.zshrc
echo 'alias intel="sudo intel_gpu_top"' >>~/.zshrc

echo '# PATH' >>~/.zshrc
echo '. /opt/asdf-vm/asdf.sh\nexport PATH=/home/santosbpm/.local/bin:$PATH' >>~/.zshrc

LV_BRANCH='release-1.2/neovim-0.8' bash <(curl -s https://raw.githubusercontent.com/lunarvim/lunarvim/master/utils/installer/install.sh)

sudo snapper -c root create --description "### Base i3 packages ###"

print "Reinicie o sistema"
