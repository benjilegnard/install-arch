# Plan: rewrite `install.sh` as a Rust CLI driven by `manifest.toml`

Status: proposal, not started.

Goal: replace the 425 lines of imperative bash in `install.sh` with a declarative
`manifest.toml` plus a small Rust runner (`canarchy`), keeping the same end
result, the same log style as `colors.sh`, and gaining `--dry-run`, `status` and
an update path.

Prior art: [caelestia-dots/caelestia](https://github.com/caelestia-dots/caelestia)
uses this exact model ([`manifest.toml`](https://github.com/caelestia-dots/caelestia/blob/main/manifest.toml)
read by `caelestia-cli`, a Python CLI installed from the AUR). Their schema is
`packages` + `entries` + `post_install`/`post_update` grouped into `[[components]]`.
That covers less than we need, see section 1.

## 1. Primitives needed

Every action currently in `install.sh`, and the manifest primitive that replaces it:

| `install.sh` does                                                              | primitive                      |
| ------------------------------------------------------------------------------ | ------------------------------ |
| `pacman -S --noconfirm --needed` (10 separate calls)                           | `packages`                     |
| `cp config/x ~/.config/x`, `cp -r config/zsh ~/.config/`                       | `files` (src, dest, mode)      |
| `sudo cp config/greetd/* /etc/greetd/`                                         | `files` with `sudo = true`     |
| `sudo systemctl enable greetd / NetworkManager / ollama / docker / containerd` | `services`                     |
| `curl -LO catppuccin-mocha.toml`                                               | `fetch` (url, dest)            |
| `curl -L gtk.zip && unzip -d ~/.themes`                                        | `fetch` with `extract`         |
| `git clone --depth 1` (tpm, Qogir, catppuccin grub/waybar/btop)                | `repos` (url, dest, depth)     |
| `cd temp/qogir-icon-theme && ./install.sh`                                     | `commands` with `cwd`          |
| `curl ... \| sh` (omz, starship, nvm, claude, opencode, ollama)                | `commands` with `shell = true` |
| `sed -i.bak '2s/1e1e2e/11111b/'`                                               | `commands`                     |
| `ln -sf` gtk-4.0 assets / gtk.css / gtk-dark.css                               | `links`                        |
| append `export GTK_THEME=` to `.profile`/`.zshrc`/`.bashrc` if absent          | `lines`                        |
| `sudo usermod -aG docker $USER`                                                | `groups`                       |
| `commandExists x` guards (~12)                                                 | `unless.command`               |
| `[ -d ~/.config/rofi ]` guards (~15)                                           | `unless.path`                  |
| `if [ -f /boot/grub/grub.cfg ]`                                                | `when.path`                    |
| `grep -q "^GRUB_THEME=" /etc/default/grub`                                     | `unless.file_contains`         |
| `GTK_THEME="catppuccin-mocha-teal-standard+default"`                           | `[vars]` + template expansion  |

Plus two from caelestia worth taking: `default = true/false` for opt-in
components, and `requires` for ordering.

`lines` is the only primitive that is non-trivially idempotent (append a line to
a file only if a pattern is absent). Everything else gets idempotency from
`pacman --needed`, `cp`, or `ln -sf`.

## 2. Manifest shape

```toml
version = 1

[settings]
temp_dir = "./temp"
pacman_args = ["--noconfirm", "--needed"]

[vars]
flavor = "mocha"
gtk_theme = "catppuccin-mocha-teal-standard+default"

[[components]]
name = "base"
default = true
description = "git, shell, cli tooling"
packages = ["git", "zsh", "man", "zip", "unzip", "xdg-utils", "clang", "kitty"]

[[components]]
name = "greetd"
default = true
requires = ["base"]
packages = ["greetd", "greetd-gtkgreet"]
services = ["greetd.service"]
[[components.files]]
src = "config/greetd/config.toml"
dest = "/etc/greetd/config.toml"
sudo = true

[[components]]
name = "alacritty"
default = true
packages = ["alacritty"]
[[components.fetch]]
url  = "https://github.com/catppuccin/alacritty/raw/main/catppuccin-{{flavor}}.toml"
dest = "$XDG_CONFIG_HOME/alacritty/catppuccin-{{flavor}}.toml"
[[components.commands]]
run = "sed -i.bak '2s/1e1e2e/11111b/' $XDG_CONFIG_HOME/alacritty/catppuccin-{{flavor}}.toml"
shell = true
[[components.files]]
src  = "config/alacritty/alacritty.toml"
dest = "$XDG_CONFIG_HOME/alacritty/alacritty.toml"

[[components]]
name = "grub-theme"
default = true
when.path = "/boot/grub/grub.cfg"           # replaces `if [ -f ... ]`
[[components.repos]]
url = "https://github.com/catppuccin/grub.git"
dest = "{{temp}}/catppuccin/grub"
depth = 1
[[components.files]]
src  = "{{temp}}/catppuccin/grub/src/catppuccin-{{flavor}}-grub-theme"
dest = "/usr/share/grub/themes/catppuccin-{{flavor}}-grub-theme"
sudo = true
mode = "755"
[[components.lines]]
file = "/etc/default/grub"
content = 'GRUB_THEME="/usr/share/grub/themes/catppuccin-{{flavor}}-grub-theme/theme.txt"'
match = "^GRUB_THEME="                      # replaces the `grep -q`
sudo = true
[[components.commands]]
run = "grub-mkconfig -o /boot/grub/grub.cfg"
sudo = true
only_if_changed = true                      # skip when `lines` was already satisfied

[[components]]
name = "gtk"
default = true
packages = ["adw-gtk-theme"]
[[components.fetch]]
url = "https://github.com/catppuccin/gtk/releases/download/v1.0.3/{{gtk_theme}}.zip"
dest = "$HOME/.themes"
extract = "zip"
unless.path = "$HOME/.themes/{{gtk_theme}}"
[[components.links]]
src  = "$HOME/.themes/{{gtk_theme}}/gtk-4.0/gtk.css"
dest = "$XDG_CONFIG_HOME/gtk-4.0/gtk.css"
[[components.lines]]
files = ["$HOME/.profile", "$HOME/.zshrc", "$HOME/.bashrc"]
content = 'export GTK_THEME="{{gtk_theme}}"'

[[components]]
name = "docker"
packages = ["docker"]
groups = ["docker"]
services = ["docker.service", "containerd.service"]

[[components]]
name = "ai-tools"
[[components.commands]]
run = "curl -fsSL https://claude.ai/install.sh | bash"
shell = true
unless.command = "claude"
```

## 3. Serde schema

```rust
#[derive(Deserialize)]
#[serde(deny_unknown_fields)]
pub struct Manifest {
    #[serde(default = "one")] pub version: u32,
    #[serde(default)] pub settings: Settings,
    #[serde(default)] pub vars: BTreeMap<String, String>,
    #[serde(default)] pub components: Vec<Component>,
}

#[derive(Deserialize)]
#[serde(deny_unknown_fields)]
pub struct Component {
    pub name: String,
    #[serde(default)] pub description: Option<String>,
    #[serde(default)] pub default: bool,
    #[serde(default)] pub requires: Vec<String>,
    #[serde(default)] pub when: Cond,
    #[serde(default)] pub unless: Cond,

    #[serde(default)] pub packages: Vec<String>,
    #[serde(default)] pub repos:    Vec<Repo>,
    #[serde(default)] pub fetch:    Vec<Fetch>,
    #[serde(default)] pub files:    Vec<FileEntry>,
    #[serde(default)] pub links:    Vec<LinkEntry>,
    #[serde(default)] pub lines:    Vec<LineEntry>,
    #[serde(default)] pub services: Vec<String>,
    #[serde(default)] pub groups:   Vec<String>,
    #[serde(default)] pub commands: Vec<CommandEntry>,
}

#[derive(Deserialize, Default)]
#[serde(deny_unknown_fields)]
pub struct Cond {
    pub command: Option<String>,
    pub path: Option<String>,
    pub file_contains: Option<FileMatch>,
}
```

Notes:

- `deny_unknown_fields` is where most of the schema value is. A typo like
  `packagees` becomes a parse error instead of a silent no-op.
- **Gotcha**: serde rejects `#[serde(flatten)]` together with
  `deny_unknown_fields`. So `when`/`unless` cannot be factored into a generic
  `Guarded<T>` wrapper while keeping strict fields. Repeat the two fields in
  each action struct (a small macro handles it). Strictness is worth more than
  the deduplication.
- Wrap `Component.name` in `toml::Spanned<String>` so `validate` can report
  `manifest.toml:47 unknown component "hyprland" in requires`.

## 4. CLI surface (clap 4, derive)

```
canarchy install [COMPONENTS]...   # empty = interactive picker seeded with default = true
        --all                      # everything, including non-default
        --skip <NAME>...
        --dry-run                  # print the plan, touch nothing
        -y, --yes                  # no picker, no confirmation
canarchy update  [COMPONENTS]...   # pacman -Syu + re-run file/link/line/command actions
canarchy list                      # components, default flag, description, satisfied?
canarchy status                    # per-action: satisfied / missing
canarchy validate                  # parse, resolve requires, detect cycles, exit 0/1
canarchy sync-back                 # port of sync-back.sh
canarchy wallpapers                # port of download-wallpapers.sh

global: -v/-vv, -q, --manifest <PATH>, --color <auto|always|never>, --no-sudo
```

`status` is the payoff: the ~30 hand-written `commandExists` / `[ -d ]` guards
collapse into one `is_satisfied()` per action type, and dry-run comes free.

## 5. Crates

| need       | crate                           | note                                                  |
| ---------- | ------------------------------- | ----------------------------------------------------- |
| args       | `clap` (features: derive, env)  |                                                       |
| schema     | `serde` + `toml`                | toml 0.8 for `Spanned`                                |
| errors     | `anyhow` + `thiserror`          | anyhow at the boundary, thiserror for manifest errors |
| color      | `owo-colors` + `supports-color` | honors `NO_COLOR` and non-tty                         |
| http       | `ureq`                          | blocking, rustls, no tokio. Do not pull in `reqwest`  |
| which      | `which`                         | replaces `commandExists`                              |
| paths      | `dirs` or `etcetera`            | `$XDG_CONFIG_HOME` fallback                           |
| expansion  | `shellexpand`                   | `$HOME`, `~`. Do `{{vars}}` with a regex              |
| prompts    | `dialoguer`                     | `MultiSelect` component picker                        |
| progress   | `indicatif`                     | optional, downloads only                              |
| glob dests | `glob`                          | only if we want `*.default*` style paths              |

Shell out to `git` and `unzip`/`bsdtar` rather than pulling `git2` and `zip`.
Both are already dependencies of the install, and libgit2 doubles build time.

Skip `tracing`, it is overkill. A ~40 line `log.rs` maps 1:1 onto `colors.sh`:

```rust
macro_rules! info    { ($($a:tt)*) => { println!("{} {}", "ℹ".blue().bold(), format!($($a)*)) } }
macro_rules! ok      { ($($a:tt)*) => { println!("{} {}", "✔".green(),        format!($($a)*)) } }
macro_rules! warn    { ($($a:tt)*) => { println!("{} {}", "⚠".yellow().bold(), format!($($a)*)) } }
macro_rules! fail    { ($($a:tt)*) => { eprintln!("{} {}", "✖".red(),          format!($($a)*)) } }
macro_rules! section { ($($a:tt)*) => { println!("{} {}", " INFO ".black().on_blue().bold(), format!($($a)*)) } }
```

## 6. Module layout

```
src/
  main.rs          dispatch
  cli.rs           clap structs
  log.rs           macros above
  manifest/
    schema.rs      serde types
    load.rs        read, validate, resolve requires (topo sort + cycle detection)
    expand.rs      {{vars}} and $ENV expansion
  plan.rs          selection -> Vec<Box<dyn Action>>, evaluates when/unless
  action/
    mod.rs         trait Action
    packages.rs    batches all selected packages into ONE pacman call
    files.rs links.rs lines.rs repos.rs fetch.rs services.rs groups.rs command.rs
  exec.rs          Command wrapper: sudo, cwd, env, dry-run gate, output streaming
  sudo.rs          `sudo -v` upfront + keepalive thread
```

The `Action` trait is the load-bearing piece:

```rust
trait Action {
    fn describe(&self) -> String;               // --dry-run
    fn is_satisfied(&self) -> Result<bool>;     // status + idempotency
    fn apply(&self, ctx: &Ctx) -> Result<Changed>; // Changed feeds only_if_changed
}
```

## 7. Known traps

1. **`source "$HOME/.cargo/env"` has no Rust equivalent.** Every `Command` is a
   fresh process. Need an explicit env layer in `exec.rs`: prepend
   `~/.cargo/bin`, `~/.local/bin`, `~/.bun/bin` to the child `PATH`, and
   re-resolve `which` on every check rather than caching at startup. Otherwise
   `unless.command = "starship"` fails immediately after installing starship.

2. **sudo.** Bash prompts whenever the timestamp expires, mid-run. Do `sudo -v`
   once at start with a keepalive thread. Hard-refuse to run the whole binary as
   root, since `$HOME` would be `/root` and every user config would land in the
   wrong place.

3. **Bootstrap chicken-and-egg.** A fresh minimal Arch has no rustc, so we
   cannot start from a Rust binary. Keep a 5 line `bootstrap.sh`:

   ```sh
   sudo pacman -S --needed --noconfirm rust git
   cargo build --release && ./target/release/canarchy install "$@"
   ```

   Longer term, a PKGBUILD publishing `canarchy` to the AUR, which is how
   caelestia solves it (`paru -S caelestia-cli && caelestia install`).

4. **Package batching ordering.** Collect `packages` from all selected
   components into a single `pacman -S --needed --noconfirm` call, but only
   after `when`/`unless` conditions have been evaluated, otherwise we install
   packages for components that end up skipped.

## 8. Effort and staging

Roughly 1200 to 1600 lines total.

- **Slice 1** (~400 lines): `packages` + `files` + `commands`, subcommands
  `install` / `list` / `--dry-run`. Already replaces ~70% of `install.sh`.
- **Slice 2**: `repos` + `fetch` + `links` + `lines`, 40 to 80 lines each.
- **Slice 3**: `services` + `groups`, `status`, `update`, `validate`.
- **Slice 4**: port `sync-back.sh` and `download-wallpapers.sh` as subcommands,
  delete the bash scripts.

`install.sh` stays working the whole time and is only deleted at the end of
slice 3.

## 9. Alternatives considered

- **chezmoi**: handles file mapping, templating, `.chezmoiexternal.toml` for
  downloads and clones, `run_once_*.sh` for the `curl | sh` installers. Closest
  off-the-shelf match, but weak on the root-side work (`/etc/greetd`,
  `systemctl enable`, `usermod -aG docker`).
- **Ansible** with `community.general.pacman`: genuinely idempotent, handles
  both user and system scope, has `--check`. Heavier, and a YAML playbook is
  less fun than a Rust CLI for a stream project.
- **Nix / home-manager**: fully declarative, but a large detour on Arch.
