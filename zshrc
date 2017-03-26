#
# User configuration sourced by interactive shells
#

# Source zim
if [[ -s ${ZDOTDIR:-${HOME}}/.zim/init.zsh ]]; then
  source ${ZDOTDIR:-${HOME}}/.zim/init.zsh
fi

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

export PATH="/usr/local/bin:$PATH"
export PATH="/usr/local/share/npm/bin:$PATH"
export PATH="$HOME/bin:$PATH"
export PATH="$HOME/pebble-dev/PebbleSDK-current/bin:$PATH"
export PATH="$HOME/Library/Haskell/bin:$PATH"
export PATH=~/pebble-dev/PebbleSDK-3.0-dp1/bin:$PATH

PERL_MB_OPT="--install_base \"/Users/scott/perl5\""; export PERL_MB_OPT;
PERL_MM_OPT="INSTALL_BASE=/Users/scott/perl5"; export PERL_MM_OPT;

[ -d ~/.nvm ] && export NVM_DIR=~/.nvm
[ -d ~/.nvm ] && [ $(command -v brew) ] && source $(brew --prefix nvm)/nvm.sh

export ANDROID_HOME=/usr/local/opt/android-sdk

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

[ -f ~/.shell_path ] && source ~/.shell_path

[ $(command -v rbenv) ] && eval "$(rbenv init -)"
