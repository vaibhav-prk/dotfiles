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

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source helper functions
source "$SCRIPT_DIR/helpers.sh"

print_header "Starting Installation Process"

# Enable repository

print_section "Setting up repositories"
source "$SCRIPT_DIR/repos/vscode.sh"
source "$SCRIPT_DIR/repos/coprs.sh"
source "$SCRIPT_DIR/repos/flatpak.sh"
source "$SCRIPT_DIR/repos/docker.sh"

# Install packages
print_section "Installing packages"
source "$SCRIPT_DIR/packages/terminal.sh"
source "$SCRIPT_DIR/packages/development.sh"
source "$SCRIPT_DIR/packages/desktop.sh"

# Install flatpak apps
print_section "Installing flatpak applications"
source "$SCRIPT_DIR/packages/flatpak.sh"

print_header "Installation Complete!"
