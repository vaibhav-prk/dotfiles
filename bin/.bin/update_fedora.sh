#!/usr/bin/env bash

source "$HOME/.bin/utils/colors.sh"

#This script updates system and software
DNF=false
FLATPAK=false

check_updates() {
  info "Checking for system updates..."
  sudo dnf check-update
  dnf_exit=$?

  if [[ $dnf_exit -ne 0 && $dnf_exit -ne 100 ]]; then
    error "Failed to check for system updates!"
    exit 1
  fi

  info "\nChecking for Flatpak updates..."
  flatpak remote-ls --updates || {
    error "Failed to check for Flatpak updates!"
    exit 1
  }

  info "\nChecking for firmware updates..."
  sudo fwupdmgr get-updates
  local fw_exit=$?
  if [[ $fw_exit -ne 0 && $fw_exit -ne 2 ]]; then
    error "Failed to check for firmware updates!"
    exit 1
  fi

  exit 0
}

while [[ $# -gt 0 ]]; do
  case $1 in
  -d)
    DNF=true
    shift
    ;;
  -f)
    FLATPAK=true
    shift
    ;;
  -c)
    check_updates
    ;;
  -fr)
    sudo fwupdmgr update || {
      error "Firmware update failed!"
      exit 1
    }
    exit 0
    ;;
  *)
    warn "unrecognized option '$1'"
    warn "Usage: update [-d] [-f] [-c] [-fr]"
    warn "  -d  Update system packages via DNF"
    warn "  -f  Update Flatpak packages"
    warn "  -c Check for updates only"
    warn "  -fr Update firmware via fwupdmgr"
    exit 1
    ;;
  esac
done

if ! $DNF && ! $FLATPAK; then
  DNF=true
  FLATPAK=true
fi
info "Starting the update process..."

if $DNF; then
  info "Updating system packages..."
  sudo dnf update -y || {
    error "System update failed!"
    exit 1
  }
fi

if $FLATPAK; then
  info "\nUpdating Flatpak packages..."
  flatpak update -y || {
    error "Flatpak update failed!"
    exit 1
  }
fi

# clean up old packages via the clean.sh script
if [ -x ~/.bin/clean.sh ]; then
  ~/.bin/clean.sh
fi
