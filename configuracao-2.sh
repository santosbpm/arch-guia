#!/bin/bash

vim /etc/mkinitcpio.conf

vim /etc/mkinitcpio.d/linux.preset

mkdir -p esp/EFI/Linux
mkinitcpio -p linux

bootctl install

sbctl status

sbctl create-keys

sbctl enroll-keys -m
# sbctl enroll-keys

sbctl status

sbctl verify


sbctl sing -s /efi/EFI/BOOT/BOOTX64.EFI
sbctl sing -s /efi/EFI/Linux/arch-linux-fallback.efi
sbctl sing -s /efi/EFI/Linux/arch-linux.efi
sbctl sing -s /efi/EFI/systemd/systemd-bootx64.efi

cp ../arch-guide /home/santosbpm/
chown santosbpm:santosbpm -R /home/santosbpm/arch-guide

echo "exit umount reboot"
