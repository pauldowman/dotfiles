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

# For GPG agent
export GPG_TTY=`tty`

github-url() {
  echo "https://github.com/`git remote -v | grep origin | head -1 | sed 's/^.*github.com[/:]\(.*\)\.git.*/\1/'`/tree/`git branch | grep '^\*' | awk '{print $2}'`"
}

dev() {
  if [ -f ~/code/.edit-locally ] ; then
    SSH=""
  else
    SSH="ssh -t dev"
  fi

  if [ "$1" = "list" ] ; then
    $SSH tmux list-sessions
  else
    $SSH tmux new-session -A -s $1 -c ~/code/$1
  fi
}

# Autocomplete for dev() - suggests subdirectories of ~/code
_dev() {
  local -a subdirs
  subdirs=("list:List all tmux sessions")
  # Add all subdirectories of ~/code
  # (N) = null glob (return empty if no matches), (/) = directories, (@) = symlinks
  for dir in $HOME/code/*(N/,@); do
    local dirname="${dir:t}"
    subdirs+=("$dirname")
  done
  _describe 'dev projects' subdirs
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
