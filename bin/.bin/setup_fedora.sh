#!/usr/bin/env bash

set -euo pipefail

BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "$BASE_DIR/utils/helpers.sh"

print_header "Setting Up Fedora Workstation"

# 1. Repositories and packages
source "$BASE_DIR/install/install.sh"

# 2. Dotfiles symlinks
print_section "Setting Up Dotfiles Symlinks"
source "$BASE_DIR/setup_symlinks.sh"

# 3. Aria2 configuration
print_section "Setting Up Aria2 Configuration"
source "$BASE_DIR/setup_aria2.sh"

print_section_complete "Fedora Setup Complete"
