# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='mvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"

. ~/.aliases

export VISUAL="code -n -w"

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
