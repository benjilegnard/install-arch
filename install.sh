#!/bin/bash

# Arch package install script
# We consider you have setup correctly an archlinux install from here

# comment this line to disable fail on error
set -e

. ./colors.sh

printInfo "Installation started..."

# Checks if a command exists
commandExists() {
  command -v "$1" >/dev/null 2>&1
}

packageInstall () {
  sudo pacman -S --noconfirm --needed $1
}

# create temp directory where we will clone repos
mkdir -p ./temp

# - [x] git and cli tools needed by other installer
packageInstall "git zsh man zip unzip xdg-utils clang kitty"

# - [x] rust
# rustup install script
if commandExists "rustup";then
    logInfo "Rust 🦀 is already installed, skipping..."
else
    packageInstall "rust rustup"
    rustup update stable
    # source env so cargo is available in the next steps
    source "$HOME/.cargo/env"
fi

# ------
# greetd
# ------
# - [x] greetd : https://man.sr.ht/~kennylevinsen/greetd/#setting-up-greetd-with-wlgreet
packageInstall "greetd greetd-gtkgreet"
sudo cp ./config/greetd/config.toml /etc/greetd/
sudo cp ./config/greetd/sway-config /etc/greetd/
#sudo cp ./config/greetd/wlgreet.toml /etc/greetd/
sudo systemctl enable greetd.service

# ---------
# alacritty
# ---------
# - [x] alacritty : https://github.com/alacritty/alacritty
if commandExists "alacritty"; then
    logInfo "Alacritty already installed, skipping..."
else
    mkdir -p ~/.config/alacritty
    # download catppuccin mocha theme
    curl -LO --output-dir ~/.config/alacritty https://github.com/catppuccin/alacritty/raw/main/catppuccin-mocha.toml
    # replace bg color
    sed -i.bak '2s/1e1e2e/11111b/' ~/.config/alacritty/catppuccin-mocha.toml
    # install
    packageInstall "alacritty"
    logSuccess "Alacritty terminal installed"
fi
# copy config
cp config/alacritty/alacritty.toml ~/.config/alacritty/

# ----
# rofi
# ----
# - [x] Rofi : https://davatorium.github.io/rofi/ 
if commandExists "rofi"; then
    logInfo "Rofi already installed, skipping..."
else
    packageInstall "rofi-wayland rofi-emoji wtype wl-clipboard"
fi

if [ -d ~/.local/share/rofi/themes ];then
    logInfo "rofi theme folder exists, skipping..."
else
    mkdir -p ~/.local/share/rofi/themes/
    cp ./config/rofi/catppuccin-mocha.rasi ~/.local/share/rofi/themes/
    logSuccess "created rofi theme"
fi

if [ -d ~/.config/rofi ]; then
    logInfo "rofi config dir exists, skipping..."
else
    mkdir -p ~/.config/rofi/
    cp ./config/rofi/config.rasi ~/.config/rofi/
    logSuccess "Rofi installed"
fi

# ----
# tmux
# ----
if commandExists "tmux"; then
    logInfo "Tmux 🔀 already installed, skipping"
else
    packageInstall "tmux"
    logSuccess "Tmux 🔀 installed"
fi

if [ -f ~/.config/tmux/tmux.conf ];then
    logInfo "Tmux 🔀 already configured, skipping..."
else
    mkdir -p ~/.config/tmux
    cp ./config/tmux/tmux.conf ~/.config/tmux/
    logSuccess "created tmux configuration file"
fi
# tmux plugin manager
if [ -d ~/.tmux/plugins/tpm ];then
    logInfo "tmux plugins already installed, skipping"
else
    mkdir -p ~/.tmux/plugins/
    git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
fi

# - [ ] mako : https://github.com/emersion/mako

# - [ ] wayland utils (wl-clipboard) https://github.com/sentriz/cliphist

# - [ ] swayidle / swaylock // TODO replace gtklock ?

# - [x] helix
if commandExists "helix"; then
    logInfo "Helix 🧬 already installed, skipping..."
else
    packageInstall "helix"
fi

if [ -f ~/.config/helix/config.toml ];then
    logInfo "Helix 🧬 already configured, skipping configuration..."
else
    mkdir -p ~/.config/helix
    cp ./config/helix/config.toml ~/.config/helix/
fi

# - [x] zsh and oh-my-zsh
if [ -d ~/.oh-my-zsh ]; then
    logInfo "OMZ 🔣 already installed, skipping..."
else
    logInfo "OMZ 🔣 not found, installing..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi

cp ./config/zshrc ~/.zshrc

# chsh -s $(which zsh)

# - [x] starship : https://starship.rs/
if commandExists "starship"; then
    logInfo "Starship 🚀 already installed, skipping..."
else
    logInfo "Starship 🚀 not found, installing..."
    curl -sS https://starship.rs/install.sh | sh
    logSuccess "Starship 🚀 installed"
fi

# hack nerd font and emojis
packageInstall "noto-fonts-emoji noto-fonts-cjk noto-fonts-extra ttf-hack-nerd"

# - [ ] yazi : https://yazi-rs.github.io/

# -----
# qogir icons
# -----
# icon themes
if [ -d ./temp/qogir-icon-theme ]; then
    logInfo "Qogir icon theme 🖌️ already cloned, skipping..."
else
    git clone https://github.com/vinceliuice/Qogir-icon-theme temp/qogir-icon-theme || { logError "git clone failed"; exit 1; }
    logSuccess "Qogir icon theme 🖌️ cloned sucessfully";
fi

if [ -d ~/.local/share/icons/Qogir ]; then
    logInfo "Qogir icon theme 🖌️ already installed, skipping..."
else
    cd temp/qogir-icon-theme
    ./install.sh
    if [[ $? != 0 ]]; then
        logError "Qogir installation failed"
        cd -
        exit 1
    fi
    cd -
fi

# ---------------
# Catppuccin Theme
# ---------------
printInfo "Installing Catppuccin themes..."

# Create temp directory for downloads
mkdir -p ./temp/catppuccin

# GRUB Theme
if [ -f /boot/grub/grub.cfg ]; then
    logInfo "GRUB is installed, setting up Catppuccin theme..."

    # Clone catppuccin/grub
    if [ ! -d ./temp/catppuccin/grub ]; then
        git clone --depth 1 https://github.com/catppuccin/grub.git ./temp/catppuccin/grub
    fi

    # Copy theme files
    sudo mkdir -p /usr/share/grub/themes
    sudo cp -r ./temp/catppuccin/grub/src/catppuccin-mocha-grub-theme /usr/share/grub/themes/
    sudo chmod -R 755 /usr/share/grub/themes/catppuccin-mocha-grub-theme

    # Check if theme is already configured
    if ! grep -q "^GRUB_THEME=" /etc/default/grub; then
        # Add theme to grub config
        sudo bash -c 'echo "GRUB_THEME=\"/usr/share/grub/themes/catppuccin-mocha-grub-theme/theme.txt\"" >> /etc/default/grub'
        # Update grub
        sudo grub-mkconfig -o /boot/grub/grub.cfg
        logSuccess "GRUB theme installed and configured"
    else
        logInfo "GRUB theme already configured, skipping..."
    fi
fi


# Waybar Theme
if [ ! -d ./temp/catppuccin/waybar ]; then
    logInfo "Cloning Catppuccin Waybar theme..."
    git clone --depth 1 https://github.com/catppuccin/waybar.git ./temp/catppuccin/waybar
fi

if [ ! -d ~/.config/waybar ]; then
    # Create waybar config directory
    mkdir -p ~/.config/waybar
    chmod 755 ~/.config/waybar

    # Copy mocha theme
    cp ./temp/catppuccin/waybar/themes/mocha.css ~/.config/waybar/
    chmod 755 ~/.config/waybar/mocha.css
    logSuccess "Waybar theme installed"

    # Tmux Theme
    logInfo "Setting up Catppuccin Tmux theme..."
    mkdir -p ~/.config/tmux/plugins/catppuccin
    chmod -R 755 ~/.config/tmux/plugins
else
    logInfo "Waybar already configured, skipping"
fi

# Btop Theme
if [ ! -d ./temp/catppuccin/btop ]; then
    logInfo "Setting up Catppuccin Btop theme..."
    git clone --depth 1 https://github.com/catppuccin/btop.git ./temp/catppuccin/btop
fi

if [ ! -d ~/.config/btop/themes ]; then
    # Create btop config directory
    mkdir -p ~/.config/btop/themes
    chmod -R 755 ~/.config/btop

    # Copy mocha theme
    cp ./temp/catppuccin/btop/themes/catppuccin_mocha.theme ~/.config/btop/themes/catppuccin.theme
    chmod 755 ~/.config/btop/themes/catppuccin.theme
    logSuccess "Btop theme installed"
fi

# GTK Theme
logInfo "Setting up Catppuccin GTK theme..."
GTK_THEME="catppuccin-mocha-teal-standard+default"

# Create themes directory
mkdir -p ~/.themes
chmod 755 ~/.themes

# Download and install GTK theme
if [ ! -d ~/.themes/${GTK_THEME} ]; then
    curl -L https://github.com/catppuccin/gtk/releases/download/v1.0.3/${GTK_THEME}.zip -o /tmp/${GTK_THEME}.zip
    unzip -q /tmp/${GTK_THEME}.zip -d ~/.themes/
    chmod -R 755 ~/.themes/${GTK_THEME}
fi

if [ ! -d ~/.config/gtk-3/ ]; then
    # Create GTK config directories
    mkdir -p ~/.config/gtk-4.0 ~/.config/gtk-3.0
    chmod 755 ~/.config/gtk-4.0 ~/.config/gtk-3.0

    # Copy settings.ini if it exists in the config directory
    if [ -f ./config/gtk/settings.ini ]; then
        cp ./config/gtk/settings.ini ~/.config/gtk-3.0/
        cp ./config/gtk/settings.ini ~/.config/gtk-4.0/
        chmod 755 ~/.config/gtk-3.0/settings.ini ~/.config/gtk-4.0/settings.ini
    else
        # Create basic settings file if it doesn't exist
        echo "[Settings]" > ~/.config/gtk-3.0/settings.ini
        echo "gtk-theme-name=${GTK_THEME}" >> ~/.config/gtk-3.0/settings.ini
        cp ~/.config/gtk-3.0/settings.ini ~/.config/gtk-4.0/
    fi

    # Create symbolic links for GTK-4.0
    ln -sf ~/.themes/${GTK_THEME}/gtk-4.0/assets ~/.config/gtk-4.0/assets
    ln -sf ~/.themes/${GTK_THEME}/gtk-4.0/gtk.css ~/.config/gtk-4.0/gtk.css
    ln -sf ~/.themes/${GTK_THEME}/gtk-4.0/gtk-dark.css ~/.config/gtk-4.0/gtk-dark.css

    # Enable theme in profile and rc files
    for file in ~/.profile ~/.zshrc ~/.bashrc; do
        if ! grep -q "export GTK_THEME=\"${GTK_THEME}\"" "$file" 2>/dev/null; then
            echo "export GTK_THEME=\"${GTK_THEME}\"" >> "$file"
        fi
    done

    # Make sure theme is in GTK settings
    if ! grep -q "gtk-theme-name=${GTK_THEME}" ~/.config/gtk-3.0/settings.ini; then
        echo "gtk-theme-name=${GTK_THEME}" >> ~/.config/gtk-3.0/settings.ini
    fi

    logSuccess "GTK theme installed and configured"

fi

printSuccess "Catppuccin themes installation completed!"

# ----
# Sway & waybar
# ----
if commandExists "sway"; then
    logInfo "Sway 🪟 already installed, skipping..."
else
    logInfo "Sway 🪟 not found, installing..."
    packageInstall "sway swaylock swayidle swaync swaybg sway-contrib zenity grim slurp wl-clipboard wayland mesa wdisplays "
    logSuccess "Sway 🪟 installed"
fi

if commandExists "waybar"; then
    logInfo "Waybar 🍫 already installed, skipping..."
else
    logInfo "Waybar 🍫 not found, installing..."
    packageInstall "waybar"
fi

# network / wiki on macOS mini mid-2014, see:
# - https://wiki.archlinux.org/title/Broadcom_wireless
# - https://bbs.archlinux.org/viewtopic.php?pid=1862759#p1862759
# packageInstall "broadcom-wl-dkms"
# also needed to blacklist some module in a /etc/modules-load.d/broadcom-wl-dkms.conf file
# echo "blacklist b43" > /etc/modprobe.d/wifi.conf

# - [ ] network and other utilities displayed in tray bar or waybar
packageInstall "networkmanager network-manager-applet pavucontrol"
sudo systemctl enable NetworkManager

# - [ ] polkit : https://wiki.archlinux.org/title/Polkit#Authentication_agents
packageInstall "polkit-gnome"

# - [ ] desktop portal
packageInstall "xdg-desktop-portal xdg-desktop-portal-wlr"

# -------
# node.js
# -------
if [ -d ~/.nvm ]; then
    logInfo "nvm 🔢 already installed, skipping..."
else
    logInfo "nvm 🔢 not found, installing..."
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash
    logSuccess "nvm 🔢 installed"
fi

# -------
# claude
# -------
if commandExists "claude"; then
    logInfo "claude 🤖 already installed, skipping..."
else
    logInfo "claude 🤖 not found, installing..."
    curl -fsSL https://claude.ai/install.sh | bash
    logSuccess "claude 🤖 installed"
fi

# --------
# opencode
# --------

if commandExists "opencode"; then
    logInfo "opencode 🤖 already installed, skipping..."
else
    logInfo "opencode 🤖 not found, installing..."
    curl -fsSL https://opencode.ai/install | bash
    logSuccess "opencode 🤖 installed"
fi

# --------
# ollama - https://ollama.com/
# --------
if commandExists "ollama"; then
    logInfo "ollama 🦙 already installed, skipping..."
else
    logInfo "ollama 🦙 not found, installing..."
    curl -fsSL https://ollama.com/install.sh | sh
    sudo systemctl enable ollama.service
    logSuccess "ollama 🦙 installed"
fi

# ------
# docker - https://docs.docker.com/desktop/setup/install/linux/archlinux/
# ------
if commandExists "docker"; then
    logInfo "docker 🐋 already installed, skipping..."
else
    logInfo "docker 🐋 not found, installing..."
    packageInstall "docker"
    # sudo groupadd docker
    sudo usermod -aG docker $USER
    sudo systemctl enable docker.service
    sudo systemctl enable containerd.service
    logSuccess "docker 🐋 installed"
fi

# misc tools
packageInstall "bat fastfetch lazygit lazydocker neovim firefox rhythmbox gimp blender obs-studio chromium mpv ffmpeg"


#
# Final checks
#
printSuccess "Installation successful !"
