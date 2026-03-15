export LANG=en_US.UTF-8

# Initialize completion system
autoload -Uz compinit
compinit

export HISTFILE=$HOME/.zsh_history
export HISTSIZE=10000
export SAVEHIST=10000
setopt APPEND_HISTORY
setopt INC_APPEND_HISTORY
setopt SHARE_HISTORY
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_REDUCE_BLANKS

zstyle ':completion:*' menu select
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"

. ~/.aliases

unset GIT_EDITOR # Fix devcontainers in cursor
if command -v nvim &> /dev/null; then
  export VISUAL="nvim"
  alias e=nvim
elif command -v code &> /dev/null; then
  export VISUAL="code -w"
  alias e=code
else
  export VISUAL="vim"
  alias e=vim
fi

bindkey -e  # use emacs key bindings for command prompt (it will default to vim mode if $VISUAL=vim)
bindkey "^[[3~" delete-char  # fn+delete (forward delete) in tmux

# For GPG agent
export GPG_TTY=`tty`

github-url() {
  echo "https://github.com/`git remote -v | grep origin | head -1 | sed 's/^.*github.com[/:]\(.*\)\.git.*/\1/'`/tree/`git branch | grep '^\*' | awk '{print $2}'`"
}

dev() {
  case "$1" in
    "")
      echo "Usage: dev <session-name> | dev list" >&2
      return 1
      ;;
    *)
      if [ ! -f ~/code/.edit-locally ]; then
        ssh -t dev "~/code/dev-container/dev-container $(printf '%q' "$1")"
      else
        ~/code/dev-container/dev-container "$1"
      fi
      ;;
  esac
}

# Autocomplete for dev() - completes directory paths under ~/code
_dev() {
  _alternative \
    'args:subcommand:(list)' \
    'dirs:directory:_path_files -/ -W $HOME/code'
}

compdef _dev dev

setopt AUTO_CD

prompt_nix_shell() {
  if [ -n "$IN_NIX_SHELL" ]; then
    echo " %F{blue}(nix)%f"
  fi
}

prompt_git_branch() {
  git symbolic-ref --short HEAD 2> /dev/null
}

prompt_git_status() {
  local gitstatus=$(git status --porcelain 2> /dev/null)
  if [[ -n $gitstatus ]]; then
    echo " %F{yellow}⚡️%f"
  fi
}

set_prompt() {
  local prompt_git_branch=$(prompt_git_branch)
  local prompt_git_status=$(prompt_git_status)
  PROMPT="%F{magenta}%n%F{white}@%F{yellow}%m: %F{cyan}%~ %F{green}$(prompt_git_branch)%f$(prompt_git_status)$(prompt_nix_shell) %f
$ "
}

precmd_functions+=(set_prompt)

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

if [ -d "$HOME/.cargo" ]; then
  . "$HOME/.cargo/env"
fi

export PATH="$PATH:$HOME/.foundry/bin"

# Claude Code
export PATH="$HOME/.local/bin:$PATH"

test -f ~/.zshrc.local && . ~/.zshrc.local || true
