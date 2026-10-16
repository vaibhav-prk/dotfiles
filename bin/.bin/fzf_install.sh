#!/usr/bin/env bash

source "$HOME/.bin/utils/colors.sh"

if ! command -v fzf >/dev/null 2>&1; then
  error "fzf not installed."
  info "Install fzf using dnf install fzf"
  exit 1
fi

set -euo pipefail

for cmd in fzf dnf awk grep sort; do
  if ! command -v "$cmd" >/dev/null 2>&1; then
    printf 'Error: %s is required.\n' "$cmd" >&2
    exit 1
  fi
done

cache_dir="${XDG_CACHE_HOME:-$HOME/.cache}/pkg-install"
cache="$cache_dir/packages.tsv"
mkdir -p "$cache_dir"

refresh_cache() {
  local tmp
  tmp=$(mktemp "$cache_dir/packages.XXXXXX")

  {
    dnf repoquery --available --qf '%{name}\n' 2>/dev/null |
      awk '!seen[$0]++ { print $0 "\t[rpm]" }'
    if command -v flatpak >/dev/null 2>&1; then
      flatpak remote-ls flathub --app \
        --columns=application 2>/dev/null |
        awk 'NF { print $0 "\t[flatpak]" }'
    fi
  } | sort -u >"$tmp" || {
    rm -f "$tmp"
    return 1
  }

  mv "$tmp" "$cache"
}

if [[ ! -s "$cache" || "$cache" -ot /etc/os-release ]]; then
  printf 'Loading package list from repositories...\n' >&2
  refresh_cache
fi

# Refresh the cache in the background when it is older than 24 hours.
if [[ -n "$(find "$cache" -mmin +1440 -print -quit 2>/dev/null)" ]]; then
  refresh_cache &
fi

selected=$(
  fzf \
    --disabled \
    --delimiter=$'\t' \
    --with-nth=1 \
    --prompt='Install package > ' \
    --header='Literal substring search | Enter: install | Esc: cancel' \
    --bind="start:reload(cat '$cache')" \
    --bind="change:reload(grep -iF -- {q} '$cache' || true)" \
    --preview='
            if [[ {2} == "[flatpak]" ]]; then
                flatpak remote-info flathub {1} 2>/dev/null
            else
                dnf info {1} 2>/dev/null
            fi
        ' \
    --preview-window='right:50%' \
    --border=rounded
) || exit 0

IFS=$'\t' read -r package source <<<"$selected"

case "$source" in
'[rpm]') sudo dnf install "$package" ;;
'[flatpak]') flatpak install flathub "$package" ;;
*)
  printf 'Unknown package source.\n' >&2
  exit 1
  ;;
esac
