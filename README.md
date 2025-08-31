# BenjiLeGnard's Arch setup

This is just an installation script for a minimal Arch setup.

Made live on [stream](https://twitch.tv/benjilegnard) in order to test some linux wayland compositor and rust-based tools

> [!WARNING]
> I do not maintain this anymore, most of the script has been integrated in my [dotfiles](https://github.com/benjilegnard/dotfiles/)

## Features

Install a minimal wayland graphical environment with :

- [fht-compositor](https://nferhat.github.io/fht-compositor/) ([github](https://github.com/nferhat/fht-compositor/)) To manage windows.
- [alacritty](https://alacritty.org/) ([github](https://github.com/alacritty/alacritty/)) for terminal emulation
- [eww](https://elkowar.github.io/eww/), Elkowars Wacky Widgets ([github](https://github.com/elkowar/eww/)) for topbar and launchers
- [swww](https://github.com/LGFae/swww/), "A Solution to your Wayland Wallpaper Woes" for wallpaper management

And additional tools:
- [zsh & oh-my-zsh](https://ohmyz.sh/) for shell
- [starship](https://starship.rs/) shell prompt decoration
- [yazi](https://yazi-rs.github.io/) for file browsing
- [tmux](https://github.com/tmux/tmux/wiki) for terminal multiplexing
- [neovim](https://neovim.io/) for code editing

All themed with [catppuccin/mocha](https://catppuccin.com/)

## Installation

Install a base arch system, preferably server or minimal.

```bash
sudo pacman -S git
git clone https://github.com/benjilegnard/install-arch.git
cd install-arch
./install.sh
```

Follow the prompts.

## TODOLIST

- [~] installer un greeter greetd + wlgreet ?
- [x] conditioner install.sh pour rejouabilité
- [x] ajouter --noconfirm / --needed aux commandes pacman
- [ ] ajouter logs / couleurs au script d'install
- [ ] automatiser + installer eww + daemon
- [ ] thème GTK + catppuccin (grub+tty) purple
- [ ] ... + profit ?
- [ ] faire nos propres widgets eww
- [ ] réintégration dans dépot dotfiles + copie des reps nvim tmux

