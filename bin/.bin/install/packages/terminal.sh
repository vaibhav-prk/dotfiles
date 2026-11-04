#!/usr/bin/env bash

source "$(dirname "${BASH_SOURCE[0]}")/../../utils/helpers.sh"

packages=(
  zsh
  kitty
  vim
  bat
  fzf
  fastfetch
  yazi
  stow
  starship
  tldr
  btop
  pass
  aria2
)

docker=(
  docker-ce
  docker-ce-cli
  containerd.io
  docker-buildx-plugin
  docker-compose-plugin
)

# Install terminal packages
for pkg in "${packages[@]}"; do
  install_dnf_package "$pkg"
done

for pkg in "${docker[@]}"; do
  install_dnf_package "$pkg"
done

# Install JetBrainsMono Nerd Font
echo ""
echo -e "${BLUE}[Installing]${NC} JetBrainsMono Nerd Font"

if [[ -d "$HOME/.fonts/JetBrainsMono" ]]; then
  print_warning "JetBrainsMono Nerd Font already installed"
else
  mkdir -p "$HOME/Downloads"
  if (
    cd "$HOME/Downloads" &&
      wget -q --show-progress https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.tar.xz &&
      mkdir -p "$HOME/.fonts/JetBrainsMono" &&
      tar -xf JetBrainsMono.tar.xz -C "$HOME/.fonts/JetBrainsMono" &&
      rm -f JetBrainsMono.tar.xz
  ); then
    print_success "JetBrainsMono Nerd Font installed"
  else
    print_error "Failed to install JetBrainsMono Nerd Font"
  fi
fi
print_separator

# Download Babita Modern Classic Cursor
echo ""
echo -e "${BLUE}[Installing]${NC} Bibata Modern Classic Cursor"

if [[ -d "$HOME/.local/share/icons/Bibata-Modern-Classic" ]]; then
  print_warning "Bibata Modern Classic Cursor already installed"
else
  mkdir -p "$HOME/Downloads"
  if (
    cd "$HOME/Downloads" &&
      wget -q --show-progress https://github.com/ful1e5/Bibata_Cursor/releases/download/v2.0.7/Bibata-Modern-Classic.tar.xz &&
      mkdir -p "$HOME/.local/share/icons" &&
      tar -xf Bibata-Modern-Classic.tar.xz -C "$HOME/.local/share/icons" &&
      rm -f Bibata-Modern-Classic.tar.xz
  ); then
    print_success "Bibata Modern Classic Cursor installed"
  else
    print_error "Failed to install Bibata Modern Classic Cursor"
  fi
fi
print_separator

echo -e "${BLUE}[Installing]${NC} herdr and herdr plugins"
if curl -fsSL https://herdr.dev/install.sh | sh; then
  export PATH="$HOME/.local/bin:$PATH"
  herdr plugin install cloudmanic/herdr-plus --yes
  herdr plugin install qu8n/herdr-automatic-rename --yes
  print_success "herdr and plugins installed"
else
  print_error "Failed to install herdr"
fi
print_separator

print_section_complete "Terminal tools installation complete!"
