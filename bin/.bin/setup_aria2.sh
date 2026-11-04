#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "$SCRIPT_DIR/utils/helpers.sh"

info "Setting up aria2 env file."

CONFIG_DIR="$HOME/.config"
ENV_FILE="$CONFIG_DIR/aria2.env"

mkdir -p "$CONFIG_DIR"

if [[ -f "$ENV_FILE" ]]; then
  warn "aria2 environment file already exists."
  chmod 600 "$ENV_FILE"
  return 0 2>/dev/null || exit 0
fi

SECRET=$(openssl rand -hex 32)

umask 077
cat >"$ENV_FILE" <<EOF
ARIA2_RPC_SECRET=$SECRET
EOF

chmod 600 "$ENV_FILE"

success "aria2 RPC secret generated."
info "Environment file: $ENV_FILE"
