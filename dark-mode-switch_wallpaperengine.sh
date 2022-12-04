#!/bin/bash

# By YidaozhanYa

LIGHT_KVANTUM_THEME="Fluent-round"  # Light Kvantum theme
DARK_KVANTUM_THEME="Fluent-roundDark"  # Dark Kvantum theme

LIGHT_GTK_THEME="Fluent-round-Light"  # Light GTK2/3 theme
DARK_GTK_THEME="Fluent-round-Dark"  # Dark GTK2/3 theme

LIGHT_GTK4_THEME="Fluent-round-Light"  # Light GTK4 theme
DARK_GTK4_THEME="Fluent-round-Dark"  # Dark GTK4 theme

LIGHT_COLOR_SCHEME="FluentLight"  # Light color scheme
DARK_COLOR_SCHEME="FluentDark"  # Dark color scheme

LIGHT_ICON_THEME="Win10Sur"   # Light icon theme
DARK_ICON_THEME="Win10Sur-dark"  # Dark icon theme

LIGHT_FCITX5_THEME="breeze"  # Light fcitx5 skin
DARK_FCITX5_THEME="plasma"  # Dark fcitx5 skin

LIGHT_WALLPAPER="file:$HOME/.local/share/Steam/steamapps/workshop/content/431960/2239430876/原神风景-wallpaper.mp4+video"  # Light wallpaper source
LIGHT_WALLPAPER_ID="2239430876"
DARK_WALLPAPER="file:$HOME/.local/share/Steam/steamapps/workshop/content/431960/2301901996/scene.json+scene"  # Dark wallpaper source
DARK_WALLPAPER_ID="2301901996"

if [ -z "$XDG_CONFIG_HOME" ]; then XDG_CONFIG_HOME="$HOME/.config"; fi

function switch_wallpaper_engine() {
    qdbus org.kde.plasmashell /PlasmaShell "org.kde.PlasmaShell.evaluateScript" '
        var allDesktops = desktops();
        for (i=0;i<allDesktops.length;i++) {{
            d = allDesktops[i];
            d.wallpaperPlugin = "com.github.casout.wallpaperEngineKde";
            d.currentConfigGroup = Array("Wallpaper",
                                        "com.github.casout.wallpaperEngineKde",
                                        "General");
            d.writeConfig("WallpaperSource", "'${1}'");
            d.writeConfig("WallpaperWorkShopId", "'${2}'");
        }}
    '  # Switch wallpaper
}

function dark_theme() {
    switch_wallpaper_engine "$DARK_WALLPAPER" "$DARK_WALLPAPER_ID"
    plasma-apply-colorscheme "$DARK_COLOR_SCHEME"
    /usr/lib/plasma-changeicons "$DARK_ICON_THEME"
    gsettings set org.gnome.desktop.interface "gtk-theme" "$DARK_GTK_THEME"
    gsettings set org.gnome.desktop.interface "color-scheme" "prefer-dark"
    kvantummanager --set "$DARK_KVANTUM_THEME"
    kwriteconfig5 --file "$XDG_CONFIG_HOME/fcitx5/conf/classicui.conf" --key "Theme" --group "<default>" "$DARK_FCITX5_THEME"
    cp "$HOME/.themes/$DARK_GTK4_THEME/gtk-4.0/gtk.css" "$XDG_CONFIG_HOME/gtk-4.0/gtk.css"
}

function light_theme() {
    switch_wallpaper_engine "$LIGHT_WALLPAPER" "$LIGHT_WALLPAPER_ID"
    plasma-apply-colorscheme "$LIGHT_COLOR_SCHEME"
    /usr/lib/plasma-changeicons "$LIGHT_ICON_THEME"
    gsettings set org.gnome.desktop.interface "gtk-theme" "$LIGHT_GTK_THEME"
    gsettings set org.gnome.desktop.interface "color-scheme" "prefer-light"
    kvantummanager --set "$LIGHT_KVANTUM_THEME"
    kwriteconfig5 --file "$XDG_CONFIG_HOME/fcitx5/conf/classicui.conf" --key "Theme" --group "<default>" "$LIGHT_FCITX5_THEME"
    cp "$HOME/.themes/$LIGHT_GTK4_THEME/gtk-4.0/gtk.css" "$XDG_CONFIG_HOME/gtk-4.0/gtk.css"
}

function finalize() {
    python -c 'from PyQt5 import QtDBus as qd; StyleChanged = 2; SETTINGS_STYLE = 7; message: qd.QDBusMessage = qd.QDBusMessage.createSignal("/KGlobalSettings", "org.kde.KGlobalSettings","notifyChange"); message.setArguments({StyleChanged, SETTINGS_STYLE}); qd.QDBusConnection.sessionBus().send(message)'  # Reload Qt widgets style
    qdbus org.kde.KWin /KWin "reconfigure"  # Reload KWin
    # latte-dock --replace &  # Reload Latte Dock
    qdbus org.fcitx.Fcitx5 /controller "org.fcitx.Fcitx.Controller1.ReloadAddonConfig" "classicui"  # Reload fcitx5 skin
}

if [ "$1" == "dark" ]; then dark_theme; finalize; exit; fi
if [ "$1" == "light" ]; then light_theme; finalize; exit; fi

CURRENT_KVANTUM_THEME="$(kreadconfig5 --group "General" --file "$XDG_CONFIG_HOME/Kvantum/kvantum.kvconfig" --key "theme")"

if [ "$CURRENT_KVANTUM_THEME" == "$LIGHT_KVANTUM_THEME" ]; then
    dark_theme
else
    light_theme
fi

finalize

