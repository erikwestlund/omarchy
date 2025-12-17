#!/bin/bash
# Set GTK color scheme based on darkman mode
case "$1" in
    dark)
        gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
        ;;
    light)
        gsettings set org.gnome.desktop.interface color-scheme 'prefer-light'
        ;;
esac
