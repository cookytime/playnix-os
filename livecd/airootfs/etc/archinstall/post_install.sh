#!/usr/bin/env bash

sddmConf="/usr/lib/sddm/sddm.conf.d/default.conf"

if [ -f /etc/sddm.conf.d/kde_settings.conf ]; then
    sddmConf="/etc/sddm.conf.d/kde_settings.conf"
fi

#Breeze login theme
mkdir -p /etc/sddm.conf.d
sudo echo -e "[Autologin]\Relogin=true\User=playnix\n[Theme]\nCurrent=breeze" > $sddmConf

#Dark Breeze theme
kwriteconfig5 --file "/home/playnix/.config/kdeglobals" --group "KDE" --key "LookAndFeelPackage" "org.kde.breezedark.desktop"

#App launcher icon + Desktop BG
icon_path="/etc/archinstall/icon.png"
bg_path="/etc/archinstall/desktop.png"
applet_file="/home/playnix/.config/plasma-org.kde.plasma.desktop-appletsrc"

cp "$applet_file" "$applet_file.bak" || true

sed -i "/plugin=org.kde.plasma.kickoff/,/^\[/{s|^icon=.*$|icon=$icon_path|}" "$applet_file"
sed -i "/plugin=org.kde.plasma.kicker/,/^\[/{s|^icon=.*$|icon=$icon_path|}" "$applet_file"

if ! grep -q "icon=" "$applet_file"; then
    sed -i "/plugin=org.kde.plasma.kickoff/a icon=$icon_path" "$applet_file"
    sed -i "/plugin=org.kde.plasma.kicker/a icon=$icon_path" "$applet_file"
fi

containment_id=$(awk -F'[][]' '/\[Containments\][0-9]+\]/{id=$2} /\[Containments\][0-9]+\]\[Wallpaper\]/,/\[/{if($0~"plugin=org.kde.image"){print id; exit}}' "$applet_file")

if [ -n "$containment_id" ]; then
  sed -i "/\\[Containments\\]\\[$containment_id\\]\\[Wallpaper\\]\\[org.kde.image\\]\\[General\\]/,/^\\[/ s|^Image=.*$|Image=file://$bg_path|" "$applet_file"
  grep -q "Image=file://$bg_path" "$applet_file" || \
    sed -i "/\\[Containments\\]\\[$containment_id\\]\\[Wallpaper\\]\\[org.kde.image\\]\\[General\\]/ a Image=file://$bg_path" "$applet_file"
else
  echo "No desktop containment found; wallpaper not set."
fi

chown "playnix:playnix" "$applet_file"

# yay
su - playnix -c '
  cd /tmp
  git clone https://aur.archlinux.org/yay.git
  cd yay
  makepkg -si --noconfirm
  cd /
  rm -rf /tmp/yay
  yay -S --noconfirm plymouth-theme-sweet-arch-git
'

plymouth-set-default-theme -R sweet-arch

#Desktop shortcuts
mkdir -p "/home/playnix/Desktop"
cp /etc/archinstall/*.desktop /home/playnix/Desktop/
chmod +x /home/playnix/Desktop/*.desktop