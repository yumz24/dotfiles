# Homebrew Path
export PATH="/opt/homebrew/bin:/opt/homebrew/sbin:$PATH"

# alias python="python"
# alias pip="pip"

# homebrew
# typeset -U path PATH
# path=(
#   /opt/homebrew/bin(N-/)
#   /opt/homebrew/sbin(N-/)
#   /usr/bin
#   /usr/sbin
#   /bin
#   /sbin
#   /usr/local/bin(N-/)
#   /usr/local/sbin(N-/)
#   /Library/Apple/usr/bin
# )


# php
export PATH=/usr/local/opt/php@8.0/bin:$PATH

# flutter
# export PATH="$PATH:/Users/yumini/development/flutter/bin"


# export PATH="$HOME/Library/Python/3.9/bin:$PATH"
# export PATH="/usr/local/opt/python@3.10/libexec/bin:$PATH"
# export PYENV_ROOT="$HOME/.pyenv"
# export PATH="$PYENV_ROOT/bin:$PATH"
# eval "$(pyenv init -)"

# ssh to raspberry pi A
alias raspi='ssh pi@192.168.0.14'

# git
alias gs='git status'
alias gcm='git commit'
alias ga='git add'
alias gco='git checkout'
alias gp='git pull'
alias gb='git branch'

# 現在のブランチ名をクリップボードにコピー
function gbc() {
  git branch --show-current | pbcopy
  echo "Copied current branch name to clipboard: $(git branch --show-current)"
}

# 存在するブランチならチェックアウト、存在しなければ作成
function gsc() {
  if [[ -z "$1" ]]; then
    echo "Usage: gsc <branch-name>"
    return 1
  fi

  local target=$1
  if git show-ref --verify --quiet refs/heads/$target; then
    read "?Branch '$target' exists. Switch to it? [y/N] " answer
    if [[ "$answer" == [yY] ]]; then
      git checkout $target
      echo "Switched to '$target'"
    else
      echo "Aborted"
    fi
  else
    git checkout -b $target
    echo "Branch '$target' created and switched"
  fi
}

# auto_cd
setopt auto_cd

# alias
alias l='ls'
alias ll='ls -la'
# alias la='ls -la'
alias lf='ls -1A'
alias lc='ls -F'   # classify
alias tree='tree -a'
alias n='nvim'
alias memo='n + ~/Documents/markdown/memo.md'
alias todo='n + ~/Documents/markdown/todo.md'

alias ...='../../'
alias ....='../../../'
alias .....='../../../../'
function pwdc() {
  pwd | pbcopy
  echo "Copied current directory path to clipboard: $(pwd)"
}

function treec() {
  local dir_name=$(basename "$PWD")
  tree "$@" \
    | sed "1s|^\\.$|$dir_name|" \
    | sed "s|$HOME|~|" \
    | pbcopy
  echo "Copied tree of ${PWD/#$HOME/~} to clipboard"
}


alias mm='n + ~/Documents/markdown/'


# Global Alias
# - alias that is interpreted even if it is not the first
alias -g G='| grep'
alias -g L='| wc -l'

# history
HISTSIZE=10000
SAVEHIST=10000

# .zsh_hisroty に追記する設定
# 複数の zsh を同時に使う時など HISTFILE に上書きせず追加する
# default on
# setopt append_history

# コマンドの実行時刻を記録する
setopt extended_history

# いつ append するのか
# inc_append_history: 実行時に HISTFILE に追加
# inc_append_history_time: 実行終了時に実行時間と共に HISTFILE に追加
# share_history: inc_append_history + 他ターミナルでの実行を即座に反映
# が排他的な設定
# terminal 毎に履歴が残った方が嬉しいこともある + 実行時間は知りたいため inc_append_history_time
setopt inc_append_history_time 

# 履歴の数が上限に達した時、古いもの以前に重複しているものを削除する
setopt hist_expire_dups_first

# 重複するコマンドは新しい方のみを記録する
setopt hist_ignore_all_dups

# 重複するコマンドは新しい方のみを HISTFILE に保存する
# 直前のコマンドをパッと使いたいケースが多いので設定しない
# setopt hist_save_no_dups

# history 参照コマンドを履歴として残さない
setopt hist_no_store

# スペースで始まるコマンド行は履歴として残さない
setopt hist_ignore_space

# 上矢印で重複をスキップ
setopt HIST_FIND_NO_DUPS      

# 補完時にヒストリを自動的に展開         
setopt HIST_EXPAND

# 開始と終了を記録
setopt EXTENDED_HISTORY

# search history の alias
alias shist="history -i 0 | grep "
# history search
bindkey '^P' history-beginning-search-backward
bindkey '^N' history-beginning-search-forward

# 補完設定
autoload -Uz compinit
compinit

zstyle ':completion:*' menu select
zstyle ':completion:*' list-colors ''
# プロンプトカスタマイズ
# venv の自動プロンプト変更を無効化（Zshで統合するため）
export VIRTUAL_ENV_DISABLE_PROMPT=1

# venv名を表示する関数（VIRTUAL_ENV があるときだけ "(name)" を返す）
python_venv() {
  if [[ -n "$VIRTUAL_ENV" ]]; then
    print -r -- "($(basename "$VIRTUAL_ENV"))"
  fi
}

autoload -Uz vcs_info
setopt prompt_subst

# Gitの変更有無表示と色
zstyle ':vcs_info:git:*' check-for-changes true
zstyle ':vcs_info:git:*' stagedstr "%F{magenta}!"
zstyle ':vcs_info:git:*' unstagedstr "%F{yellow}"

# ブランチ表示のフォーマット（あなたの指定色を維持）
# %c: stagedstr, %u: unstagedstr, %b: branch
zstyle ':vcs_info:*' formats "%F{#50c878}%c%u(%b)%f"
zstyle ':vcs_info:*' actionformats '[%b|%a]'

precmd () { vcs_info }

# default
# PROMPT='
# [%B%F{034}%n@%m%f%b : %F{036}%~%f]%F{020}$vcs_info_msg_0_%f
# %F{white}❯%f '
# PROMPT='
# %F{036}%~%f %F{020}$vcs_info_msg_0_%f
# %F{white}❯%f '

# 1行表示（改行を削除し、同一行にまとめる）
# 左：ディレクトリ（薄い青）＋ Git（緑）
# 右：何も出さない場合は未設定。必要ならRPROMPTに(venv)を出すオプションを下に用意
PROMPT='%F{#6ec6ff}%~%f %F{#50c878}$vcs_info_msg_0_%f ${$(python_venv):-}'$'\n''%F{white}%f'

# —— オプション：右側に (venv) を出したい場合 ——
# 左にディレクトリ＋Git、右に (venv) を表示する。好みでこちらを使ってください。
# PROMPT='%F{#6ec6ff}%~%f %F{#50c878}$vcs_info_msg_0_%f %F{white}❯%f '
# RPROMPT='${$(python_venv):-}'

# 色を一覧表示する
colorlist() {
  for color in {000..015}; do
    print -nP "%F{$color}$color %f"
  done
  printf "\n"
  for color in {016..255}; do
    print -nP "%F{$color}$color %f"
    if [ $(($((color-16))%6)) -eq 5 ]; then
      printf "\n"
    fi
  done
}

# docker 
docker-exec() {
  # 実行中のコンテナ名を取得
  containers=($(docker ps --format "{{.Names}}"))

  # 実行中のコンテナがない場合の処理
  if (( ${#containers[@]} == 0 )); then
    echo "No running containers found."
    return 1
  fi

  # コンテナ選択メニューを表示
  echo "Available containers:"
  select name in "${containers[@]}"; do
    # ユーザーが有効な選択肢を選んだか確認
    if [[ -n "$name" ]]; then
      docker exec -it "$name" bash
      break
    else
      echo "Invalid selection. Please try again."
    fi
  done
}

# default editor
EDITOR="vim"
# Rust settings
export PATH="$HOME/.cargo/bin:$PATH"

# Python settings
export PYENV_ROOT="${HOME}/.pyenv"
export PATH="${PYENV_ROOT}/bin:$PATH"
eval "$(pyenv init -)"
eval "$(pyenv virtualenv-init -)"
export PATH="$HOME/.local/bin:$PATH"

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
