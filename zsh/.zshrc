export PATH="$HOME/.local/bin:$HOME/go/bin:$HOME/.bin:$PATH"
# Default editor
export EDITOR="nvim"

# Starship prompt
eval "$(starship init zsh)"

HISTFILE=~/.history
HISTSIZE=10000
SAVEHIST=10000

setopt HIST_IGNORE_ALL_DUPS     # Don't record duplicate entries(Ignores all duplicates)
setopt HIST_REDUCE_BLANKS       # Remove extra blanks
setopt SHARE_HISTORY            # Share history across sessions
setopt EXTENDED_HISTORY         # Save timestamp info
setopt HIST_SAVE_NO_DUPS        # Don't write duplicates to history file
setopt HIST_EXPIRE_DUPS_FIRST   # Expire duplicates first when trimming

# Enable zsh completion system
autoload -Uz compinit
compinit

# Better tab completion behavior
bindkey '^I' expand-or-complete

# Set up zoxide
eval "$(zoxide init zsh)"

# My alias
# Custom scripts
alias clean='clean.sh'
alias update='update_fedora.sh'
alias install='fzf_install.sh'
alias remove='fzf_remove.sh'
alias passf='pass_fzf.sh'

# Custom commands
alias grub_update='sudo grub2-mkconfig -o /boot/grub2/grub'
alias cd='z'
alias vim='nvim'
alias pfzf='fzf --preview="bat --color=always {}"'
alias nfzf='nvim $(fzf -m --preview="bat --color=always {}")'
alias la='ls -lah --color=auto'
alias ll='ls -lh --color=auto'
alias rm='rm -i'
alias mv='mv -i'
alias suspend='systemctl suspend'
alias lzg='lazygit'
alias lzd='lazydocker'
alias ff='fastfetch'
alias lf='yazi'

# Set up fzf key bindings and fuzzy completion
source <(fzf --zsh)

ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=8'


# Auto activate env on cd into directory
eval "$(direnv hook zsh)"


# Set Cursor
# 5 blinking beam
# 6 for steady beam
precmd() {
    echo -ne '\e[6 q'
}

# zsh plugins
source ~/.config/zsh-autosuggestions/zsh-autosuggestions.zsh
source ~/.config/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
