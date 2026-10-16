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
  rpm -qa --qf '%{NAME}\n' |
    awk '{print $0 "\t[rpm]"}' |
    grep -v -E '^(lib|font|glibc|kernel|systemd|dbus|NetworkManager|grub|dracut)' |
    grep -v -E '(devel|debug|doc|lang|headers)$'

  if command -v flatpak >/dev/null 2>&1; then
    flatpak list --app --columns=application 2>/dev/null |
      awk 'NF { print $0 "\t[flatpak]" }'
  fi
} | sort -u >"$tmp"

selected=$(
  fzf \
    --disabled \
    --delimiter=$'\t' \
    --with-nth=1 \
    --prompt='Remove package > ' \
    --header='Enter: remove | Esc or Ctrl+C: cancel' \
    --bind="start:reload(cat '$tmp')" \
    --bind="change:reload(grep -iF -- {q} '$tmp' || true)" \
    --preview='
            if [[ {2} == "[flatpak]" ]]; then
                flatpak info {1} 2>/dev/null
            else
                rpm -qi {1} 2>/dev/null
            fi
        ' \
    --preview-window='down:50%' \
    --border=rounded \
    --height=100% \
    </dev/null
) || exit 0

[[ -n "$selected" ]] || exit 0

IFS=$'\t' read -r name source <<<"$selected"

if [[ -z "$name" || -z "$source" ]]; then
  printf 'Could not determine package name and source: %s\n' "$selected" >&2
  exit 1
fi

printf '\nSelected: %s %s\n' "$name" "$source"

case "$source" in
'[flatpak]')
  flatpak uninstall --delete-data "$name"
  ;;
'[rpm]')
  sudo dnf remove "$name"
  ;;
*)
  printf 'Unknown package source: %s\n' "$source" >&2
  exit 1
  ;;
esac
