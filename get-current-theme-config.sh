#!/bin/bash

# By YidaozhanYa

export LANGUAGE=en_US.UTF-8
export LC_ALL=en_US.UTF-8

if [ "$(gsettings get org.gnome.desktop.interface color-scheme)" == "'prefer-dark'" ]; then
    echo "You are in dark theme."
else
    echo "You are in light theme."
fi

echo ''
echo "- Kvantum theme: '$(kreadconfig5 --group "General" --file "$XDG_CONFIG_HOME/Kvantum/kvantum.kvconfig" --key "theme")'"
echo "- GTK theme: $(gsettings get org.gnome.desktop.interface gtk-theme)"
echo "- Color scheme: '$(plasma-apply-colorscheme --list-schemes 2>/dev/null | grep 'current color scheme' | awk -F'*' '{print $2}' | awk -F'(' '{print $1}' | sed "s# ##g")'"
echo "- Icon theme: $(gsettings get org.gnome.desktop.interface "icon-theme")"
echo "- Fcitx5 skin: '$(kreadconfig5 --file "$XDG_CONFIG_HOME/fcitx5/conf/classicui.conf" --key "Theme" --group "<default>")'"

qdbus org.kde.plasmashell /PlasmaShell "org.kde.PlasmaShell.evaluateScript" '
    var allDesktops = desktops();
    for (i=0; i<allDesktops.length ;i++) {
        d = allDesktops[i];
        if (d.wallpaperPlugin == "org.kde.image") {
            d.currentConfigGroup = Array("Wallpaper", "org.kde.image", "General");
            print("- Desktop " + i + " wallpaper plugin: Image\n  Wallpaper source: \u0027" + d.readConfig("Image") + "\u0027");
        } else if (d.wallpaperPlugin == "com.github.casout.wallpaperEngineKde") {
            d.currentConfigGroup = Array("Wallpaper", "com.github.casout.wallpaperEngineKde", "General");
            print("- Desktop " + i + " wallpaper plugin: Wallpaper Engine for KDE\n  Wallpaper source: \u0027" + d.readConfig("WallpaperSource") + "\u0027\n  Wallpaper Workshop ID: \u0027" + d.readConfig("WallpaperWorkShopId") + "\u0027");
        }
    }
'
