#!/bin/bash
# i3wm dotfiles install script
# Run this after cloning the repo on a fresh Pop!_OS install

set -e

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="$HOME/.config/i3"
FONT_DIR="$HOME/.local/share/fonts/JetBrainsMono"

echo "==> Creating config directory..."
mkdir -p "$CONFIG_DIR"
mkdir -p "$FONT_DIR"
mkdir -p "$HOME/Pictures"

# ─── APT PACKAGES ────────────────────────────────────────────────────────────
echo "==> Installing apt packages..."
sudo apt update
sudo apt install -y \
    i3-wm i3status i3lock \
    alacritty zsh \
    rofi picom \
    feh imagemagick \
    scrot flameshot \
    brightnessctl playerctl \
    alsa-utils xinput x11-xserver-utils \
    copyq arandr \
    unzip curl git

# ─── RUST & CARGO TOOLS ──────────────────────────────────────────────────────
echo "==> Installing Rust via rustup..."
if ! command -v cargo &>/dev/null; then
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
    source "$HOME/.cargo/env"
fi

echo "==> Installing cargo tools..."
cargo install bluetui

# ─── NERD FONT ───────────────────────────────────────────────────────────────
echo "==> Installing JetBrainsMono Nerd Font..."
if [ ! -f "$FONT_DIR/JetBrainsMonoNerdFont-Regular.ttf" ]; then
    wget -q --show-progress \
        https://github.com/ryanoasis/nerd-fonts/releases/download/v3.2.1/JetBrainsMono.zip \
        -O /tmp/JetBrainsMono.zip
    unzip -q /tmp/JetBrainsMono.zip -d "$FONT_DIR"
    rm /tmp/JetBrainsMono.zip
    fc-cache -fv
else
    echo "    Font already installed, skipping."
fi

# ─── OH MY ZSH ───────────────────────────────────────────────────────────────
echo "==> Installing Oh My Zsh..."
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    RUNZSH=no CHSH=no \
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
else
    echo "    Oh My Zsh already installed, skipping."
fi

echo "==> Installing zsh plugins..."
ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

if [ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]; then
    git clone https://github.com/zsh-users/zsh-autosuggestions \
        "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
fi

if [ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]; then
    git clone https://github.com/zsh-users/zsh-syntax-highlighting \
        "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
fi

# ─── SET DEFAULT SHELL ───────────────────────────────────────────────────────
echo "==> Setting zsh as default shell..."
chsh -s "$(which zsh)"

# ─── SYMLINK CONFIGS ─────────────────────────────────────────────────────────
echo "==> Linking config files..."
ln -sf "$REPO_DIR/config"           "$CONFIG_DIR/config"
ln -sf "$REPO_DIR/i3status.conf"    "$CONFIG_DIR/i3status.conf"
ln -sf "$REPO_DIR/wallpaper.png"    "$CONFIG_DIR/wallpaper.png"
ln -sf "$REPO_DIR/lock_icon.png"    "$CONFIG_DIR/lock_icon.png"
ln -sf "$REPO_DIR/screen_lock.sh"   "$CONFIG_DIR/screen_lock.sh"
ln -sf "$REPO_DIR/protected_ws.sh"  "$CONFIG_DIR/protected_ws.sh"

chmod +x "$CONFIG_DIR/screen_lock.sh"
chmod +x "$CONFIG_DIR/protected_ws.sh"

# ─── CARGO PATH IN ZSHRC ─────────────────────────────────────────────────────
echo "==> Adding cargo to PATH in .zshrc..."
if ! grep -q 'cargo/bin' "$HOME/.zshrc" 2>/dev/null; then
    echo 'export PATH="$HOME/.cargo/bin:$PATH"' >> "$HOME/.zshrc"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Done! Log out and back in to apply."
echo "  Select i3 at the login screen."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
