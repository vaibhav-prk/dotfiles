#!/usr/bin/env bash

source "$(dirname "${BASH_SOURCE[0]}")/../../utils/helpers.sh"

# Format: "app_id|display_name"
flatpak_apps=(
  "app.zen_browser.zen|Zen Browser"
  "net.davidotek.pupgui2|ProtonUP-Qt"
  "com.mattjakeman.ExtensionManager|ExtensionManager"
)

for app_entry in "${flatpak_apps[@]}"; do
  IFS='|' read -r app_id app_name <<<"$app_entry"
  install_flatpak "$app_id" "$app_name"
done

print_section_complete "Flatpak Apps installation complete!"
