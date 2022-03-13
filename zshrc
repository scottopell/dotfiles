# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

#
# User configuration sourced by interactive shells
#

if [ -f ~/.shell_aliases ]; then
  source ~/.shell_aliases
fi

if [ -f ~/.shell_functions ]; then
  source ~/.shell_functions
fi

# All env vars and PATHs related to local software
# gets put into this file
if [ -f ~/.mach_specific_paths_n_stuff ]; then
  source ~/.mach_specific_paths_n_stuff
fi

export EDITOR="nvim"

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

