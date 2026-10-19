#!/usr/bin/env bash

for cmd in fzf dnf awk grep sort; do
  if ! command -v "$cmd" >/dev/null 2>&1; then
    printf 'Error: %s is required.\n' "$cmd" >&2
    exit 1
  fi
done

set -euo pipefail

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

case "${1:-}" in
-up | --update)
  echo "Updating cache..."
  refresh_cache
  ;;
esac

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
    --multi \
    --layout=reverse \
    --border=rounded \
    --delimiter=$'\t' \
    --with-nth=1 \
    --prompt='Search packages > ' \
    --header='Tab: toggle selection | Enter: install | Esc or Ctrl + C: exit' \
    --bind='tab:toggle+transform-header:
        printf "Tab: toggle selection | Enter: install | Esc or Ctrl + C: exit\n"
        if [[ -n "{+1}" && "$FZF_SELECT_COUNT" -gt 0 ]]; then
          printf "SELECTED PACKAGES\n%s\n" "{+1}"
          printf "-------------------------------\n"
        fi
    ' \
    --preview='
      if [[ {2} == "[flatpak]" ]]; then
        flatpak remote-info flathub {1} 2>/dev/null
      else
        dnf info {1} 2>/dev/null
      fi
    ' \
    --preview-window='right:55%:wrap:border-left' \
    --height=100% \
    <"$cache"
) || exit 0

rpm_packages=()
flatpak_packages=()

while IFS=$'\t' read -r package source; do
  [[ -z "$package" ]] && continue

  case "$source" in
  '[rpm]') rpm_packages+=("$package") ;;
  '[flatpak]') flatpak_packages+=("$package") ;;
  *)
    printf 'Unknown package source.\n' >&2
    exit 1
    ;;
  esac
done <<<"$selected"

if ((${#rpm_packages[@]})); then
  sudo dnf install "${rpm_packages[@]}"
fi

if ((${#flatpak_packages[@]})); then
  flatpak install flathub "${flatpak_packages[@]}"
fi
