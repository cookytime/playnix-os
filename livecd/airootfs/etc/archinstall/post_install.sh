#!/usr/bin/env bash
set -euxo pipefail

USER="playnix"
HOME="/home/$USER"
SDDM_CONF="/etc/sddm.conf.d/autologin.conf"
ICON_PATH="/etc/archinstall/icon.png"
BG_PATH="/etc/archinstall/desktop.png"
APPLET_FILE="$HOME/.config/plasma-org.kde.plasma.desktop-appletsrc"

# Breeze login theme
mkdir -p /etc/sddm.conf.d
touch "$SDDM_CONF"
cat > "$SDDM_CONF" <<EOF
[Autologin]
Relogin=true
User=$USER
[Theme]
Current=breeze
EOF

# Dark Breeze theme

echo "[KDE]" >> "$HOME/.config/kdeglobals"
echo "LookAndFeelPackage=org.kde.breezedark.desktop" >> "$HOME/.config/kdeglobals"

# App launcher icon + Desktop BG
if [ -f "$APPLET_FILE" ]; then
  cp "$APPLET_FILE" "$APPLET_FILE.bak" || true
  sed -i "/plugin=org.kde.plasma.kickoff/,/^\[/{s|^icon=.*$|icon=$ICON_PATH|}" "$APPLET_FILE"
  sed -i "/plugin=org.kde.plasma.kicker/,/^\[/{s|^icon=.*$|icon=$ICON_PATH|}" "$APPLET_FILE"
  if ! grep -q "icon=" "$APPLET_FILE"; then
      sed -i "/plugin=org.kde.plasma.kickoff/a icon=$ICON_PATH" "$APPLET_FILE"
      sed -i "/plugin=org.kde.plasma.kicker/a icon=$ICON_PATH" "$APPLET_FILE"
  fi
  CONTAINMENT_ID=$(awk -F'[][]' '/\[Containments\][0-9]+\]/{id=$2} /\[Containments\][0-9]+\]\[Wallpaper\]/,/\[/{if($0~"plugin=org.kde.image"){print id; exit}}' "$APPLET_FILE")
  if [ -n "$CONTAINMENT_ID" ]; then
    sed -i "/\\[Containments\\]\\[$CONTAINMENT_ID\\]\\[Wallpaper\\]\\[org.kde.image\\]\\[General\\]/,/^\\[/ s|^Image=.*$|Image=file://$BG_PATH|" "$APPLET_FILE"
    grep -q "Image=file://$BG_PATH" "$APPLET_FILE" || \
      sed -i "/\\[Containments\\]\\[$CONTAINMENT_ID\\]\\[Wallpaper\\]\\[org.kde.image\\]\\[General\\]/ a Image=file://$BG_PATH" "$APPLET_FILE"
  else
    echo "No desktop containment found; wallpaper not set."
  fi
  chown "$USER:$USER" "$APPLET_FILE"
else
  echo "No applet file found; skipping desktop customization."
fi

echo "$USER ALL=(ALL) NOPASSWD: /usr/bin/pacman" >> /etc/sudoers.d/99-pacman-nopasswd

# yay (requiere tener go, git y base-devel instalados)
su - "$USER" -c '
  cd /tmp
  git clone https://aur.archlinux.org/yay.git
  cd yay
  makepkg -si --noconfirm || true
  cd /
  rm -rf /tmp/yay
  yay -S --noconfirm plymouth-theme-sweet-arch-git || true
'

rm -rf /etc/sudoers.d/99-pacman-nopasswd

plymouth-set-default-theme -R sweet-arch || true

# Desktop shortcuts
mkdir -p "$HOME/Desktop"
cp /etc/archinstall/*.desktop "$HOME/Desktop/" || true
chmod +x "$HOME/Desktop/"*.desktop || true

# Permisos finales
chown -R "$USER:$USER" "$HOME"

exit 0