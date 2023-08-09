#!/bin/bash

# sexy ascii art
echo "sofarch-installer.ascii"

# options
echo -e "\n\n"
lsblk -p
echo -en "\nSelect a device: " && read -irn device
echo -n "Set Hostname: " && read -irn hostname
echo -n "Set Username: " && read -irn username
echo -n "Set Password: " && read -irn password

boot="${device}p1"
swap="${device}p2"
root="${device}p3"

# stuff to make pacman faster
sed -i "s/#Color/Color" /etc/pacman.conf
sed -i "s/#ParallelDownloads = 5/ParallelDownloads = 25" /etc/pacman.conf

# idk fancy weird shit
echo -en "\e[?25l\nInstalling Arch Linux" && sleep 0.5
echo -n "." && sleep 0.5
echo -n "." && sleep 0.5
echo -n "." && sleep 1 && clear

# fuck yeah installation time
timedatectl && echo ""

# scary device partitioning shit
parted "$device" mklabel gpt
parted "$device" mkpart primary fat32 1MiB 300MiB
parted "$device" mkpart linux-swap 301Mib 4000MiB
parted "$device" mkpart primary ext4 4001MiB 100%
parted "$device" set 1 boot on
parted "$device" set 2 swap on
echo ""

# wiping all the gay furry porn off the drives
mkfs.fat -F 32 "$boot"
mkswap "$swap"
mkfs.ext4 "$root" && echo ""

# uh-oh... partition sex
mount "$root" /mnt
mount --mkdir "$boot" /mnt/boot
swapon "$swap" && echo ""

# FedEx stuff or something... idk i don't mess with packages
pacstrap -K /mnt base basedevel linux linux-firmware

# more drive stuff smh
genfstab -U /mnt >> /mnt/etc/fstab

# variables
export hostname
export username
export password

# changing root B)
arch-chroot /mnt /bin/bash <<EOF
sed -i "s/#Color/Color" /etc/pacman.conf
sed -i "s/#ParallelDownloads = 5/ParallelDownloads = 25" /etc/pacman.conf

pacman -Syu sudo --noconfirm

ln -sf /usr/share/zoneinfo/America/Chicago /etc/localtime
hwclock --systohc

sed -i s/#en_US/en_US/g /etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" > /etc/locale.conf

echo "$hostname" > /etc/hostname
useradd -m -G wheel -s /bin/bash "$username"
echo -e "$password\n$password\n" | passwd "$username"


pacman -S neofetch --noconfirm
clear && neofetch && sleep 1 && echo -n "mmmm.... " && sleep 2 && echo "sexy..." && sleep 1
EOF

echo -e "\e[?25h"
