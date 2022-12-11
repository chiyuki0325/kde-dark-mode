#!/bin/bash

# By YidaozhanYa

# environment variables for running in cron
export DISPLAY=:0
export QT_QPA_PLATFORM=xcb
export DESKTOP_SESSION=plasma
export KDE_SESSION_UID=1000
export XDG_CURRENT_DESKTOP=KDE
export XDG_RUNTIME_DIR=/run/user/1000
export XDG_SEAT=seat0
export XDG_SEAT_PATH=/org/freedesktop/DisplayManager/Seat0
export XDG_SESSION_CLASS=user
export XDG_SESSION_DESKTOP=KDE
export XDG_SESSION_ID=1
export XDG_SESSION_PATH=/org/freedesktop/DisplayManager/Session0
export XDG_SESSION_TYPE=x11

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

LIGHT_WALLPAPER="file:///usr/share/wallpapers/Altai/"  # Light wallpaper source
DARK_WALLPAPER="file:///usr/share/wallpapers/Next/"  # Dark wallpaper source

DAY="6"  # The hour the day begins
NIGHT="22"  # The hour the night begins

if [ -z "$XDG_CONFIG_HOME" ]; then XDG_CONFIG_HOME="$HOME/.config"; fi

function switch_wallpaper() {
    qdbus org.kde.plasmashell /PlasmaShell "org.kde.PlasmaShell.evaluateScript" '
        var allDesktops = desktops();
        for (i=0;i<allDesktops.length;i++) {{
            d = allDesktops[i];
            d.wallpaperPlugin = "org.kde.image";
            d.currentConfigGroup = Array("Wallpaper",
                                        "org.kde.image",
                                        "General");
            d.writeConfig("Image", "'${1}'")
        }}
    '  # Switch wallpaper
}

function dark_theme() {
    rm -rf "$XDG_CONFIG_HOME/gtk-4.0/"*".css"
    switch_wallpaper "$DARK_WALLPAPER"
    plasma-apply-colorscheme "$DARK_COLOR_SCHEME"
    /usr/lib/plasma-changeicons "$DARK_ICON_THEME"
    gsettings set org.gnome.desktop.interface "gtk-theme" "$DARK_GTK_THEME"
    gsettings set org.gnome.desktop.interface "color-scheme" "prefer-dark"
    kvantummanager --set "$DARK_KVANTUM_THEME"
    kwriteconfig5 --file "$XDG_CONFIG_HOME/fcitx5/conf/classicui.conf" --key "Theme" --group "<default>" "$DARK_FCITX5_THEME"
    cp -r "$HOME/.themes/$DARK_GTK4_THEME/gtk-4.0" "$XDG_CONFIG_HOME"
}

function light_theme() {
    rm -rf "$XDG_CONFIG_HOME/gtk-4.0/"*".css"
    switch_wallpaper "$LIGHT_WALLPAPER"
    plasma-apply-colorscheme "$LIGHT_COLOR_SCHEME"
    /usr/lib/plasma-changeicons "$LIGHT_ICON_THEME"
    gsettings set org.gnome.desktop.interface "gtk-theme" "$LIGHT_GTK_THEME"
    gsettings set org.gnome.desktop.interface "color-scheme" "prefer-light"
    kvantummanager --set "$LIGHT_KVANTUM_THEME"
    kwriteconfig5 --file "$XDG_CONFIG_HOME/fcitx5/conf/classicui.conf" --key "Theme" --group "<default>" "$LIGHT_FCITX5_THEME"
    cp -r "$HOME/.themes/$LIGHT_GTK4_THEME/gtk-4.0" "$XDG_CONFIG_HOME"
}

function finalize() {
    python -c 'from PyQt5 import QtDBus as qd; StyleChanged = 2; SETTINGS_STYLE = 7; message: qd.QDBusMessage = qd.QDBusMessage.createSignal("/KGlobalSettings", "org.kde.KGlobalSettings","notifyChange"); message.setArguments({StyleChanged, SETTINGS_STYLE}); qd.QDBusConnection.sessionBus().send(message)'  # Reload Qt widgets style
    qdbus org.kde.KWin /KWin "reconfigure"  # Reload KWin
    # latte-dock --replace &  # Reload Latte Dock
    qdbus org.fcitx.Fcitx5 /controller "org.fcitx.Fcitx.Controller1.ReloadAddonConfig" "classicui"  # Reload fcitx5 skin
}

if [[ "$1" == "help" ||  "$1" == "-h" || "$1" == "--help" ]]; then
    echo 'Usage: dark-mode-switch [dark light auto]'
    echo 'By YidaozhanYa'
fi

if [ "$1" == "dark" ]; then dark_theme; finalize; exit; fi
if [ "$1" == "light" ]; then light_theme; finalize; exit; fi

CURRENT_KVANTUM_THEME="$(kreadconfig5 --group "General" --file "$XDG_CONFIG_HOME/Kvantum/kvantum.kvconfig" --key "theme")"

if [ "$1" == "auto" ]; then
    CURRENT_HOUR="$(date +%_H | sed 's# ##g')"
    if [[ "$CURRENT_HOUR" -ge "$DAY" && "$CURRENT_HOUR" -lt "$NIGHT" ]]; then
        if [ "$CURRENT_KVANTUM_THEME" != "$LIGHT_KVANTUM_THEME" ]; then light_theme; finalize; fi
    else
        if [ "$CURRENT_KVANTUM_THEME" != "$DARK_KVANTUM_THEME" ]; then dark_theme; finalize; fi
    fi
    exit
fi

if [ "$CURRENT_KVANTUM_THEME" == "$LIGHT_KVANTUM_THEME" ]; then
    dark_theme
else
    light_theme
fi

finalize

