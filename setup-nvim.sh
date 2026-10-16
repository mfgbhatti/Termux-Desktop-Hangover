#!/data/data/com.termux/files/usr/bin/bash
set -e

# Assumes git is already installed.
NVIM_REPO="${NVIM_REPO:-https://github.com/mfgbhatti/Sokha}"

export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
NVIM_DIR="$XDG_CONFIG_HOME/nvim"

command -v git >/dev/null 2>&1 || {
  echo "Error: git is not installed / in path." >&2
  exit 1
}

echo "Getting Sokha (nvim config)"
mkdir -p "$XDG_CONFIG_HOME"
if [ -d "$NVIM_DIR/.git" ]; then
  echo "Sokha already cloned, updating"
  git -C "$NVIM_DIR" pull --ff-only ||
    echo "Warning: could not update Sokha, using the existing checkout"
else
  if [ -e "$NVIM_DIR" ] && [ -n "$(ls -A "$NVIM_DIR" 2>/dev/null)" ]; then
    backup="$NVIM_DIR.bak.$(date +%Y%m%d_%H%M%S)"
    echo "$NVIM_DIR exists and is not a git checkout, moving it to $backup"
    mv "$NVIM_DIR" "$backup"
  fi
  git clone "$NVIM_REPO" "$NVIM_DIR"
fi

if ! command -v nvim >/dev/null 2>&1; then
  echo "Note: nvim is not installed yet (e.g. 'pacman -S neovim' or 'pkg install neovim')."
fi

# Language servers: Sokha's own installer (global npm packages). Use the same
# npmrc as the zsh config (hastre exports NPM_CONFIG_USERCONFIG), otherwise npm
# running under bash would ignore it and install into its default prefix.
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"
export XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
export XDG_STATE_HOME="${XDG_STATE_HOME:-$HOME/.local/state}"
if [ -f "$XDG_CONFIG_HOME/npm/npmrc" ]; then
  export NPM_CONFIG_USERCONFIG="$XDG_CONFIG_HOME/npm/npmrc"
fi

echo
echo "Installing language servers"
if [ ! -f "$NVIM_DIR/scripts/install_packages.sh" ]; then
  echo "Warning: $NVIM_DIR/scripts/install_packages.sh not found, skipping"
elif ! command -v npm >/dev/null 2>&1; then
  echo "Warning: npm is not installed, skipping language servers."
  echo "Install nodejs (e.g. 'pacman -S nodejs-lts'), then run:"
  echo "  bash $NVIM_DIR/scripts/install_packages.sh"
else
  bash "$NVIM_DIR/scripts/install_packages.sh" ||
    echo "Warning: language server install failed, re-run: bash $NVIM_DIR/scripts/install_packages.sh"
fi

echo
echo "Config is in $NVIM_DIR"
echo "Plugins are installed by nvim (vim.pack) the first time you start it."
echo "done....."
