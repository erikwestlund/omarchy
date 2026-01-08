#!/bin/bash
# Set GTK color scheme based on darkman mode
# File dialogs and GTK apps will follow this setting
case "$1" in
    dark)
        gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
        gsettings set org.gnome.desktop.interface gtk-theme 'Adwaita-dark'
        ;;
    light)
        gsettings set org.gnome.desktop.interface color-scheme 'prefer-light'
        gsettings set org.gnome.desktop.interface gtk-theme 'Adwaita'
        ;;
esac
