#!/usr/bin/env bash

source "$HOME/.bin/utils/colors.sh"

if ! command -v stow >/dev/null 2>&1; then
  error "GNU: Stow not installed."
  info "Install that using dnf install stow"
  exit 1
fi

# Define the paths of the files and directories to be removed
FILES=(
  "$HOME/.zshrc"
  "$HOME/.tmux.conf"
)

FOLDERS=(
  "$HOME/.config/ghostty"
  "$HOME/.config/nvim"
  "$HOME/.config/starship"
  "$HOME/.config/fastfetch"
  "$HOME/.config/kitty"
  "$HOME/.config/zsh-syntax-highlighting"
  "$HOME/.config/zsh-autosuggestions"
)

# Function to safely remove files
remove_file() {
  if [ -f "$1" ] || [ -L "$1" ]; then
    warn "Removing file: $1"
    rm -r "$1"
  else
    warn "No file found: $1"
  fi
}

# Function to safely remove directories
remove_directory() {
  if [ -d "$1" ]; then
    warn "Removing directory: $1"
    rm -rf "$1"
  else
    warn "No directory found: $1"
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

# Use stow to create symlinks for each package
cd "$HOME/dotfiles" || {
  error "Failed to change directory"
  error "Exiting"
  exit 1
}
pwd

PACKAGES=(
  bin
  #ghostty
  kitty
  nvim
  starship
  #tmux
  zsh
  zsh-plugins
  fastfetch
  herdr
  git
)

for pkg in "${PACKAGES[@]}"; do
  stow -v "$pkg"
done

success "Stowing complete"
