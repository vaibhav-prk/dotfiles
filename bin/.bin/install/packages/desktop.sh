#!/usr/bin/env bash

source "$(dirname "${BASH_SOURCE[0]}")/../../utils/helpers.sh"

packages=(
  gnome-tweaks
  vlc
)

for pkg in "${packages[@]}"; do
  install_dnf_package "$pkg"
done

# Install multimedia
echo ""
echo -e "${BLUE}[Installing]${NC} Multimedia support (group)"

if sudo dnf -y group install multimedia; then
  print_success "Multimedia support installed successfully"
else
  print_error "Failed to install multimedia support"
  return 1
fi
print_separator

print_section_complete "Desktop Apps installation complete!"
