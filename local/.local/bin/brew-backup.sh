#!/bin/zsh
# Dumps current Homebrew state (taps, formulae, casks) to a Brewfile in dotfiles.

set -euo pipefail

DOTFILES_DIR="${DOTFILES_DIR:-$HOME/dotfiles}"
BREWFILE="$DOTFILES_DIR/Brewfile"

echo "Backing up Homebrew packages to $BREWFILE..."
brew bundle dump --file="$BREWFILE" --force --describe --no-vscode

echo "Done. $(grep -c '^brew' "$BREWFILE") formulae, $(grep -c '^cask' "$BREWFILE") casks saved."
