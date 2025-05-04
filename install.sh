#!/bin/bash

# Arch package install script
# We consider you have setup correctly an archlinux install from here

# - [x] rust / cargo 
sudo pacman -S rust

# - [ ] install paru : https://github.com/Morganamilo/paru
sudo pacman -S --needed base-devel
git clone https://aur.archlinux.org/paru.git
cd paru
makepkg -si

# - [ ] alacritty : https://github.com/alacritty/alacritty
# // TODO setup config https://alacritty.org/config-alacritty.html

# - [ ] wofi : https://hg.sr.ht/~scoopta/wofi
sudo pacman -S alacritty wofi grim slurp wl-clipboard
sudo pacman -S bat fastfetch

# - [ ] installation fht-compositor : https://nferhat.github.io/fht-compositor/
# TODO: install manually, version is not in aur
paru -S fht-compositor-git

# Needed for screencast to work
paru -S fht-share-picker-git

# Recommended
paru -S uwsm

# - [ ] mako : https://github.com/emersion/mako

# - [ ] wayland utils (wl-clipboard) https://github.com/sentriz/cliphist

# - [ ] swayidle / swaylock

# - [ ] neovim

# - [ ] tmux

# - [ ] yazi : https://yazi-rs.github.io/

# - [ ] Hack web font https://github.com/ryanoasis/nerd-fonts/releases/download/v3.4.0/Hack.zip

# - [ ] optional / greetd wlgreet : https://git.sr.ht/~kennylevinsen/wlgreet / https://man.sr.ht/~kennylevinsen/greetd/#setting-up-greetd-with-wlgreet

# - [ ] polkit : https://wiki.archlinux.org/title/Polkit#Authentication_agents
sudo pacman -S polkit-gnome
# - [ ] desktop portal
sudo pacman -S xdg-desktop-portal

# - [ ] swww (wallpaper manager) https://github.com/LGFae/swww

# - [ ] astal https://aylur.github.io/astal/

# - aylurs-gtk-shell-git (for developing astal, `)
