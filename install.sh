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

# - [x] rust
# rustup install script
if commandExists "rustup";then
    logInfo "Rust 🦀 is already installed, skipping..."
else
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
    # source env so cargo is available in the next steps
    source "$HOME/.cargo/env"
    # - [x] git and cli tools needed
    packageInstall "git zsh man zip unzip xdg-utils"
fi
# ------
# greetd
# ------
# - [x] greetd : https://man.sr.ht/~kennylevinsen/greetd/#setting-up-greetd-with-wlgreet
packageInstall "greetd greetd-gtkgreet greetd-tuigreet"
sudo cp ./config/greetd/config.toml /etc/greetd/
sudo systemctl enable greetd.service

# --------------
# fht-compositor
# --------------
# - [x] installation fht-compositor : https://nferhat.github.io/fht-compositor/
# build dependencies
packageInstall "clang mesa wayland udev seatd uwsm libdisplay-info libxkbcommon libinput libdrm pipewire dbus"
# Recommended and deps
packageInstall "gtklock grim slurp wl-clipboard libnewt libnotify"

# Clone
if [ -d ./fht-compositor ]; then
    logInfo "fht-compositor already cloned, skipping..."
else
    git clone https://github.com/nferhat/fht-compositor/
    logSuccess "Cloned fht-compositor to ${CWD}/fht-compositor/"
fi

# Build

if [ -f /usr/local/bin/fht-compositor ]; then
    logInfo "fht-compositor already installed, skipping..."
else
    logInfo "Compiling fht-compositor"
    cd fht-compositor
    cargo build --profile opt --features systemd
    # You can copy it to /usr/local/bin or ~/.local/bin, make sure its in $PATH though!
    sudo cp target/opt/fht-compositor /usr/local/bin/

    # Wayland session desktop files
    sudo mkdir -p /usr/share/wayland-sessions
    sudo install -Dm644 res/fht-compositor-uwsm.desktop -t /usr/share/wayland-sessions
    cd -
    logSuccess "fht-compositor Successfully installed !"
fi


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

# misc tools
packageInstall "bat fastfetch lazygit"

# ----
# tmux
# ----
if commandExists "tmux"; then
    logInfo "Tmux already installed, skipping"
else
    packageInstall "tmux"
    logSuccess "Tmux installed"
fi

if [ -f ~/.config/tmux/tmux.conf ];then
    logInfo "tmux already configured, skipping..."
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

# ---
# eww
# ---
# eww dynamic lib dependencies
packageInstall "gtk3 gtk-layer-shell pango cairo glib2 libdbusmenu-gtk3 gdk-pixbuf2 gcc-libs glibc"
# clone build
if [ -d ./eww ];then
    logInfo "eww already cloned, skipping..."
else
    git clone https://github.com/elkowar/eww
    logSuccess "eww cloned successfully"
fi


if commandExists "eww"; then
    logInfo "eww already installed, skipping..."
else
    cd ./eww
    cargo build --release --no-default-features --features=wayland
    chmod +x target/release/eww
    sudo cp target/release/eww /usr/local/bin/
    cd -
fi

mkdir -p ~/.config/eww

cp -r ./config/eww/eww.yuck ~/.config/eww/

# - [ ] mako : https://github.com/emersion/mako

# - [ ] wayland utils (wl-clipboard) https://github.com/sentriz/cliphist

# - [ ] swayidle / swaylock // TODO replace gtklock ?

# - [x] helix
if commandExists "helix"; then
    logInfo "Helix editor already installed, skipping..."
else
    packageInstall "helix"
fi

if [ -f ~/.config/helix/config.toml ];then
    logInfo "Helix already configured, skipping configuration..."
else
    mkdir -p ~/.config/helix
    cp ./config/helix/config.toml ~/.config/helix/
fi

# - [x] zsh and oh-my-zsh
if [ -d ~/.oh-my-zsh ]; then
    logInfo "OMZ already installed, skipping"
else
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi

cp ./config/zshrc ~/.zshrc

# chsh -s $(which zsh)

# - [x] starship
if commandExists "starship"; then
    logInfo "Starhip already installed, skipping..."
else
    curl -sS https://starship.rs/install.sh | sh
fi

# hack nerd font and emojis
packageInstall "noto-fonts-emoji ttf-hack-nerd"

# - [ ] yazi : https://yazi-rs.github.io/

# -----
# qogir
# -----
# icon themes
if [ -d qogir-icon-theme ]; then
    logInfo "Qogir icons already cloned, skipping..."
else
    git clone https://github.com/vinceliuice/Qogir-icon-theme qogir-icon-theme || { logError "git clone failed"; exit 1; }
    logSuccess "Qogir icon theme cloned sucessfully";
fi

if [ -d ~/.local/share/icons/Qogir ]; then
    logInfo "Qogir theme already installed, skipping..."
else
    cd qogir-icon-theme
    ./install.sh
    if [[ $? != 0 ]]; then
        logError "Qogir installation failed"
        cd -
        exit 1
    fi
    cd -
fi

# ----
# Sway & waybar
# ----
if commandExists "sway"; then
    logInfo "Sway already installed, skipping..."
else
    packageInstall "sway swaylock swayidle swaync swaybg sway-contrib"
    logSuccess "sway installed"
fi

if commandExists "waybar"; then
    logInfo "Waybar already installed, skipping..."
else
    packageInstall "waybar rhythmbox"
fi

packageInstall "network-manager-applet pavucontrol"

# - [ ] polkit : https://wiki.archlinux.org/title/Polkit#Authentication_agents
packageInstall "polkit-gnome"
# - [ ] desktop portal
packageInstall "xdg-desktop-portal xdg-desktop-portal-wlr"

# - [ ] swww (wallpaper manager) https://github.com/LGFae/swww
packageInstall "swww"
# TODO automatic install of wallpapers + create script to randomize + transition

# -------
# node.js
# -------
if [ -d ~/.nvm ]; then
    logInfo "nvm already installed, skipping..."
else
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash
fi


#
# Final checks
#
printSuccess "Installation successful !"
