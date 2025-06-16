#!/usr/bin/env bash
# shellcheck disable=SC2034

# PlayNix Arch Linux KDE Live CD Profile Definition
# Este archivo define las características principales de la ISO

# Información básica de la ISO
iso_name="playnix-arch-kde"
iso_label="PLAYNIX_$(date +%Y%m)"
iso_publisher="PlayNix Team"
iso_application="PlayNix Arch Linux KDE Live CD"
iso_version="$(date +%Y.%m.%d)"
install_dir="arch"
buildmodes=('iso')
bootmodes=('bios.syslinux.mbr' 'bios.syslinux.eltorito'
           'uefi-x64.systemd-boot.esp' 'uefi-x64.systemd-boot.eltorito')
arch="x86_64"
pacman_conf="pacman.conf"
airootfs_image_type="squashfs"

# Opciones de compresión del sistema de archivos
# xz proporciona mejor compresión pero es más lento
# zstd es más rápido pero menos compresión
airootfs_image_tool_options=('-comp' 'xz' '-Xbcj' 'x86' '-b' '1M' '-Xdict-size' '1M')

# Permisos de archivos específicos
file_permissions=(
  ["/etc/shadow"]="0:0:400"
  ["/root"]="0:0:750"
  ["/root/.automated_script.sh"]="0:0:755"
  ["/root/.gnupg"]="0:0:700"
  ["/usr/local/bin/choose-mirror"]="0:0:755"
  ["/usr/local/bin/Installation_guide"]="0:0:755"
  ["/usr/local/bin/livecd-sound"]="0:0:755"

  # PlayNix específicos
  ["/root/customize_airootfs.sh"]="0:0:755"
  ["/usr/local/bin/arch-installer"]="0:0:755"
  ["/usr/local/bin/playnix-live-setup.sh"]="0:0:755"

  # Archivos del usuario live
  ["/etc/skel"]="0:0:755"
  ["/etc/skel/.bashrc"]="0:0:644"
  ["/etc/skel/.bash_profile"]="0:0:644"
  ["/etc/skel/Desktop"]="0:0:755"
  ["/etc/skel/Desktop/arch-installer.desktop"]="0:0:755"
  ["/etc/skel/Desktop/gparted.desktop"]="0:0:755"

  # Archivos de root
  ["/root/Desktop"]="0:0:755"
  ["/root/Desktop/arch-installer.desktop"]="0:0:755"
  ["/root/Desktop/gparted.desktop"]="0:0:755"
)