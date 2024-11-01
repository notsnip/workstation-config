#!/bin/bash

printf " Choose your wallpaper.
1. Ash and Pikachu
2. Son Goku
3. Gon and Kilua
4. Your Name Sceneryss
5. Luffy Gear V
6. Miyamoto Musashi
7. Vinland Saga \n"
read -r -p  "Enter the number of the wallpaper you want to use: " id

gsettings set org.gnome.desktop.background picture-uri "file://$current_directory/wallpapers/$id.jpg"
