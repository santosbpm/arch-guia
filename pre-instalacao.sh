#!/bin/bash

gdisk /dev/nvme0n1
gdisk /dev/sda

cryptsetup luksFormat /dev/nvme0n1p2
cryptsetup luksFormat /dev/sda1

cryptsetup luksOpen /dev/nvme0n1p2 root
cryptsetup luksOpen /dev/sda1 crypt0

mkfs.btrfs --csum xxhash /dev/mapper/root
mkfs.btrfs --csum xxhash /dev/mapper/crypt0

mkfs.fat -F 32 -n BOOT /dev/nvme0n1p1

mount /dev/mapper/root /mnt

btrfs subvolume create /mnt/@
btrfs subvolume create /mnt/@log
btrfs subvolume create /mnt/@cache
btrfs subvolume create /mnt/@flatpak
btrfs subvolume create /mnt/@libvirt
btrfs subvolume create /mnt/@containerd
btrfs subvolume create /mnt/@machines
btrfs subvolume create /mnt/@docker
btrfs subvolume create /mnt/@swap
btrfs subvolume create /mnt/@snapshots

chattr +C /mnt/@libvirt
chattr +C /mnt/@containerd
chattr +C /mnt/@machines
chattr +C /mnt/@docker
chattr +C /mnt/@swap

umount /mnt

mount -o defaults,noatime,compress-force=zstd,subvol=@ /dev/mapper/root /mnt

mkdir /mnt/efi
mkdir /mnt/home
mkdir /mnt/.snapshots
mkdir -p /mnt/var/{log,cache,swap}
mkdir -p /mnt/var/lib/{libvirt,containerd,docker,machines,flatpak}

mount -o defaults,noatime,compress-force=zstd,subvol=@home /dev/mapper/home-crypt /mnt/home

mount -o defaults,noatime,compress-force=zstd,subvol=@log /dev/mapper/root /mnt/var/log
mount -o defaults,noatime,compress-force=zstd,subvol=@cache /dev/mapper/root /mnt/var/cache
mount -o defaults,noatime,compress-force=zstd,subvol=@swap /dev/mapper/root /mnt/var/swap
mount -o defaults,noatime,compress-force=zstd,subvol=@libvirt /dev/mapper/root /mnt/var/lib/libvirt
mount -o defaults,noatime,compress-force=zstd,subvol=@machines /dev/mapper/root /mnt/var/lib/machines
mount -o defaults,noatime,compress-force=zstd,subvol=@docker /dev/mapper/root /mnt/var/lib/docker
mount -o defaults,noatime,compress-force=zstd,subvol=@containerd /dev/mapper/root /mnt/var/lib/containerd
mount -o defaults,noatime,compress-force=zstd,subvol=@flatpak /dev/mapper/root /mnt/var/lib/flatpak
mount -o defaults,noatime,compress-force=zstd,subvol=@snapshots /dev/mapper/root /mnt/.snapshots

mount /dev/nvme0n1p1 /mnt/efi

pacstrap /mnt linux linux-headers linux-firmware base base-devel intel-ucode btrfs-progs vim

cp -r ../arch-guide /mnt/root

arch-chroot /mnt
