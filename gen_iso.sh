#!/bin/bash
# Run
docker run  -itd --privileged --name bio bioarchlinux/bioarchlinux /bin/bash
# System
docker exec -it bio sh -c "ln -sf /usr/share/zoneinfo/GMT /etc/localtime"
docker exec -it bio sh -c "pacman -Syu --noconfirm"
docker exec -it bio sh -c "pacman -S archiso --noconfirm"
# Use mkarchiso
docker cp bio/ bio:/root/
docker exec -it bio sh -c "cd /root/bio &&  mkarchiso -C pacman.conf -v ."
docker cp bio:/root/bio/out/bioarchlinux-$(date "+%Y.%m.%d")-x86_64.iso .
# Clean system
docker stop bio
docker rm bio
docker rmi --force $(docker images -q)
# GPG Sign
gpg --output  bioarchlinux-$(date "+%Y.%m.%d")-x86_64.iso.sig --sign bioarchlinux-$(date "+%Y.%m.%d")-x86_64.iso
# Sum sign
for bin in $(pacman -Ql coreutils | grep 'sum$' | sed 's/\// /g' | awk '{print $4}')
do
	$bin bioarchlinux-$(date "+%Y.%m.%d")-x86_64.iso > bioarchlinux-$(date "+%Y.%m.%d")-x86_64.iso.$bin
done
# Remove
rm /usr/share/lilac/Repo/iso/*
# Move
mv bioarchlinux-$(date "+%Y.%m.%d")-x86_64.iso* /usr/share/lilac/Repo/iso


