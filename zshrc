export LANG=en_US.UTF-8

HISTFILE=$HOME/.zsh_history

. ~/.aliases

if command -v code &> /dev/null; then
  export VISUAL="code -n -w"
else
  export VISUAL="vim"
  alias code=vim
fi

bindkey -e  # use emacs key bindings for command prompt (it will default to vim mode if $VISUAL=vim)

# For GPG agent
export GPG_TTY=`tty`

# iterm badge with param
badge() {
  badge="$1"
  if [ -z "$badge" ]; then
    badge=$(basename $(pwd))
  fi
  printf "\e]1337;SetBadgeFormat=%s\a" $(echo -n "$badge" | base64)
}

github-url() {
  echo "https://github.com/`git remote -v | grep origin | head -1 | sed 's/^.*github.com[/:]\(.*\)\.git.*/\1/'`/tree/`git branch | grep '^\*' | awk '{print $2}'`"
}

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

test -f ~/.zshrc.local && . ~/.zshrc.local || true
