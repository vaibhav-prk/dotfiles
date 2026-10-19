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
    dnf repoquery --available --qf '%{name} %{version}\n' 2>/dev/null |
      awk '!seen[$0]++ { 
      split($0, fields, " ")
      printf "%s\t%s\t[rpm]\n", fields[1], fields[2]
    } '
    if command -v flatpak >/dev/null 2>&1; then
      flatpak remote-ls flathub --app \
        --columns=application,version 2>/dev/null |
        awk 'NF >= 2 { printf "%s\t%s\t[flatpak]\n", $1, $2 }'
    fi
  } | sort -t $'\t' -k1,1 -k2,2Vr >"$tmp" || {
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
    --exact \
    --layout=reverse \
    --border=rounded \
    --delimiter=$'\t' \
    --with-nth=1,2 \
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
      if [[ {3} == "[flatpak]" ]]; then
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

while IFS=$'\t' read -r package version source; do
  [[ -z "$package" ]] && continue

  case "$source" in
  '[rpm]') rpm_packages+=("$package-$version") ;;
  '[flatpak]') flatpak_packages+=("$package") ;;
  *)
    printf 'Unknown package source.\n' >&2
    exit 1
    ;;
  esac
done <<<"$selected"

if ((${#rpm_packages[@]})); then
  printf 'Installing RPM pacakage(s):\n'
  printf ' %s\n' "${rpm_packages[@]}"
  sudo dnf install "${rpm_packages[@]}"
fi

if ((${#flatpak_packages[@]})); then
  printf 'Installing Flatpak applications:\n'
  printf '  %s\n' "${flatpak_packages[@]}"
  flatpak install flathub "${flatpak_packages[@]}"
fi
