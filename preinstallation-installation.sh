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
btrfs subvolume create /mnt/@
btrfs subvolume create /mnt/@home
btrfs subvolume create /mnt/@root
btrfs subvolume create /mnt/@log
btrfs subvolume create /mnt/@cache
btrfs subvolume create /mnt/@games
btrfs subvolume create /mnt/@usr_local
btrfs subvolume create /mnt/@libvirt
btrfs subvolume create /mnt/@flatpak
btrfs subvolume create /mnt/@opt
btrfs subvolume create /mnt/@snapshots
chown root:games /mnt/@games

chattr +C /mnt/@libvirt
umount /mnt

mount -o defaults,noatime,discard=async,compress-force=zstd,ssd,subvol=@ /dev/nvme0n1p2 /mnt
mkdir -p /mnt/boot/efi
mkdir /mnt/home
mkdir /mnt/root
mkdir -p /mnt/var/log
mkdir /mnt/var/cache
mkdir /mnt/var/games
mkdir -p /mnt/usr/local
mkdir -p /mnt/var/lib/libvirt
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

# System Installation
pacstrap /mnt base base-devel linux linux-headers linux-firmware intel-ucode zstd btrfs-progs vim
genfstab -U /mnt >> /mnt/etc/fstab

# Configuration System
echo '##### Run systemconfiguration.sh #####' 
arch-chroot /mnt

