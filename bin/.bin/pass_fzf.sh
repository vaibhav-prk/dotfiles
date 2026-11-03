#! /usr/bin/env bash

source "$HOME/.bin/utils/colors.sh"

# Use pass with fzf to fuzzy find password

copy=false

while getopts ":c" opt; do
  case $opt in
  c)
    copy=true
    ;;
  \?)
    warn "unrecognized option '-$OPTARG'"
    warn "Usage: pass"
    warn "No arguments show the password"
    warn "Usage: passf [-c]"
    warn "  -c  Copy the password to the clipboard"
    exit 1
    ;;
  esac
done

entry=$(pass git ls-files '*.gpg' | sed 's/\.gpg$//' | fzf)

if [ -z "$entry" ]; then
  exit 1
fi

if [ "$copy" = true ]; then
  pass show "$entry" | xclip -selection clipboard
  success "Password for '$entry' copied to clipboard."
else
  # No option given -> show password
  pass show "$entry"
fi
