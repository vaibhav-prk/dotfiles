#!/usr/bin/env bash

source "$(dirname "${BASH_SOURCE[0]}")/../../utils/helpers.sh"

if repo_enabled "docker"; then
  print_warning "Docker Repo already enabled."
  return 0
fi

print_section "Adding Docker repository."
sudo dnf config-manager addrepo --from-repofile "https://download.docker.com/linux/fedora/docker-ce.repo"
print_success "Docker repo added"
