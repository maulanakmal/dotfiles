# vim: set filetype=sh:

ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"
[ ! -d $ZINIT_HOME ] && mkdir -p "$(dirname $ZINIT_HOME)"
[ ! -d $ZINIT_HOME/.git ] && git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"

source "${ZINIT_HOME}/zinit.zsh"

zinit light zsh-users/zsh-history-substring-search
zinit light zsh-users/zsh-syntax-highlighting
zinit light zsh-users/zsh-completions
zinit light zsh-users/zsh-autosuggestions
zinit light Aloxaf/fzf-tab

bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down


zinit snippet OMZP::git/git.plugin.zsh
zinit snippet OMZP::per-directory-history/per-directory-history.zsh
alias gcnvm='git commit --no-verify --message'



eval "$(oh-my-posh init zsh --config $(nix-store -q $(which oh-my-posh))/share/oh-my-posh/themes/M365Princess.omp.json)"

eval "$(zoxide init zsh)"
eval "$(fzf --zsh)"

SCRIPTS_DIR="$HOME/.local/scripts"
[ -f $SCRIPTS_DIR/sesh-sessions-func.sh ] && source "$SCRIPTS_DIR/sesh-sessions-func.sh"

# History
HISTSIZE=5000
HISTFILE=~/.zsh_history
SAVEHIST=$HISTSIZE
HISTDUP=erase
setopt appendhistory
setopt sharehistory
setopt hist_ignore_space
setopt hist_ignore_all_dups
setopt hist_save_no_dups
setopt hist_ignore_dups
setopt hist_find_no_dups

#TODO 
export SP_UNIX_SOCKET=$HOME/.run/spex/spex.sock
export SP_INTERCEPT_UNIX_SOCKET=$HOME/.run/spex/spex_intercept.sock

export PATH=$PATH:$HOME/.local/bin

export EDITOR=nvim
alias vim=nvim
alias v=nvim


zle -N sesh-sessions
bindkey "^K" sesh-sessions

__reload_zshrc() {
    source ~/.zshrc
}


# Programming language specific setup
#
# Go
# Need to install GVM manually
DEFAULT_GO_VERSION=go1.23.4
[[ ! -d "$HOME/.gvm" ]] && ! command -v gvm && GVM_NO_UPDATE_PROFILE=true bash < <(curl -s -S -L https://raw.githubusercontent.com/moovweb/gvm/master/binscripts/gvm-installer)
[[ -s "$HOME/.gvm/scripts/gvm" ]] && source "$HOME/.gvm/scripts/gvm"
# [[ -s "$HOME/.gvm/scripts/gvm" ]] && ! (gvm list | grep "$DEFAULT_GO_VERSION") && gvm install "$DEFAULT_GO_VERSION" -B
# [[ -s "$HOME/.gvm/scripts/gvm" ]] && ! (gvm list | grep "=>") && gvm use --default "$DEFAULT_GO_VERSION"

# Rust

[[ -s "$HOME/.cargo/env" ]] && source "$HOME/.cargo/env"

# Python
# Pyenv will be installed using nixpkgs
export PYENV_ROOT="$HOME/.pyenv"
[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"
