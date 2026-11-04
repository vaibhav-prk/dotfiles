#!/usr/bin/env bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/utils/helpers.sh"

if ! command -v stow >/dev/null 2>&1; then
  error "GNU: Stow not installed."
  info "Install that using dnf install stow"
  return 1 2>/dev/null || exit 1
fi

# Define the paths of the files and directories to be removed
FILES=(
  "$HOME/.zshrc"
)

FOLDERS=(
  "$HOME/.config/nvim"
  "$HOME/.config/starship"
  "$HOME/.config/fastfetch"
  "$HOME/.config/kitty"
  "$HOME/.config/zsh-syntax-highlighting"
  "$HOME/.config/zsh-autosuggestions"
)

# Function to safely remove files
remove_file() {
  local target="${1:-}"
  if [ -n "$target" ] && ([ -f "$target" ] || [ -L "$target" ]); then
    warn "Removing file: $target"
    rm -r "$target"
  else
    warn "No file found: $target"
  fi
}

# Function to safely remove directories
remove_directory() {
  local target="${1:-}"
  if [ -n "$target" ] && [ -d "$target" ]; then
    warn "Removing directory: $target"
    rm -rf "$target"
  else
    warn "No directory found: $target"
  fi
}

# Remove files
for FILE in "${FILES[@]}"; do
  remove_file "$FILE"
done

# Remove directories
for DIR in "${FOLDERS[@]}"; do
  remove_directory "$DIR"
done

success "Cleanup complete."

DOTFILES_DIR="${HOME}/dotfiles"
if [[ ! -d "$DOTFILES_DIR" ]]; then
  error "Dotfiles directory not found at $DOTFILES_DIR"
  return 1 2>/dev/null || exit 1
fi

pushd "$DOTFILES_DIR" >/dev/null || {
  error "Failed to change directory to $DOTFILES_DIR"
  return 1 2>/dev/null || exit 1
}

PACKAGES=(
  bin
  kitty
  nvim
  starship
  zsh
  zsh-plugins
  fastfetch
  herdr
  git
  aria2
)

for pkg in "${PACKAGES[@]}"; do
  stow -v "$pkg"
done

popd >/dev/null

success "Stowing complete"
