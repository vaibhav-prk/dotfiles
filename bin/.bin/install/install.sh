#!/usr/bin/env bash

set -e # exit on error

# Cleanup function for graceful exit
cleanup() {
  echo ""
  echo ""
  echo -e "${RED}╔════════════════════════════════════════╗${NC}"
  echo -e "${RED}║  Installation interrupted by user.     ║${NC}"
  echo -e "${RED}║  Exiting...                            ║${NC}"
  echo -e "${RED}╚════════════════════════════════════════╝${NC}"
  exit 1
}

# Trap Ctrl+C and call cleanup
trap cleanup SIGINT

CURR_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source helper functions
source "$CURR_DIR/../utils/helpers.sh"

print_header "Starting Installation Process"

# Enable repository

print_section "Setting up repositories"
source "$CURR_DIR/repos/vscode.sh"
source "$CURR_DIR/repos/coprs.sh"
source "$CURR_DIR/repos/flatpak.sh"
source "$CURR_DIR/repos/docker.sh"

# Install packages
print_section "Installing packages"
source "$CURR_DIR/packages/terminal.sh"
source "$CURR_DIR/packages/development.sh"
source "$CURR_DIR/packages/desktop.sh"

# Install flatpak apps
print_section "Installing flatpak applications"
source "$CURR_DIR/packages/flatpak.sh"

print_header "Installation Complete!"
