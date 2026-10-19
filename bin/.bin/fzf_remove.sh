#!/usr/bin/env bash

for cmd in fzf dnf awk grep sort; do
  if ! command -v "$cmd" >/dev/null 2>&1; then
    printf 'Error: %s is required.\n' "$cmd" >&2
    exit 1
  fi
done

set -uo pipefail

tmp=$(mktemp) || exit 1
trap 'rm -f "$tmp"' EXIT

{
  rpm -qa --qf '%{NAME} %{VERSION}\n' |
    awk '!seen[$0]++ {
      split($0, fields, " ")
      printf "%s\t%s\t[rpm]\n", fields[1], fields[2]
    }' |
    grep -v -E '^(lib|font|glibc|kernel|systemd|dbus|NetworkManager|grub|dracut)' |
    grep -v -E '(devel|debug|doc|lang|headers)$'

  if command -v flatpak >/dev/null 2>&1; then
    flatpak list --app --columns=application,version 2>/dev/null |
      awk 'NF >= 2 { printf "%s\t%s\t[flatpak]\n", $1, $2 }'
  fi
} | sort -t $'\t' -k1,1 -k2,2Vr -u >"$tmp"

selected=$(
  fzf \
    --multi \
    --exact \
    --layout=reverse \
    --border=rounded \
    --delimiter=$'\t' \
    --with-nth=1,2 \
    --prompt='Search packages > ' \
    --header='Tab: toggle selection | Enter: remove | Esc or Ctrl+C: cancel' \
    --bind='tab:toggle+transform-header:
        printf "Tab: toggle selection | Enter: install | Esc or Ctrl + C: exit\n"
        if [[ -n "{+1}" && "$FZF_SELECT_COUNT" -gt 0 ]]; then
          printf "SELECTED PACKAGES\n%s\n" "{+1}"
          printf "-------------------------------\n"
        fi
    ' \
    --preview='
      if [[ {3} == "[flatpak]" ]]; then
        flatpak info {1} 2>/dev/null
      else
        rpm -qi {1} 2>/dev/null
      fi
    ' \
    --preview-window='right:55%:wrap:border-left' \
    --height=100% \
    <"$tmp"
) || exit 0

[[ -n "$selected" ]] || exit 0

rpm_packages=()
flatpak_packages=()

while IFS=$'\t' read -r name version source; do
  [[ -z "$name" ]] && continue

  case "$source" in
  '[rpm]') rpm_packages+=("$name-$version") ;;
  '[flatpak]') flatpak_packages+=("$name") ;;
  *)
    printf 'Unknown package source: %s\n' "$source" >&2
    exit 1
    ;;
  esac
done <<<"$selected"

if ((${#rpm_packages[@]})); then
  printf 'Removing RPM packages:\n'
  printf '  %s\n' "${rpm_packages[@]}"
  sudo dnf remove "${rpm_packages[@]}"
fi

if ((${#flatpak_packages[@]})); then
  printf 'Removing Flatpak applications:\n'
  printf '  %s\n' "${flatpak_packages[@]}"
  flatpak uninstall --delete-data "${flatpak_packages[@]}"
fi
