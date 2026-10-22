# ~/.zshrc - F#ckIt! edition

# Oh My Zsh (optional - uncomment if you want it)
# export ZSH="$HOME/.oh-my-zsh"
# ZSH_THEME=""
# plugins=(git docker docker-compose kubectl)
# source $ZSH/oh-my-zsh.sh

# Starship prompt
eval "$(starship init zsh)"

# History
HISTFILE=~/.zsh_history
HISTSIZE=100000
SAVEHIST=100000
setopt EXTENDED_HISTORY
setopt HIST_EXPIRE_DUPS_FIRST
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_FIND_NO_DUPS
setopt HIST_SAVE_NO_DUPS
setopt SHARE_HISTORY
setopt INC_APPEND_HISTORY

# Completion
autoload -Uz compinit
compinit -d ~/.zcompdump
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"

# Keybindings
bindkey -e
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down
bindkey '^R' history-incremental-search-backward
bindkey '^[[3~' delete-char

# Aliases
alias ls='ls --color=auto -h'
alias ll='ls -la'
alias la='ls -A'
alias l='ls -CF'
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'
alias df='df -h'
alias du='du -h'
alias free='free -h'
alias ps='ps auxf'
alias mkdir='mkdir -pv'
alias wget='wget -c'
alias histg='history | grep'
alias myip='curl ipinfo.io/ip'
alias ports='netstat -tulanp'

# Git aliases
alias g='git'
alias gs='git status'
alias ga='git add'
alias gc='git commit'
alias gp='git push'
alias gl='git pull'
alias gd='git diff'
alias gco='git checkout'
alias gb='git branch'
alias glog='git log --oneline --graph --decorate --all'

# Docker aliases
alias d='docker'
alias dc='docker-compose'
alias dps='docker ps'
alias di='docker images'
alias drm='docker rm'
alias drmi='docker rmi'

# System
alias update='yay -Syu'
alias cleanup='yay -Sc && paccache -r'
alias reboot='sudo reboot'
alias poweroff='sudo poweroff'

# Editor
alias e='zed'
alias em='emacsclient -c -a emacs'
alias vim='nvim'

# Config shortcuts
alias dots='cd ~/FckIt && git status'
alias hyprconf='zed ~/.config/hypr/'
alias zedconf='zed ~/.config/zed/'
alias emacsconf='zed ~/.config/emacs/'

# Functions
mkcd() { mkdir -p "$1" && cd "$1"; }
extract() {
  if [ -f "$1" ]; then
    case "$1" in
      *.tar.bz2) tar xjf "$1" ;;
      *.tar.gz) tar xzf "$1" ;;
      *.bz2) bunzip2 "$1" ;;
      *.rar) unrar x "$1" ;;
      *.gz) gunzip "$1" ;;
      *.tar) tar xf "$1" ;;
      *.tbz2) tar xjf "$1" ;;
      *.tgz) tar xzf "$1" ;;
      *.zip) unzip "$1" ;;
      *.Z) uncompress "$1" ;;
      *.7z) 7z x "$1" ;;
      *) echo "'$1' cannot be extracted via extract()" ;;
    esac
  else
    echo "'$1' is not a valid file"
  fi
}

# FZF (if installed)
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# Zoxide (if installed)
eval "$(zoxide init zsh)"

# Direnv (if installed)
eval "$(direnv hook zsh)"

# Local overrides
[ -f ~/.zshrc.local ] && source ~/.zshrc.local