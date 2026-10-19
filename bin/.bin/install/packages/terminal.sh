#!/usr/bin/env bash

source "$(dirname "${BASH_SOURCE[0]}")/../helpers.sh"

packages=(
  zsh
  #ghostty
  kitty
  #tmux
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

# Install JetBrainsMono Nerd Fornt
echo ""
echo -e "${BLUE}[Installing]${NC} JetBrainsMono Nerd Font"

if [[ -d "$HOME/.fonts/JetBrainsMono" ]]; then
  print_warning "JetBrainsMono Nerd Font already installed"
elif ! cd "$HOME/Downloads"; then
  print_error "Failed to change to Downloads directory. Skipping font installation."
elif ! wget https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.tar.xz; then
  print_error "Failed to download fonts."
else
  mkdir -p "$HOME/.fonts/JetBrainsMono"
  tar -xf JetBrainsMono.tar.xz -C ~/.fonts/JetBrainsMono
  rm JetBrainsMono.tar.xz
  print_success "JetBrainsMono Nerd Font installed"
fi
print_separator

# Create .tmux/plugins folder and clone tmp
# echo ""
# if [[ ! -d "$HOME/.tmux/plugins/tpm" ]]; then
#   git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
# else
#   print_warning "TPM already installed"
# fi
#
# print_separator

echo -e "${BLUE}[Installing]${NC} herdr and herdr plugins"
if curl -fsSL https://herdr.dev/install.sh | sh; then
  export PATH="$HOME/.local/bin:$PATH"
  herdr plugin install cloudmanic/herdr-plus --yes
  herdr plugin install qu8n/herdr-automatic-rename --yes
  herdr plugin install jwarykowski/shepherd --yes
  herdr plugin install rjyo/herdr-window-title-sync --yes
  print_success "herdr and plugins installed"
else
  print_error "Failed to install herdr"
fi
print_separator

print_section_complete "Terminal tools installation complete!"
