#!/usr/bin/env bash

# Get the absolute path of the script's directory
current_directory=$(dirname "$(realpath "$0")")

ask_user_to_execute_command() {
    if [ "$#" = 3 ]; then
        QUESTION=$1
        COMMAND=$2
        NO_MESSAGE=$3
        while true; do
            read -r -p "$QUESTION [Y/n] " yn
            case $yn in
            [Yy]*)
                $COMMAND
                break
                ;;
            "")
                $COMMAND
                break
                ;; # Default choice: execute command
            [Nn]*)
                echo "$NO_MESSAGE"
                break
                ;;
            *) echo "Please answer yes or no." ;;
            esac
        done
    else
        echo "Call me as 'question' 'command to execute' 'Message if no is chosen'"
    fi
}

say() {
    echo "$1"
    echo ""  # Add a gap after the message
}

install_system_programs() {
    # Install gnome tweaks, grub-customizer, and flatpak
    sudo add-apt-repository ppa:danielrichter2007/grub-customizer
    sudo apt update
    sudo apt upgrade
    sudo apt install -y gnome-tweaks gnome-shell-extension-manager grub-customizer neofetch flatpak curl
    flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.0/install.sh | bash # Install nvm
    say "Rebooting..."
    sleep 3
    reboot
}

general_theming() {
    printf "Choose your wallpaper.\n1. Ash and Pikachu\n2. Son Goku\n3. Gon and Kilua\n4. Your Name Sceneryss\n5. Luffy Gear V\n6. Miyamoto Musashi\n7. Vinland Saga\n"
    read -r -p "Enter the number of the wallpaper you want to use: " id
    gsettings set org.gnome.desktop.background picture-uri "file://$current_directory/wallpapers/$id.jpg"

    # Installing Fonts
    mkdir -p ~/.fonts
    cp "$current_directory/fonts/SF-Pro-Display-Regular.otf" ~/.fonts
    cp "$current_directory/fonts/SF-Pro-Display-Bold.otf" ~/.fonts

    # Installing gtk and shell themes
    mkdir -p ~/.themes
    cp -r "$current_directory/themes/WhiteSur-Dark" ~/.themes/
    cp -r "$current_directory/themes/WhiteSur-Light" ~/.themes/
    gsettings set org.gnome.desktop.interface gtk-theme "WhiteSur-Dark" # Apply WhiteSur-Dark gtk theme

    # Installing Icon Themes
    mkdir -p ~/.icons
    cp -r "$current_directory/themes/WhiteSur-Icon" ~/.icons/
    gsettings set org.gnome.desktop.interface icon-theme "WhiteSur-Icon"

    # Installing Cursor Theme
    cp -r "$current_directory/themes/WhiteSur-cursors" ~/.icons/
    gsettings set org.gnome.desktop.interface cursor-theme "WhiteSur-cursors"

    install_warp() {
        sudo apt-get install wget gpg
        wget -qO- https://releases.warp.dev/linux/keys/warp.asc | gpg --dearmor > warpdotdev.gpg
        sudo install -D -o root -g root -m 644 warpdotdev.gpg /etc/apt/keyrings/warpdotdev.gpg
        sudo sh -c 'echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/warpdotdev.gpg] https://releases.warp.dev/linux/deb stable main" > /etc/apt/sources.list.d/warpdotdev.list'
        rm warpdotdev.gpg
        sudo apt update && sudo apt install warp-terminal
    }
}

install_applications() {
    say "Installing browsers and media players..."

    # Zen Browser
    flatpak install flathub io.github.zen_browser.zen

    # Flatpak Package Manager
    flatpak install flathub io.github.flattool.Warehouse

    # Audio Player: Amberol
    flatpak install flathub io.bassi.Amberol

    # Photo Gallery: Fotema
    flatpak install flathub app.fotema.Fotema

    # Video Player: Clapper
    flatpak install flathub com.github.rafostar.Clapper

    # VS Code (Snap)
    sudo snap install --classic code

    # Discord Client: ArmCord
    flatpak install flathub xyz.armcord.ArmCord

    # Ask user to install Warp Terminal
    ask_user_to_execute_command "Do you want to install Warp Terminal?" install_warp "Skipping Warp."

    # Ask user to install Github Desktop
    ask_user_to_execute_command "Do you want to install Github Desktop?" "flatpak install flathub io.github.shiftey.Desktop" "Skipping Github Desktop."

    # Ask user to install OBS Studio
    ask_user_to_execute_command "Do you want to install OBS Studio?" "flatpak install flathub com.obsproject.Studio" "Skipping OBS Studio."

    # Ask user to install Blender
    ask_user_to_execute_command "Do you want to install Blender?" "flatpak install flathub org.blender.Blender" "Skipping Blender."
}

install_runtime_env() {
    say "Installing development tools and runtimes..."
    ask_user_to_execute_command "Do you want to install build-essential?" "sudo apt update && sudo apt install build-essential" "Skipping build-essential."
    ask_user_to_execute_command "Do you want to install MongoDB Compass?" "flatpak install flathub com.mongodb.Compass" "Skipping MongoDB Compass."

    # Nodejs installation through nvm
    nvm install 22
    node -v
    npm -v

    ask_user_to_execute_command "Do you want to install JDK 21?" "sudo apt install openjdk-21-jdk" "Skipping Java Development Kit."
}

git_setup() {
    sudo apt update && sudo apt install git
    printf "Installed Git Version: " git --version
    say "Configuring Git..."
    read -r -p "Enter your username for git: " git_name
    read -r -p "Enter your email for git: " git_email
    git config --global user.name "$git_name"
    git config --global user.email "$git_email"
    git config --global core.excludesFile ${pwd}/config/global_gitignore
}

manual_setup() {
    printf "
1. Install the following GNOME extensions: User Themes, Blur my Shell, GS Connect, Compiz alike window effect, Gnome Clipboard.
2. Install Dash to Dock extension for MacOS dock. Make sure to disable the default Ubuntu dock.
3. Apply GNOME shell theme and change the font style.
4. Configure display scaling and mouse sensitivity to your liking.
5. Set up the GRUB boot order if needed.
"
}

# Execution Order
printf "This script sets up your OS with a reasonable config and programs. 
For more details, see README.md.\n
  Essential Softwares & Theming
  Install application programs
  Install compilers and runtime environments
  Git configuration
  \n Note: Before running the script, make sure the script is executed in the following directory: '~/Downloads/workstation-config' \n\n"

ask_user_to_execute_command "Do you want to setup a fresh install with flatpak and gnome tweaks?" install_system_programs "Skipping flatpak and gnome tweaks.\n"

general_theming
install_applications
install_runtime_env
ask_user_to_execute_command "\n Do you want to setup Git?" git_setup "Skipping Git setup.\n"
manual_setup
