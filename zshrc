# Path to your oh-my-zsh installation.
export ZSH=$HOME/.oh-my-zsh

ZSH_THEME="danstheme"

plugins=(git zsh-syntax-highlighting osx)

source $ZSH/oh-my-zsh.sh

# User configuration

if [ -f ~/.shell_aliases ]; then
  source ~/.shell_aliases
fi

if [ -f ~/.shell_functions ]; then
  source ~/.shell_functions
fi

if [ -f ~/.profile ]; then
  source ~/.profile
fi

export EDITOR="vim"

export PATH="/usr/local/bin:/bin:/usr/sbin:/sbin:/usr/bin"

export PATH="/usr/local/share/npm/bin:$PATH"
export PATH="$HOME/bin:$PATH"
export PATH="$HOME/pebble-dev/PebbleSDK-current/bin:$PATH"
export PATH="$HOME/Library/Haskell/bin:$PATH"
export PATH=~/pebble-dev/PebbleSDK-3.0-dp1/bin:$PATH

PERL_MB_OPT="--install_base \"/Users/scott/perl5\""; export PERL_MB_OPT;
PERL_MM_OPT="INSTALL_BASE=/Users/scott/perl5"; export PERL_MM_OPT;