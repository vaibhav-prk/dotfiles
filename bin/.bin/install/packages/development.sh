#!/usr/bin/env bash

source "$(dirname "${BASH_SOURCE[0]}")/../../utils/helpers.sh"

packages=(
  golang
  code
  lazygit
  neovim
  git
  direnv
)

for pkg in "${packages[@]}"; do
  install_dnf_package "$pkg"
done

# Ensure GOPATH/bin is in PATH
if [[ ":$PATH:" != *":$HOME/go/bin:"* ]]; then
  export PATH="$PATH:$HOME/go/bin"
fi

# Install lazydocker
echo ""
echo -e "${BLUE}[Installing]${NC} lazydocker"

if command -v lazydocker &>/dev/null; then
  print_warning "lazydocker already installed"
else
  if command -v go &>/dev/null; then
    go install github.com/jesseduffield/lazydocker@latest
    print_success "lazydocker installed to $HOME/go/bin/lazydocker"
  else
    print_error "Go is not installed, cannot install lazydocker"
    return 1
  fi
fi
print_separator

print_section_complete "Development tools installation complete!"
