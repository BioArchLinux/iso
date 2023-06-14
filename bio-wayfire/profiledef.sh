#!/usr/bin/env bash
# shellcheck disable=SC2034

iso_name="bioarchlinux-wayfire"
iso_label="ARCH_$(date +%Y%m)"
iso_publisher="BioArchLinux <https://bioarchlinux.org>"
iso_application="BioArchLinux Live/Rescue CD"
iso_version="$(date +%Y.%m.%d)"
install_dir="bioarch"
buildmodes=('iso')
bootmodes=('bios.syslinux.mbr' 'bios.syslinux.eltorito'
           'uefi-ia32.grub.esp' 'uefi-x64.grub.esp'
           'uefi-ia32.grub.eltorito' 'uefi-x64.grub.eltorito')
arch="x86_64"
pacman_conf="pacman.conf"
airootfs_image_type="squashfs"
airootfs_image_tool_options=('-comp' 'xz' '-Xbcj' 'x86' '-b' '1M' '-Xdict-size' '1M')
file_permissions=(
  ["/etc/shadow"]="0:0:400"
  ["/etc/gshadow"]="0:0:400"
  ["/usr/local/bin/Installation_guide"]="0:0:755"
  ["/usr/local/bin/livecd-sound"]="0:0:755"
)
