#
# User configuration sourced by interactive shells
#

# Important, must be set to emacs mode before sourcing zim config
# Otherwise, zsh seems to default to the "safe" keymap, which is pretty much
# useless
# TODO investigate more here and figure out why I'm defaulting to "safe"
# docs seem to suggest that the default should be emacs, or vim.
bindkey -e

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
export PATH="$HOME/Library/Haskell/bin:$PATH"

PERL_MB_OPT="--install_base \"/Users/scott/perl5\""; export PERL_MB_OPT;
PERL_MM_OPT="INSTALL_BASE=/Users/scott/perl5"; export PERL_MM_OPT;

[ -d ~/.nvm ] && export NVM_DIR=~/.nvm
[ -d ~/.nvm ] && [ $(command -v brew) ] && source $(brew --prefix nvm)/nvm.sh

export ANDROID_HOME=/usr/local/opt/android-sdk

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

[ -f ~/.shell_path ] && source ~/.shell_path

[ $(command -v rbenv) ] && eval "$(rbenv init -)"

# Allows >> to create a new file (not dangerous so no reason not to)
setopt APPEND_CREATE

# Docker autocomplete, instructions here:
# https://docs.docker.com/compose/completion/#zsh
# https://docs.docker.com/machine/completion/#zsh
[ -d ~/.zsh/completion ] && fpath=(~/.zsh/completion $fpath)


# Respect .ignore/.gitignore etc, but DO search hidden files
export FZF_DEFAULT_COMMAND='ag --hidden --ignore .git -g ""'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
