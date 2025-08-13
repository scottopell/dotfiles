# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

#
# User configuration sourced by interactive shells
#

# Shell aliases (consolidated from shell_aliases)
# takes you to the last directory you were in
alias cd-='cd "$OLDPWD"'

# tmux aliases
#  forces 256 color mode
alias tmux='tmux -2'

# Useful for piping into vim and then closing without needing to save
alias v='nvim -R -'

alias k='kubectl'
# Example usage, kns datadog-agent sets kubectl namespace to 'datadog-agent'
alias kns='kubectl config set-context --current --namespace '

alias vim='nvim'

# Shell functions (consolidated from shell_functions)
# goes up 4 levels instead of ../../../..
up(){
  local d=""
  limit=$1
  for ((i=1 ; i <= limit ; i++))
    do
      d=$d/..
    done
  d=$(echo $d | sed 's/^\///')
  if [ -z "$d" ]; then
    d=..
  fi
  cd $d
}

extract () {
  if [ -f $1 ] ; then
      case $1 in
          *.tar.bz2)   tar xvjf $1    ;;
          *.tar.xz)    tar xf   $1    ;;
          *.tar.gz)    tar xvzf $1    ;;
          *.bz2)       bunzip2 $1     ;;
          *.rar)       unrar x $1     ;;
          *.gz)        gunzip $1      ;;
          *.tar)       tar xvf $1     ;;
          *.tbz2)      tar xvjf $1    ;;
          *.tgz)       tar xvzf $1    ;;
          *.zip)       unzip $1       ;;
          *.Z)         uncompress $1  ;;
          *.7z)        7z x $1        ;;
          *)           echo "don't know how to extract '$1'..." ;;
      esac
  else
      echo "'$1' is not a valid file!"
  fi
}

export EDITOR="nvim"

# FZF dark theme (gruvbox-inspired)
export FZF_DEFAULT_OPTS='--color=fg:#ebdbb2,bg:#282828,hl:#fabd2f,fg+:#ebdbb2,bg+:#3c3836,hl+:#fabd2f,info:#83a598,prompt:#bdae93,pointer:#84a0c6,marker:#fe8019,spinner:#8ec07c,header:#928374'

# Allows >> to create a new file (not dangerous so no reason not to)
setopt APPEND_CREATE

# Allows use of # character in interactive commands as a comment
# Useful if you have a command you want to save in history, but not execute
# right away
setopt interactivecomments

## Begin History Section
# > The file to save the history in when an interactive shell exits.
export HISTFILE=~/.zsh_history

# > The maximum number of history events to save in the history file.
export SAVEHIST=999999

# > The maximum number of events stored in the internal history list.
# number of history entries loaded into memory from history file
export HISTSIZE=$SAVEHIST

# Remove "superfluous" blanks from each command line from history file
setopt HIST_REDUCE_BLANKS

# My ZSH instances should:
# 1 Write history sooner rather than later
# 2 Not overwrite other instances history (aka, want shared history)
# 3 commands from instance A should not be visible from instance B until B "reloads" history
# 4 instances should be able to easily "reload" shell history (see (3))

# This option appends history eagerly, satisfying (1), (2) and (3)
setopt INC_APPEND_HISTORY_TIME
# To satisfy 4, alias obscure `fc` command
alias history_reload="fc -RI"

# > If a new command line being added to the history list duplicates
# > an older one, the older command is removed from the list
# > (even if it is not the previous event).
# Never write a duplicate command to history
setopt HIST_IGNORE_ALL_DUPS

## End History Section

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# Sets emacs shortcuts
bindkey -e

# Option + Left/Right for word navigation
bindkey '^[[1;3D' backward-word   # Option + Left
bindkey '^[[1;3C' forward-word    # Option + Right

# This functionality is required to have SSH auth agent
# work seamlessly in tmux.
# See my notes in tmux.conf for more details
if [ -n "$TMUX" ]; then
  function refresh {
    eval $(tmux show-environment -s SSH_AUTH_SOCK)
  }
else
  function refresh { }
fi

function preexec {
    refresh
}

