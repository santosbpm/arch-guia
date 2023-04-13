#!/bin/bash

ln -sf /usr/share/zoneinfo/America/Sao_Paulo /etc/localtime
hwclock --systohc

sed -i  '/en_US_BR/,+1 s/^#//' /etc/locale.gen
# sed -i  '/pt_BR/,+1 s/^#//' /etc/locale.gen

locale-gen

echo "LANG=en_US.UTF-8" >> /etc/locale.conf
# echo "LANG=pt_BR.UTF-8" >> /etc/locale.conf

echo "KEYMAP=us" >> /etc/vconsole.conf
# echo "KEYMAP=br-abnt2" >> /etc/vconsole.conf

echo "archbtw" >> /etc/hostname
echo "127.0.0.1 localhost" >> /etc/hosts
echo "::1       localhost" >> /etc/hosts
echo "127.0.1.1 archbtw.localdomain archbtw" >> /etc/hosts

pacman -S networkmanager reflector acpid acpi snapper sbctl bash-completion xdg-user-dirs xdg-utils

systemctl enable acpid
systemctl enable NetworkManager

useradd -m -G log,http,games,dbus,network,power,rfkill,storage,input,audio,wheel santosbpm
echo "santosbpm ALL=(ALL) ALL" >> /etc/sudoers.d/santosbpm

passwd
passwd santosbpm

# ou senha pré-definida
# echo santosbpm:santosbpm | chpasswd
# echo root:root | chpasswd

echo "Veja no readme quais são os comandos deve ser inseridos e saia do usuário"
su santosbpm
# xdg-user-dirs-update
# mkdir -p ~/{.cache,Games,'VirtualBox VMs'}
# mkdir -p ~/.local/share/{libvirt,flatpak,docker}

mount -o defaults,noatime,compress-force=zstd,subvol=@games /dev/mapper/home-crypt /home/santosbpm/Games
mount -o defaults,noatime,compress-force=zstd,subvol=@VMs /dev/mapper/home-crypt /home/santosbpm/VirtualBox\ VMs
mount -o defaults,noatime,compress-force=zstd,subvol=@downloads /dev/mapper/home-crypt /home/santosbpm/Downloads
mount -o defaults,noatime,compress-force=zstd,subvol=@documents /dev/mapper/home-crypt /home/santosbpm/Documents
mount -o defaults,noatime,compress-force=zstd,subvol=@pictures /dev/mapper/home-crypt /home/santosbpm/Pictures
mount -o defaults,noatime,compress-force=zstd,subvol=@videos /dev/mapper/home-crypt /home/santosbpm/Videos
mount -o defaults,noatime,compress-force=zstd,subvol=@cache_home /dev/mapper/home-crypt /home/santosbpm/.cache
mount -o defaults,noatime,compress-force=zstd,subvol=@libvirt_home /dev/mapper/home-crypt /home/santosbpm/.local/share/libvirt
mount -o defaults,noatime,compress-force=zstd,subvol=@flatpak_home /dev/mapper/home-crypt /home/santosbpm/.local/share/flatpak
mount -o defaults,noatime,compress-force=zstd,subvol=@docker_home /dev/mapper/home-crypt /home/santosbpm/.local/share/docker

chown santosbpm:santosbpm -R /home/santosbpm/

modprobe zram
echo zstd > /sys/block/zram0/comp_algorithm
echo 2G > /sys/block/zram0/disksize
mkswap --label zram0 /dev/zram0
swapon --priority 100 /dev/zram0

btrfs filesystem mkswapfile --size 16g /var/swap/swapfile
swapon /var/swap/swapfile

exit

echo rd.luks.uuid=$(lsblk -o UUID /dev/nvme0n1p2 | tail -n 1) rd.luks.name=$(lsblk -o UUID /dev/nvme0n1p2 | tail -n 1)=root rd.luks.options=password-echo=no rootflags=subvol=@ resume=UUID=$(findmnt -no UUID -T /mnt/var/swap/swapfile) resume_offset=$(btrfs inspect-internal map-swapfile -r /mnt/var/swap/swapfile) zswap.enabled=0 rw quiet bgrt_disable nmi_watchdog=0 nowatchdog >> /mnt/etc/kernel/cmdline

echo "vm.swappiness = 10" > /mnt/etc/sysctl.d/99-swappiness.conf

echo 'home-crypt         UUID='$(lsblk -o UUID /dev/sda1 | head -n 2 | tail -n 1)'        none       luks' >> /mnt/etc/crypttab

genfstab -U /mnt >> /mnt/etc/fstab

arch-chroot /mnt
