export LANG=en_US.UTF-8
export COLORTERM=truecolor

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

if command -v nvim &> /dev/null; then
  export VISUAL="nvim"
else
  export VISUAL="vim"
fi
export EDITOR=$VISUAL

. ~/.aliases

export PATH="$HOME/.local/bin:$PATH"

bindkey -e  # use emacs key bindings for command prompt (it will default to vim mode if $VISUAL=vim)
bindkey "^[[3~" delete-char  # fn+delete (forward delete) in tmux

# For GPG agent
export GPG_TTY=`tty`

github-url() {
  echo "https://github.com/`git remote -v | grep origin | head -1 | sed 's/^.*github.com[/:]\(.*\)\.git.*/\1/'`/tree/`git branch | grep '^\*' | awk '{print $2}'`"
}

if [ -e ~/code/dev-container/dev ]; then
  eval "$(~/code/dev-container/dev --init)"
fi

setopt AUTO_CD

zmodload zsh/datetime

human_duration() {
  local -F elapsed=$1
  local -i seconds=$elapsed milliseconds=$((elapsed * 1000))
  if (( elapsed < 1 )); then
    printf '%dms' $milliseconds
  elif (( seconds < 60 )); then
    printf '%.1fs' $elapsed
  elif (( seconds < 3600 )); then
    printf '%dm%ds' $((seconds / 60)) $((seconds % 60))
  elif (( seconds < 86400 )); then
    printf '%dh%dm' $((seconds / 3600)) $((seconds % 3600 / 60))
  else
    printf '%dd%dh' $((seconds / 86400)) $((seconds % 86400 / 3600))
  fi
}

start_cmd_timer() {
  CMD_START_TIME=$EPOCHREALTIME
}

prompt_cmd_status() {
  local -i exit_code=$1
  local segment=''
  (( exit_code != 0 )) && segment=' 💥'
  if [[ -n $CMD_START_TIME ]]; then
    segment+=" %F{240}$(human_duration $((EPOCHREALTIME - CMD_START_TIME)))%f"
  fi
  echo $segment
}

prompt_nix_shell() {
  if [ -n "$IN_NIX_SHELL" ]; then
    echo " %F{blue}(nix)%f"
  fi
}

prompt_git_branch() {
  git symbolic-ref --short HEAD 2> /dev/null
}

# The dirty indicator is computed in the background. `git status` recurses into
# nested submodules, which takes tens of seconds in repos like optimism, and
# computing it inline blocked every prompt for that long.
typeset -g _prompt_head='' _prompt_tail='' _prompt_branch=''
typeset -g _prompt_dirty='' _prompt_dirty_fd=''

render_prompt() {
  PROMPT="${_prompt_head}${_prompt_dirty}${_prompt_tail}"
}

cancel_git_dirty() {
  [[ -z $_prompt_dirty_fd ]] && return
  zle -F $_prompt_dirty_fd 2> /dev/null
  exec {_prompt_dirty_fd}<&- 2> /dev/null
  _prompt_dirty_fd=''
}

on_git_dirty() {
  local fd=$1 result
  IFS= read -r result <&$fd
  zle -F $fd
  exec {fd}<&-
  _prompt_dirty_fd=''

  local segment=''
  [[ $result == dirty ]] && segment=' %F{yellow}⚡️%f'
  [[ $segment == $_prompt_dirty ]] && return
  _prompt_dirty=$segment
  render_prompt
  zle reset-prompt
}

start_git_dirty() {
  cancel_git_dirty
  exec {_prompt_dirty_fd}< <(
    [[ -n $(git status --porcelain 2> /dev/null) ]] && print dirty
  )
  zle -F $_prompt_dirty_fd on_git_dirty
}

# Avoid showing the previous directory's state while the new check is in flight.
clear_git_dirty() {
  _prompt_dirty=''
}

set_prompt() {
  local exit_code=$?
  _prompt_branch=$(prompt_git_branch)
  _prompt_head="%F{magenta}%n%F{white}@%F{yellow}%m: %F{cyan}%~ %F{green}${_prompt_branch}%f"
  _prompt_tail="$(prompt_nix_shell)$(prompt_cmd_status $exit_code) %f
❯ "
  unset CMD_START_TIME
  render_prompt
  start_git_dirty
}

set_pane_title() {
  local branch=$_prompt_branch
  local title="${PWD:t}"
  [[ -n $branch ]] && title="$title ($branch)"
  print -Pn "\e]2;$title\e\\"
}

preexec_functions+=(start_cmd_timer cancel_git_dirty)
precmd_functions+=(set_prompt set_pane_title)
chpwd_functions+=(clear_git_dirty)

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

if [ -f "$HOME/.cargo/env" ]; then
  . "$HOME/.cargo/env"
fi

export PATH="$PATH:$HOME/.foundry/bin"

# opencode
export PATH=$PATH:/home/paul/.opencode/bin

test -f ~/.zshrc.local && . ~/.zshrc.local || true


# opencode
export PATH=/home/paul/.opencode/bin:$PATH
