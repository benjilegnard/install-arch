<div align="center">
<img src="./assets/canarchy-logo.svg" style="width: 100px; height: 100px;" alt="a duck silouhette on a rainbow background"/>

# CANARCHY
<p>BenjiLeGnard's minimal Arch setup</p>
</div>

This is just an installation script for a basic Arch setup.

Made live on [stream](https://twitch.tv/benjilegnard) in order to test some linux wayland compositor and try mainly rust-based tools

> [!WARNING]
> I do not really maintain this anymore, most of the script has been integrated in my [dotfiles](https://github.com/benjilegnard/dotfiles/), and it has derailed from the original intent. I'll come back to it sometimes.

> [!IMPORTANT]
> I decline all responsability if you use this and brick you computer, the script is provided as-is, with no garanty etc...

## Features

Install a minimal wayland graphical environment with :

- [fht-compositor](https://nferhat.github.io/fht-compositor/) ([github](https://github.com/nferhat/fht-compositor/)) To manage windows.
- [eww](https://elkowar.github.io/eww/), Elkowars Wacky Widgets ([github](https://github.com/elkowar/eww/)) for topbar and launchers
- [awww](https://codeberg.org/LGFae/awww), "An Answer to your Wayland Wallpaper Woes" for wallpaper management
- [alacritty](https://alacritty.org/) ([github](https://github.com/alacritty/alacritty/)) for terminal emulation

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
git clone https://github.com/benjilegnard/canarchy.git
cd canarchy
./install.sh
```

Follow the prompts.

## TODOLIST

- [x] installer un greeter greetd + wlgreet
- [x] conditionner install.sh pour rejouabilité
  - [ ] rewrite it in rust ?
- [x] ajouter --noconfirm / --needed aux commandes pacman
- [x] ajouter logs / couleurs au script d'install
- [x] automatiser + installer eww + daemon
- [ ] thème catppuccin 
  - [x] grub
  - [ ] tty
  - [ ] gtk3/gtk4
  - [ ] ...
- [ ] plymouth ?
  - [ ] choose a theme lol
- [ ] ... + profit ?
- [ ] faire nos propres widgets eww
  - [ ] remplacement de waybar
    - [ ] workspaces
    - [ ] window name
    - [ ] date + calendar
    - [ ] music player
    - [ ] stats system
    - [ ] volume
    - [ ] brightness
    - [ ] battery
    - [ ] systray
    - [ ] idle_inhibitor
    - [ ] airplane_mode ?
  - [ ] powermenu (logout/poweroff/reboot)
  - [ ] launcher ? (rofi or [sirula](https://github.com/DorianRudolph/sirula) ?)
  - [ ] notifs ??
    - [ ] mako ou dunst
  - [ ] dashboard...
    - [ ] logs ?
- [ ] ~~réintégration dans dépot dotfiles~~
- [ ] awww + wallpaper picker
