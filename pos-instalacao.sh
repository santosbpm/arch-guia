#!/bin/bash

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
pacman -S grub grub-btrfs efibootmgr networkmanager reflector avahi xdg-user-dirs xdg-utils inetutils dnsutils bash-completion acpid acpi acpi_call sof-firmware snapper 

# Grub install
grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=GRUB
grub-mkconfig -o /boot/grub/grub.cfg

# Inicialize services
systemctl enable avahi-daemon
systemctl enable reflector.timer
systemctl enable acpid
systemctl enable NetworkManager

# Add user
useradd -m -G sys,log,http,games,dbus,network,power,rfkill,users,storage,lp,input,audio,wheel santosbpm
echo santosbpm:santosbpm | chpasswd

echo "santosbpm ALL=(ALL) ALL" >> /etc/sudoers.d/santosbpm

echo "REBOOT SYSTEM NOW"
