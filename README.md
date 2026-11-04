# Fedora Workstation

This repository contains my personal configuration files and setup scripts for various tools, ensuring a consistent setup across different Fedora machines.

## What This Repo Does

- Automatically installs all required packages (shell, terminal, tools, fonts, etc.) on Fedora via DNF and Flatpak
- Sets up configuration files using GNU Stow to create symlinks
- Provides a reproducible environment for Zsh, Neovim (LazyVim), Herdr, Kitty/Ghostty, and more

## Included Configurations

- **Zsh**
- **Tmux**
- **Neovim (LazyVim)**
- **Kitty Terminal**
- **Ghostty Terminal**
- **Starship**
- **fastfetch**
- **herdr**
- **Zsh-plugins**
- **Custom Scripts**

## Installation

### Using bash scripts

Clone this repository to your home directory

```
git clone https://github.com/VaibhavPrakash0503/dotfiles.git ~/dotfiles
```

Move into the dotfiles directory (inside bin) run this command

```
cd dotfiles/bin/.bin
```

Run the bash script

```
./setup_fedora.sh
```

Restart your terminal for all changes to take effect.

## Using ansible script

Install ansible on your Fedora machine

```
sudo dnf install ansible
```

Move in dotfiles dir and inside ansible

```
cd dotfiles/ansible
```

Run the ansible playbook

```
anisble-playbook setup.yml
```

## Notes

- **Fedora-specific**: This setup is designed and tested for Fedora Linux
- The scripts are idempotent where possible, so you can re-run them when setting up new machines

To customize what is being installed checkout these scripts

For bash

```
cd dotfiles/bin/.bin/install/packages/
```

For ansible

defaults dir in each role
