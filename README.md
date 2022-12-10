This script is a possible dark mode solution for KDE Plasma, working as an alternative to KDE Plasma's built-in 'activities' if you want to keep the windows when switch between dark and light modes.

This script contains the following changes to toggle between dark and light modes in KDE Plasma:

- GTK 2 / 3 theme
- GTK 4 (libadwaita) theme
- Kvantum theme
- Color scheme
- Icon theme
- Fcitx5 skin
- Wallpaper

To use this script, **edit these items first**. You can comment out unneeded items.  
You can get your current theme config with `get-current-theme-config.sh`.

### Dependencies

- `qt5-tools`

- Kvantum Manager

- Python & PyQt5

### Usage

`dark-mode-switch dark`: Switch to dark theme.  
`dark-mode-switch light`: Switch to light theme.    
`dark-mode-switch auto`: Switch theme automatically depends on current time (can be used in crontabs.).  

### Tips

Some slight changes are required to get this script to work with Wallpaper Engine for KDE, see `dark-mode-switch_wallpaperengine.sh`.
