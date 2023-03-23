# BioArchLinux ISO

![](https://raw.githubusercontent.com/BioArchLinux/iso/master/screenshot.png)

## Download

Download [iso image file](https://repo.bioarchlinux.org/iso) from [any mirror](https://raw.githubusercontent.com/BioArchLinux/mirror/main/mirrorlist.bio) of BioArchLinux.

## Release

This iso is released monthly and built by mkarchiso.

# Installation guide

## Pre-installation

### Partition the disks

Check the partitions, usually, you need one boot partition and one / partition.

```
# fdsik -l
```

If you want to create partitions use

```
# fdisk /dev/the_disk_to_be_partitioned
```

### Format partitions

Following commands format the boot partition as fas, the root partition as ext4.

```
# mkfs.ext4 /dev/root_partition
# mkfs.fas /dev/boot_partition
```

### Mount

```
# mount /dev/root_partition /mnt
# mount --mkdir /dev/boot_partition /mnt/boot
```

## Installation

### Select the mirrors

you can edit `/etc/pacman.d/mirrorlist` and `/etc/pacman.d/mirrorlist.bio`, and put the mirror you want at the top of the file.

### Install essential packages

The example commands will let you use the Linux kernel, you can replace it with other kernels.

```
# pacstrap /mnt base-bio linux linux-firmware
```

### pacman.conf

You can use the `pacman.conf` from live cd, or you should manually add `bioarchlinux` repo to `pacman.conf`

```
# cp /etc/pacman.conf /mnt/etc/pacman.conf
```


## Configure the system, Reboot & Post-installation

You can view [archlinux wiki](https://wiki.archlinux.org/title/Installation_guide), totally the same as Arch Linux.

