#!/usr/bin/env bash

# PlayNix Arch Linux KDE Live CD Customization Script
# Este script personaliza el sistema live antes de crear la ISO

set -e -u

echo "🎮 Iniciando customización del sistema PlayNix Live..."

# Configurar locales
echo "📍 Configurando idiomas y locales..."
sed -i 's/#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen
sed -i 's/#es_ES.UTF-8 UTF-8/es_ES.UTF-8 UTF-8/' /etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" > /etc/locale.conf

# Configurar teclado
echo "⌨️  Configurando teclado español..."
echo "KEYMAP=es" > /etc/vconsole.conf

# Configurar timezone
echo "⏰ Configurando zona horaria..."
ln -sf /usr/share/zoneinfo/UTC /etc/localtime

# Crear usuario liveuser
echo "👤 Creando usuario del sistema live..."
useradd -m -G wheel,audio,video,storage,optical,network,power,users,sys -s /bin/bash liveuser

# Configurar contraseñas (sin contraseña)
echo "🔐 Configurando acceso sin contraseña..."
passwd -d liveuser
passwd -d root

# Configurar sudo sin contraseña
echo "🔑 Configurando sudo sin contraseña..."
echo "%wheel ALL=(ALL:ALL) NOPASSWD: ALL" >> /etc/sudoers
echo "liveuser ALL=(ALL:ALL) NOPASSWD: ALL" >> /etc/sudoers

# Habilitar servicios del sistema
echo "⚙️  Habilitando servicios del sistema..."
systemctl enable NetworkManager.service
systemctl enable sddm.service
systemctl enable systemd-timesyncd.service
systemctl enable systemd-resolved.service

# Configurar NetworkManager
echo "🌐 Configurando NetworkManager..."
mkdir -p /etc/NetworkManager/conf.d
cat > /etc/NetworkManager/conf.d/wifi-powersave-off.conf << EOF
[connection]
wifi.powersave = 2
EOF

# Configurar SDDM para autologin
echo "🖥️  Configurando SDDM para autologin..."
mkdir -p /etc/sddm.conf.d
cat > /etc/sddm.conf.d/autologin.conf << EOF
[Autologin]
User=liveuser
Session=plasma

[Theme]
Current=breeze

[General]
HaltCommand=/usr/bin/systemctl poweroff
RebootCommand=/usr/bin/systemctl reboot

[X11]
ServerPath=/usr/bin/X
SessionCommand=/usr/share/sddm/scripts/Xsession
SessionDir=/usr/share/xsessions
EOF

# Configurar hostname
echo "🏷️  Configurando hostname..."
echo "playnix-live" > /etc/hostname

# Configurar hosts
cat > /etc/hosts << EOF
127.0.0.1   localhost
::1         localhost
127.0.1.1   playnix-live.localdomain playnix-live
EOF

# Configurar mirrors de pacman
echo "📦 Configurando mirrors de pacman..."
cat > /etc/pacman.d/mirrorlist << EOF
##
## Arch Linux repository mirrorlist
## Configurado para PlayNix Live CD
##
Server = https://mirror.rackspace.com/archlinux/\$repo/os/\$arch
Server = https://mirror.leaseweb.net/archlinux/\$repo/os/\$arch
Server = https://mirrors.kernel.org/archlinux/\$repo/os/\$arch
Server = https://archlinux.mirror.wearetriple.com/\$repo/os/\$arch
Server = https://mirror.cyberbits.eu/archlinux/\$repo/os/\$arch
EOF

# Configurar bashrc para liveuser
echo "🐚 Configurando bashrc para usuario live..."
cat >> /home/liveuser/.bashrc << 'EOF'

# PlayNix Live System Configuration
export EDITOR=nano
export BROWSER=firefox
export TERMINAL=konsole

# Aliases útiles
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'
alias diff='diff --color=auto'
alias ip='ip -color=auto'

# Aliases de sistema
alias update='sudo pacman -Syu'
alias install='sudo pacman -S'
alias search='pacman -Ss'
alias remove='sudo pacman -R'
alias autoremove='sudo pacman -Rns $(pacman -Qtdq)'

# Aliases de red
alias myip='curl -s https://ipinfo.io/ip'
alias ports='netstat -tulanp'
alias listening='lsof -i -P -n | grep LISTEN'

# Funciones útiles
extract() {
    if [ -f $1 ] ; then
        case $1 in
            *.tar.bz2)   tar xjf $1     ;;
            *.tar.gz)    tar xzf $1     ;;
            *.bz2)       bunzip2 $1     ;;
            *.rar)       unrar x $1     ;;
            *.gz)        gunzip $1      ;;
            *.tar)       tar xf $1      ;;
            *.tbz2)      tar xjf $1     ;;
            *.tgz)       tar xzf $1     ;;
            *.zip)       unzip $1       ;;
            *.Z)         uncompress $1  ;;
            *.7z)        7z x $1        ;;
            *)           echo "'$1' no se puede extraer" ;;
        esac
    else
        echo "'$1' no es un archivo válido"
    fi
}

# Mensaje de bienvenida
clear
echo ""
echo "🎮 =============================================== 🎮"
echo "🎮    Bienvenido a PlayNix Arch Linux Live     🎮"
echo "🎮 =============================================== 🎮"
echo ""
echo "💻 Sistema: Arch Linux + KDE Plasma"
echo "👤 Usuario: liveuser (sin contraseña)"
echo "🔑 Sudo: Habilitado sin contraseña"
echo "🌐 Red: NetworkManager (WiFi disponible)"
echo ""
echo "🛠️  HERRAMIENTAS DISPONIBLES:"
echo "   • Instalador PlayNix (doble clic en el escritorio)"
echo "   • GParted (editor de particiones)"
echo "   • Firefox (navegador web)"
echo "   • Konsole (terminal)"
echo "   • Todas las herramientas de KDE"
echo ""
echo "📚 COMANDOS ÚTILES:"
echo "   • update        - Actualizar sistema"
echo "   • install <pkg> - Instalar paquete"
echo "   • myip          - Ver IP pública"
echo "   • extract <file>- Extraer archivos"
echo ""
echo "🚀 Para instalar PlayNix permanentemente:"
echo "   • Haz doble clic en 'Instalador PlayNix' del escritorio"
echo "   • O ejecuta: sudo arch-installer auto"
echo ""
echo "ℹ️  Para ayuda: arch-installer help"
echo ""

# Mostrar información del sistema
if command -v fastfetch &> /dev/null; then
    fastfetch
elif command -v neofetch &> /dev/null; then
    neofetch
else
    echo "💡 Sistema iniciado correctamente"
fi

echo ""
EOF

# Configurar entorno KDE para liveuser
echo "🎨 Configurando entorno KDE..."
mkdir -p /home/liveuser/.config
mkdir -p /home/liveuser/.local/share

# Configurar wallpaper y tema
mkdir -p /home/liveuser/.config/plasma-org.kde.plasma.desktop-appletsrc
cat > /home/liveuser/.config/kdeglobals << EOF
[General]
ColorScheme=Breeze

[Icons]
Theme=breeze

[KDE]
LookAndFeelPackage=org.kde.breeze.desktop
EOF

# Configurar permisos del directorio home
chown -R liveuser:liveuser /home/liveuser

# Crear servicio de configuración inicial
echo "🔧 Creando servicio de configuración inicial..."
cat > /etc/systemd/system/playnix-live-setup.service << EOF
[Unit]
Description=PlayNix Live CD Initial Setup
After=NetworkManager.service sddm.service
Wants=NetworkManager.service

[Service]
Type=oneshot
ExecStart=/usr/local/bin/playnix-live-setup.sh
RemainAfterExit=yes
User=root

[Install]
WantedBy=multi-user.target
EOF

# Script de configuración inicial
cat > /usr/local/bin/playnix-live-setup.sh << 'EOF'
#!/bin/bash

# PlayNix Live CD Setup Script
echo "🎮 Iniciando configuración inicial de PlayNix Live..."

# Actualizar mirrors si reflector está disponible
if command -v reflector &> /dev/null; then
    echo "📦 Actualizando mirrors de pacman..."
    reflector --country Spain,France,Germany,Netherlands \
              --age 6 --protocol https --sort rate \
              --save /etc/pacman.d/mirrorlist &
fi

# Detectar y configurar red WiFi automáticamente
echo "🌐 Configurando red automáticamente..."
nmcli device wifi rescan &>/dev/null || true

# Configurar hora automática
echo "⏰ Sincronizando hora..."
timedatectl set-ntp true &>/dev/null || true

# Configurar audio
echo "🔊 Configurando audio..."
systemctl --user --global enable pipewire.service &>/dev/null || true
systemctl --user --global enable pipewire-pulse.service &>/dev/null || true

echo "✅ Configuración inicial completada"
EOF

chmod +x /usr/local/bin/playnix-live-setup.sh
systemctl enable playnix-live-setup.service

# Configurar logrotate para evitar logs grandes
echo "📄 Configurando rotación de logs..."
cat > /etc/logrotate.d/playnix-live << EOF
/var/log/playnix-live.log {
    daily
    missingok
    rotate 3
    compress
    delaycompress
    notifempty
    create 644 root root
}
EOF

# Limpiar sistema y cachés
echo "🧹 Limpiando sistema..."
pacman -Scc --noconfirm
journalctl --vacuum-size=50M
rm -rf /var/cache/pacman/pkg/*
rm -rf /tmp/*
rm -rf /var/tmp/*
rm -rf /var/log/journal/*
rm -rf /root/.cache/*

# Configurar límites de journal
echo "📰 Configurando límites de journal..."
mkdir -p /etc/systemd/journald.conf.d
cat > /etc/systemd/journald.conf.d/size.conf << EOF
[Journal]
SystemMaxUse=100M
RuntimeMaxUse=50M
EOF

echo "🎉 Customización de PlayNix Live completada exitosamente!"
echo "🚀 El sistema está listo para crear la ISO."