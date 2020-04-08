#!/bin/sh

sgdisk --clear /dev/sda
sgdisk --new 1:0:+512M --typecode 1:ef00 --change-name 1:"boot" /dev/sda
sgdisk --new 2:0:+8G -t 2:8200 -c 2:"swap" /dev/sda
sgdisk --new 3:0:+40G -t 3:8304 -c 3:"root" /dev/sda
sgdisk --new 4:0:+52G -t 4:8302 -c 4:"home" /dev/sda
mkfs.fat -F 32 -n boot /dev/sda1
mkswap /dev/sda2
mkswapon
mkfs.ext4 -L root /dev/sda3
mkfs.ext4 -L home /dev/sda4
mount /dev/disk/by-label/root /mnt/
mkdir -p /mnt/boot
mkdir -p /mnt/home
mount /dev/disk/by-label/boot /mnt/boot
mount /dev/disk/by-label/home /mnt/home

nixos-generate-config --root /mnt
cp machine/base/configuration.nix /mnt/etc/nixos
cp machine/base/systemd-networkd.nix /mnt/etc/nixos
nixos-install --root /mnt
