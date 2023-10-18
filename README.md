dotfiles
========

Nothing exciting or groundbreaking, just my dotfiles.

I try to avoid using other's existing dotfiles, so these are pretty much written from scratch with only the things that I care about.

## Link the configs
```sh
mkdir -p ~/.config/{tmux,nvim,git}
ln -s $HOME/dotfiles/tmux.conf $HOME/.config/tmux/tmux.conf
ln -s $HOME/dotfiles/init.vim $HOME/.config/nvim/init.vim
ln -s $HOME/dotfiles/gitignore_global $HOME/.config/git/gitignore_global
ln -s $HOME/dotfiles/gitconfig $HOME/.config/git/config
ln -s $HOME/dotfiles/shell_aliases $HOME/.shell_aliases
ln -s $HOME/dotfiles/p10k.zsh $HOME/.p10k.zsh
echo <<<
[ -f ~/dotfiles/zshrc ] && source ~/dotfiles/zshrc
[ -f ~/dotfiles/fzf-git.sh/fzf-git.sh ] && source ~/dotfiles/fzf-git.sh/fzf-git.sh
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
>>> >> ~/.zshrc
# Maybe also setup instant prompt
```

## Install things
[`vim-plug`](https://github.com/junegunn/vim-plug#installation)
[`p10k`](https://github.com/romkatv/powerlevel10k#manual)

