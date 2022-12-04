## Possible dark mode solution for KDE Plasma

This script contains the following changes to toggle between dark and light modes in KDE Plasma:

- GTK 2 / 3 theme
- GTK 4 (libadwaita) theme
- Kvantum theme
- Color scheme
- Icon theme
- Fcitx5 skin
- Wallpaper

To use this script, **edit these items first**. You can comment out unneeded items.

### Dependencies

- `qt5-tools`

- `glib2`
- Kvantum Manager
- Python & PyQt5

### Tips

Some slight changes are required to get this script to work with Wallpaper Engine for KDE, see `dark-mode-switch_wallpaperengine.sh`.
