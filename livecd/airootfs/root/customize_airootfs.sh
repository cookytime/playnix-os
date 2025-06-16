#!/usr/bin/env bash
set -e -u

echo "Iniciando customización..."

# Locale
sed -i "s/#en_US.UTF-8/en_US.UTF-8/" /etc/locale.gen
sed -i "s/#es_ES.UTF-8/es_ES.UTF-8/" /etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" > /etc/locale.conf
echo "KEYMAP=es" > /etc/vconsole.conf

# Timezone
ln -sf /usr/share/zoneinfo/UTC /etc/localtime

# Usuario
useradd -m -G wheel,audio,video,storage,network -s /bin/bash liveuser
passwd -d liveuser
passwd -d root
echo "%wheel ALL=(ALL:ALL) NOPASSWD: ALL" >> /etc/sudoers

# Servicios
systemctl enable NetworkManager.service
systemctl enable sddm.service
systemctl enable livecd-loading.service

# SDDM autologin
cat > /etc/sddm.conf.d/autologin.conf << EOF
[Autologin]
User=liveuser
Session=plasma
[Theme]
Current=breeze
EOF

# Hostname
echo "archiso-kde" > /etc/hostname

# Bashrc con información de bienvenida
cat >> /home/liveuser/.bashrc << EOF
alias ll="ls -la"
clear
echo -e "\033[1;34m=== 🐧 Arch Linux KDE Live CD ===\033[0m"
echo -e "\033[1;32mBienvenido al sistema Live de Arch Linux con KDE\033[0m"
echo -e "\033[0;36mUsuario actual: liveuser (sin contraseña)\033[0m"
echo -e "\033[0;36mPara instalar: Ejecuta el instalador desde el escritorio\033[0m"
echo ""
EOF

chown -R liveuser:liveuser /home/liveuser

# Configurar Plymouth para splash screen
if command -v plymouth-set-default-theme &> /dev/null; then
  plymouth-set-default-theme bgrt
fi

# Limpiar cache de pacman
pacman -Scc --noconfirm
