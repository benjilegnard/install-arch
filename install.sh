#!/bin/bash

# Arch package install script
# We consider you have setup correctly an archlinux install from here

# disable fail on error, you can skip install prompts
# set -e

# - [x] rust
# rustup install script
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
# source env so cargo is available in the next steps
. "$HOME/.cargo/env"
# - [x] git and cli tools needed
sudo pacman -S git tmux zsh man zip unzip

# --------------
# fht-compositor
# --------------
# - [x] installation fht-compositor : https://nferhat.github.io/fht-compositor/
# build dependencies
sudo pacman -S clang mesa wayland udev seatd uwsm libdisplay-info libxkbcommon libinput libdrm pipewire dbus
# Recommended and deps
sudo pacman -S gtklock grim slurp wl-clipboard libnewt libnotify

# Clone
if [ -d ./fht-compositor ]; then
    echo "fht-compositor already cloned"
else
    git clone https://github.com/nferhat/fht-compositor/
fi

# Build
cd fht-compositor

cargo build --profile opt --features uwsm
# You can copy it to /usr/local/bin or ~/.local/bin, make sure its in $PATH though!
sudo cp target/opt/fht-compositor /usr/local/bin/

# Wayland session desktop files
sudo mkdir -p /usr/share/wayland-sessions
sudo install -Dm644 res/fht-compositor-uwsm.desktop -t /usr/share/wayland-sessions

cd -

# ---------
# alacritty
# ---------
# - [x] alacritty : https://github.com/alacritty/alacritty
mkdir -p ~/.config/alacritty
# download catppuccin mocha theme
curl -LO --output-dir ~/.config/alacritty https://github.com/catppuccin/alacritty/raw/main/catppuccin-mocha.toml
# replace bg color
sed -i.bak '2s/1e1e2e/11111b/' ~/.config/alacritty/catppuccin-mocha.toml
# copy config
cp config/alacritty/alacritty.toml ~/.config/alacritty/
# install
sudo pacman -S alacritty

# ----
# wofi (and other tools, temporary, sort later)
# ----
# - [ ] wofi : https://hg.sr.ht/~scoopta/wofi
sudo pacman -S wofi bat fastfetch lazygit

# - [ ] mako : https://github.com/emersion/mako

# - [ ] wayland utils (wl-clipboard) https://github.com/sentriz/cliphist

# - [ ] swayidle / swaylock // TODO replace gtklock

# - [ ] neovim
sudo pacman -S neovim
# // TODO neovim config files

# - [x] zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
cp ./config/zshrc ~/.zshrc
chsh -s $(which zsh)
# - [x] starship
curl -sS https://starship.rs/install.sh | sh

# hack nerd font and emojis
sudo pacman -S noto-fonts-emoji ttf-hack-nerd
# - [ ] tmux
# - [ ] tmux plugins : https://github.com/tmux-plugins/tpm

# - [ ] yazi : https://yazi-rs.github.io/

# - [ ] Hack web font https://github.com/ryanoasis/nerd-fonts/releases/download/v3.4.0/Hack.zip

# - [ ] optional / greetd wlgreet : https://git.sr.ht/~kennylevinsen/wlgreet / https://man.sr.ht/~kennylevinsen/greetd/#setting-up-greetd-with-wlgreet

# - [ ] polkit : https://wiki.archlinux.org/title/Polkit#Authentication_agents
sudo pacman -S polkit-gnome
# - [ ] desktop portal
sudo pacman -S xdg-desktop-portal

# - [ ] swww (wallpaper manager) https://github.com/LGFae/swww
sudo pacman -S swww
# TODO automatic install of wallpapers + create script to randomize + transition

# -------
# node.js
# -------
if command -v nvm; then
    echo "nvm already installed, skipping..."
else
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash
fi


