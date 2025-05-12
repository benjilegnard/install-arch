#!/bin/bash

# Arch package install script
# We consider you have setup correctly an archlinux install from here

# disable fail on error, you can skip install prompts
# set -e

# common bash functions

exists()
{
  command -v "$1" >/dev/null 2>&1
}

# - [x] rust
# rustup install script
if exists "rustup";then
    echo "rustup already installed, skipping"
else
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
    # source env so cargo is available in the next steps
    source "$HOME/.cargo/env"
    # - [x] git and cli tools needed
    sudo pacman -S --noconfirm --needed git tmux zsh man zip unzip
fi
# ------
# greetd
# ------
# - [x] greetd : https://man.sr.ht/~kennylevinsen/greetd/#setting-up-greetd-with-wlgreet
sudo pacman -S --noconfirm --needed greetd greetd-gtkgreet greetd-tuigreet
sudo cp ./config/greetd/config.toml /etc/greetd/
sudo systemctl enable greetd.service

# --------------
# fht-compositor
# --------------
# - [x] installation fht-compositor : https://nferhat.github.io/fht-compositor/
# build dependencies
sudo pacman -S --noconfirm --needed clang mesa wayland udev seatd uwsm libdisplay-info libxkbcommon libinput libdrm pipewire dbus
# Recommended and deps
sudo pacman -S --noconfirm --needed gtklock grim slurp wl-clipboard libnewt libnotify

# Clone
if [ -d ./fht-compositor ]; then
    echo "fht-compositor already cloned"
else
    git clone https://github.com/nferhat/fht-compositor/
fi

# Build

if [ -f /usr/local/bin/fht-compositor ]; then
    echo "fht-compositor already installed, skipping..."
else
    cd fht-compositor
    cargo build --profile opt --features uwsm
    # You can copy it to /usr/local/bin or ~/.local/bin, make sure its in $PATH though!
    sudo cp target/opt/fht-compositor /usr/local/bin/

    # Wayland session desktop files
    sudo mkdir -p /usr/share/wayland-sessions
    sudo install -Dm644 res/fht-compositor-uwsm.desktop -t /usr/share/wayland-sessions
    cd -
fi


# ---------
# alacritty
# ---------
# - [x] alacritty : https://github.com/alacritty/alacritty
if exists "alacritty"; then
    echo "Alacritty already installed, skipping..."
else
    mkdir -p ~/.config/alacritty
    # download catppuccin mocha theme
    curl -LO --output-dir ~/.config/alacritty https://github.com/catppuccin/alacritty/raw/main/catppuccin-mocha.toml
    # replace bg color
    sed -i.bak '2s/1e1e2e/11111b/' ~/.config/alacritty/catppuccin-mocha.toml
    # install
    sudo pacman -S --noconfirm --needed alacritty
fi
# copy config
cp config/alacritty/alacritty.toml ~/.config/alacritty/

# ----
# wofi (and other tools, temporary, sort later)
# ----
# - [ ] wofi : https://hg.sr.ht/~scoopta/wofi
sudo pacman -S --noconfirm --needed wofi bat fastfetch lazygit

# ---
# eww
# ---
# eww dynamic lib dependencies
sudo pacman -S --noconfirm --needed gtk3 gtk-layer-shell pango cairo glib2 libdbusmenu-gtk3 gdk-pixbuf2 gcc-libs glibc
# clone build
if [ -d ./eww ];then
    echo "eww already cloned, skipping..."
else
    git clone https://github.com/elkowar/eww
fi


if exists "eww"; then
    echo "eww already installed, skipping..."
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

# - [ ] swayidle / swaylock // TODO replace gtklock

# - [ ] neovim
sudo pacman -S --noconfirm --needed neovim
# // TODO neovim config files

# - [x] zsh and oh-my-zsh
if [ -d ~/.oh-my-zsh ]; then
    echo "OMZ already installed, skipping"
else
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi

cp ./config/zshrc ~/.zshrc

# chsh -s $(which zsh)

# - [x] starship
if exists "starship"; then
    echo "Starhip already installed, skipping..."
else
    curl -sS https://starship.rs/install.sh | sh
fi

# hack nerd font and emojis
sudo pacman -S --noconfirm --needed noto-fonts-emoji ttf-hack-nerd
# - [ ] tmux
# - [ ] tmux plugins : https://github.com/tmux-plugins/tpm

# - [ ] yazi : https://yazi-rs.github.io/

# -----
# qogir
# -----
# icon themes
if [ -d qogir-icon-theme ]; then
    echo "Qogir icons already cloned, skipping..."
else
    git clone https://github.com/vinceliuice/Qogir-icon-theme qogir-icon-theme
fi


if [ -d ~/.local/share/icons/Qogir ]; then
    echo "Qogir theme already installed, skipping..."
else
    cd qogir-icon-theme
    ./install.sh
    cd -
fi


# - [ ] Hack web font https://github.com/ryanoasis/nerd-fonts/releases/download/v3.4.0/Hack.zip


# - [ ] polkit : https://wiki.archlinux.org/title/Polkit#Authentication_agents
sudo pacman -S --noconfirm --needed polkit-gnome
# - [ ] desktop portal
sudo pacman -S --noconfirm --needed xdg-desktop-portal

# - [ ] swww (wallpaper manager) https://github.com/LGFae/swww
sudo pacman -S --noconfirm --needed swww
# TODO automatic install of wallpapers + create script to randomize + transition

# -------
# node.js
# -------
if exists "nvm"; then
    echo "nvm already installed, skipping..."
else
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash
fi


