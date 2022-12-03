#!/bin/bash

loadkeys br-abnt2
locale-gen
export LANG=pt_BR.UTF-8
timedatectl set-ntp true
sudo reflector --verbose --latest 5 --sort rate --save /etc/pacman.d/mirrorlist
pacman -Syy

# create partition
mkfs.fat -F32 -n BOOT /dev/nvme0n1p1
mkfs.btrfs --csum xxhash /dev/nvme0n1p2

# create subvolumes
mount /dev/nvme0n1p2 /mnt
btrfs subvolume delete /mnt/@
# btrfs subvolume delete /mnt/@home
btrfs subvolume delete /mnt/@root
btrfs subvolume delete /mnt/@log
btrfs subvolume delete /mnt/@cache
btrfs subvolume delete /mnt/@games
btrfs subvolume delete /mnt/@usr_local
btrfs subvolume delete /mnt/@libvirt
btrfs subvolume delete /mnt/@flatpak
btrfs subvolume delete /mnt/@opt
btrfs subvolume delete /mnt/@snapshots

btrfs subvolume create /mnt/@
# btrfs subvolume create /mnt/@home
btrfs subvolume create /mnt/@root
btrfs subvolume create /mnt/@log
btrfs subvolume create /mnt/@cache
btrfs subvolume create /mnt/@games
btrfs subvolume create /mnt/@usr_local
btrfs subvolume create /mnt/@libvirt
btrfs subvolume create /mnt/@flatpak
btrfs subvolume create /mnt/@opt
btrfs subvolume create /mnt/@snapshots
chown root:games @games

chattr +C /mnt/@libvirt
umount /mnt

mount -o defaults,noatime,discard=async,compress-force=zstd,ssd,subvol=@ /dev/nvme0n1p2 /mnt
mkdir -p /mnt/boot/efi
mkdir /mnt/home
mkdir /mnt/root
mkdir /mnt/var/log
mkdir /mnt/var/cache
mkdir /mnt/var/games
mkdir /mnt/usr/local
mkdir /mnt/var/lib/libvirt
mkdir /mnt/var/lib/flatpak
mkdir /mnt/opt
mkdir /mnt/.snapshots
mount -o defaults,noatime,discard=async,compress-force=zstd,ssd,subvol=@home /dev/nvme0n1p2 /mnt/home
mount -o defaults,noatime,discard=async,compress-force=zstd,ssd,subvol=@root /dev/nvme0n1p2 /mnt/root
mount -o defaults,noatime,discard=async,compress-force=zstd,ssd,subvol=@log /dev/nvme0n1p2 /mnt/var/log
mount -o defaults,noatime,discard=async,compress-force=zstd,ssd,subvol=@cache /dev/nvme0n1p2 /mnt/var/cache
mount -o defaults,noatime,discard=async,compress-force=zstd,ssd,subvol=@games /dev/nvme0n1p2 /mnt/var/games
mount -o defaults,noatime,discard=async,compress-force=zstd,ssd,subvol=@usr_local /dev/nvme0n1p2 /mnt/usr/local
mount -o defaults,noatime,discard=async,compress-force=zstd,ssd,subvol=@libvirt /dev/nvme0n1p2 /mnt/var/lib/libvirt
mount -o defaults,noatime,discard=async,compress-force=zstd,ssd,subvol=@flatpak /dev/nvme0n1p2 /mnt/var/lib/flatpak
mount -o defaults,noatime,discard=async,compress-force=zstd,ssd,subvol=@opt /dev/nvme0n1p2 /mnt/opt
mount -o defaults,noatime,discard=async,compress-force=zstd,ssd,subvol=@snapshots /dev/nvme0n1p2 /mnt/.snapshots
mount /dev/nvme0n1p1 /mnt/boot/efi

# System Instalation
pacstrap /mnt base base-devel linux linux-headers linux-firmware intel-ucode zstd btrfs-progs vim
genfstab -U /mnt >> /mnt/etc/fstab

# Configuration System
arch-chroot /mnt
ln -sf /usr/share/zoneinfo/America/Sao_Paulo /etc/localtime
hwclock --systohc
sed -i '387s/.//' /etc/locale.gen
locale-gen
echo "LANG=pt_BR.UTF-8" >> /etc/locale.conf
echo "KEYMAP=br-abnt2" >> /etc/vconsole.conf
echo "archbtw" >> /etc/hostname
echo "127.0.0.1 localhost" >> /etc/hosts
echo "::1       localhost" >> /etc/hosts
echo "127.0.1.1 archbtw.localdomain archbtw" >> /etc/hosts
echo root:root | chpasswd

# Necessary Softwares (for me)
pacman -S grub grub-btrfs efibootmgr networkmanager wpa_supplicant dosfstools reflector avahi xdg-user-dirs xdg-utils nfs-utils inetutils dnsutils bluez bluez-utils alsa-utils pipewire pipewire-alsa pipewire-pulse pipewire-jack wirepumbler bash-completion acpi acpi_call sof-firmware os-prober ntfs-3g snapper 

# Grub install
grub-install --target=x86_64-efi --efi-directory=/boot/ --bootloader-id=GRUB
grub-mkconfig -o /boot/grub/grub.cfg

# Inicialize services
systemctl enable bluetooth
systemctl enable sshd
systemctl enable avahi-daemon
systemctl enable reflector.timer
systemctl enable fstrim.timer
systemctl enable acpid

# Add user
useradd -m -G sys,log,http,games,dbus,network,power,rfkill,users,storage,lp,input,audio,wheel santosbpm
echo santosbpm:santosbpm | chpasswd

echo "santosbpm ALL=(ALL) ALL" >> /etc/sudoers.d/santosbpm
