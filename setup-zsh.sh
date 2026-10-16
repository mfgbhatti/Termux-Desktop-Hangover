#!/data/data/com.termux/files/usr/bin/bash
set -e

# Assumes git and zsh are already installed.
HASTRE_REPO="${HASTRE_REPO:-https://github.com/mfgbhatti/hastre}"

for cmd in git zsh; do
  command -v "$cmd" >/dev/null 2>&1 || {
    echo "Error: $cmd is not installed / in path." >&2
    exit 1
  }
done

# Clean
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_STATE_HOME="$HOME/.local/state"

# hastre-setup requires the checkout to live at $XDG_CONFIG_HOME/zsh
# (the zshenv template points ZDOTDIR there).
HASTRE_DIR="$XDG_CONFIG_HOME/zsh"

echo "Creating xdg custom dirs"
mkdir -p "$XDG_CONFIG_HOME"
cat >"$XDG_CONFIG_HOME/user-dirs.dirs" <<'EOF'
XDG_DESKTOP_DIR="$HOME/Desktop"
EOF

echo "Creating xdg default dirs"
xdg-user-dirs-update

echo "Creating XDG directories for zsh"
mkdir -p "$XDG_CACHE_HOME/zsh"
mkdir -p "$XDG_STATE_HOME/zsh"
mkdir -p "$XDG_DATA_HOME/zsh"
mkdir -p "$XDG_CONFIG_HOME/npm"
mkdir -p "$XDG_CONFIG_HOME/wget"
mkdir -p "$XDG_DATA_HOME/wineprefixes"

cat >"$XDG_CONFIG_HOME/npm/npmrc" <<'EOF'
prefix=${XDG_DATA_HOME}/npm
cache=${XDG_CACHE_HOME}/npm
init-module=${XDG_CONFIG_HOME}/npm/config/npm-init.js
logs-dir=${XDG_STATE_HOME}/npm/logs
EOF

echo "hsts-file \= "$XDG_STATE_HOME"/wget-hsts" >>"$XDG_CONFIG_HOME/wget/wgetrc"

echo "Getting hastre (zsh config)"
if [ -d "$HASTRE_DIR/.git" ]; then
  echo "hastre already cloned, updating"
  git -C "$HASTRE_DIR" pull --ff-only ||
    echo "Warning: could not update hastre, using the existing checkout"
else
  if [ -e "$HASTRE_DIR" ] && [ -n "$(ls -A "$HASTRE_DIR" 2>/dev/null)" ]; then
    backup="$HASTRE_DIR.bak.$(date +%Y%m%d_%H%M%S)"
    echo "$HASTRE_DIR exists and is not a git checkout, moving it to $backup"
    mv "$HASTRE_DIR" "$backup"
  fi
  git clone "$HASTRE_REPO" "$HASTRE_DIR"
fi

# hastre-setup is a zsh script: it writes ~/.zshenv (XDG_* and ZDOTDIR) and
# installs templates/zshrc as $ZDOTDIR/.zshrc. Each step is safe to re-run.
# A ~/.zshenv that already works is left alone; a broken one is reported and
# left unchanged (re-run "hastre-setup zshenv --force" to replace it, a backup
# is kept).
echo "Setting up hastre: ~/.zshenv"
zsh "$HASTRE_DIR/tools/hastre-setup" zshenv --yes ||
  echo "Warning: ~/.zshenv needs attention, see the message above"

echo "Setting up hastre: .zshrc"
zsh "$HASTRE_DIR/tools/hastre-setup" zshrc --yes ||
  echo "Warning: .zshrc was not installed, see the message above"

echo "Checking hastre dependencies"
zsh "$HASTRE_DIR/tools/hastre-setup" deps ||
  echo "Warning: some required programs are missing, see the list above"

echo "Configuring starship with the pure preset"
starship preset pure-preset -o "$HOME/.config/starship.toml"

echo "Setting zsh as default shell"
chsh -s zsh

echo "done....."
