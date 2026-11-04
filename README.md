# Fedora Workstation

This repository contains my personal dotfiles and setup scripts for configuring a consistent development environment across multiple Fedora machines.

## What This Repository Does

- Installs essential packages and tools using DNF and Flatpak.
- Configures applications by managing symlinks with GNU Stow.
- Automates system setup using Bash scripts or Ansible.
- Provides a reproducible development environment across Fedora installations.

## Included Configurations

- **Zsh** – Shell configuration
- **Tmux** – Terminal multiplexer
- **Neovim** – LazyVim configuration
- **Kitty** – Terminal emulator
- **Starship** – Shell prompt
- **fastfetch** – System information
- **herdr** – Plugin manager
- **Zsh Plugins** – Shell extensions
- **aria2** - Download Manager
- **Custom Scripts** – Personal utility scripts

## Installation

There are two ways to set up this environment: using Bash scripts or Ansible. Choose either method depending on your preference.

### Using Bash Scripts

Clone the repository into your home directory:

```bash
git clone https://github.com/vaibhav-prk/dotfiles.git ~/dotfiles
```

Navigate to the setup scripts directory:

```bash
cd ~/dotfiles/bin/.bin
```

Run the setup script:

```bash
./setup_fedora.sh
```

Restart your terminal for the changes to take effect.

### Using Ansible

Install Ansible:

```bash
sudo dnf install ansible
```

Navigate to the Ansible directory:

```bash
cd ~/dotfiles/ansible
```

Run the playbook:

```bash
ansible-playbook setup.yml
```

## Customization

You can customize the packages and configurations installed by the setup scripts.

**Bash scripts:**

```bash
cd ~/dotfiles/bin/.bin/install/packages/
```

**Ansible:**

Modify the default variables in the respective role directories:

```text
ansible/roles/<role_name>/defaults/main.yml
```

## Notes

- **Fedora-specific:** This setup is designed and tested for Fedora Linux.
- **Idempotent:** The setup scripts and Ansible tasks are designed to be safely re-run where possible.
- **GNU Stow:** Configuration files are managed using symlinks, making it easier to maintain and synchronize configurations across machines.
