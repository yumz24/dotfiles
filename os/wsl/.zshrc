[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

export PATH="$HOME/AppData/Local/Programs/Python/Python314/:$PATH"
export PATH="$HOME/AppData/Local/Programs/Python/Python314/Scripts:$PATH"

alias ll="ls -la"
alias l='ls -l'

alias n="nvim"
alias tree="tree -a"

alias ..='cd ../'
alias ...='cd ../../'
alias ....='cd ../../../'
alias .....='cd ../../../../'

alias -g G='| grep'
alias -g L='| wc -l'

autoload -Uz vcs_info
setopt prompt_subst

zstyle ':vcs_info:git:*' formats '%b'

precmd() {
  vcs_info
  print -Pn "\e]0;${PWD}\a"
}

build_prompt() {
  local GREEN='%F{green}'
  local YELLOW='%F{yellow}'
  local CYAN='%F{cyan}'
  local MAGENTA='%F{magenta}'
  local RESET='%f'

  local VENV=""
  if [[ -n "$VIRTUAL_ENV" && -d "$PWD/venv" ]]; then
    VENV="${CYAN}[python: $(basename $VIRTUAL_ENV)]${RESET}"
  else
    VENV=""
  fi
  # if [[ -n "$VIRTUAL_ENV" ]]; then
  #   VENV="${CYAN}[python: $(basename $VIRTUAL_ENV)]"
  # fi

  local GIT="${MAGENTA}(git: None)${RESET} "
  if [[ -n "$vcs_info_msg_0_" ]]; then
    GIT="${MAGENTA}(git: ${vcs_info_msg_0_})${RESET} "
  fi

  local USER_PART="${GREEN}%n${RESET}"
  local PATH_PART="${YELLOW}%~${RESET}"

  PROMPT="
${USER_PART} ${PATH_PART} ${GIT}${VENV}
%F{white}❯%f "
}

precmd_functions+=(build_prompt)

export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init --path)"
eval "$(pyenv init -)"
export PATH=$HOME/.npm-global/bin:$PATH

# --------------------------------------------
# OSC 7 - WezTermにカレントディレクトリを通知
# --------------------------------------------
# if [[ ! ("$(uname -a)" =~ "microsoft" && "$(uname -a)" =~ "WSL2") ]]; then
# fi 
__wezterm_osc7() {
    printf '\e]7;file://localhost%s\e\\' "$PWD"
}
precmd_functions+=(__wezterm_osc7)

