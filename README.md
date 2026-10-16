# Termux-Desktop-Hangover

Scripts that turn Termux into a Linux desktop (KDE Plasma, MATE or XFCE over
Termux:X11) with [Hangover](https://github.com/AndreRH/hangover) Wine for
running Windows apps, plus my shell and editor setup.

## Before you start

`install.sh` does **not** install these, so install them first:

1. `git`
2. `neovim` (optional: `setup-nvim.sh` only warns if it is missing)

`zsh` and `nodejs-lts` are installed by `install.sh` itself (see `packages`).

## Install

```sh
git clone https://github.com/mfgbhatti/Termux-Desktop-Hangover
cd Termux-Desktop-Hangover
./install.sh
```

`install.sh` asks for confirmation once, then:

1. loads the package lists from `packages`
2. installs the chosen desktop, the base, GUI and GPU packages, and Hangover Wine
3. creates the `tx11start` and `tx11stop` commands and a desktop entry
4. writes a fontconfig file and the Termux extra keys
5. installs `mason-installer`
6. runs `setup-zsh.sh`, then `setup-nvim.sh`

Choices are variables at the top of `install.sh`:

| Variable | Values | Meaning |
| -------- | ------ | ------- |
| `USE_PACMAN` | `true` / `false` | Use `pacman` (Termux pacman) or `pkg` |
| `DESKTOP` | `plasma` / `mate` / `xfce` | Desktop environment to install |
| `INSTALL_WINE` | `true` / `false` | Install Hangover and run `hangover-wine` |

## Files

| File | What it does |
| ---- | ------------ |
| `install.sh` | Main installer |
| `packages` | Package lists (base, GUI, GPU, desktops, Hangover) |
| `hangover-wine` | Wine setup: `wine`/`wineserver` links, winetricks, launcher wrappers |
| `setup-zsh.sh` | Clones [hastre](https://github.com/mfgbhatti/hastre) to `~/.config/zsh` and runs its `hastre-setup`; sets up XDG dirs, npm and wget config, starship, default shell |
| `setup-nvim.sh` | Clones [Sokha](https://github.com/mfgbhatti/Sokha) to `~/.config/nvim` and installs its language servers (needs npm) |
| `mason-installer` | Installs a package with `pkg`/`pacman` and registers it for Mason in Neovim |
| `old/` | Previous version of the installer |

`setup-zsh.sh` and `setup-nvim.sh` can also be run on their own. Both update an
existing checkout instead of cloning again, and move aside a folder that is not
a git checkout.

## Usage

Start and stop the desktop:

```sh
tx11start
tx11stop
```

Run Windows programs with a chosen emulation backend (`hw*` wraps `wine`, `wt*`
wraps `winetricks` with the same backends):

| Command | Backend |
| ------- | ------- |
| `hwfex` / `wtfex` | FEX for x64 and x86 |
| `hw64fex` / `wt64fex` | FEX for x64 only |
| `hw32fex` / `wt32fex` | FEX for x86 only |
| `hwcpu` / `wtcpu` | Native WoW64 CPU for x86 |
| `hwbox` / `wtbox` | Box64-based x86 emulation |

```sh
hwfex setup.exe
wtfex corefonts
```

Install a tool and make it visible to Neovim's Mason:

```sh
mason-installer shfmt
mason-installer lua-language-server
mason-installer <package> [executable-name]
```

## Notes

- Paths assume Termux (`/data/data/com.termux/files/usr`).
- `hangover-wine` also writes a Photoshop `.desktop` entry that expects Adobe
  Photoshop CC 2017 (32 bit) in the default Wine prefix. Remove it from the
  script if you do not use it.
