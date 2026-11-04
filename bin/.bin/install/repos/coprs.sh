#!/usr/bin/env bash

source "$(dirname "${BASH_SOURCE[0]}")/../../utils/helpers.sh"

# Install dnf-plugins-core
echo ""
echo -e "${BLUE}[Installing]${NC} dnf-plugins-core"

if rpm -q dnf-plugins-core &>/dev/null; then
  print_warning "dnf-plugins-core already installed"
else
  if sudo dnf install -y dnf-plugins-core; then
    print_success "dnf-plugins-core installed successfully"
  else
    print_error "Failed to install dnf-plugins-core"
    return 1
  fi
fi
print_separator

# Array of COPR repos: "name|identifier"
coprs=(
  "Yazi|lihaohong/yazi"
  "Lazygit|dejan/lazygit"
  "Starship|atim/starship"
)

for copr_entry in "${coprs[@]}"; do
  IFS='|' read -r name identifier <<<"$copr_entry"

  if copr_enabled "$identifier"; then
    print_warning "$name COPR already enabled"
  else
    echo -e "${BLUE}[Enabling]${NC} $name COPR..."
    sudo dnf copr enable "$identifier" -y
    print_success "$name COPR enabled"
  fi
done
