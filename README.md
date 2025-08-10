dotfiles
========

Nothing exciting or groundbreaking, just my dotfiles.

I try to avoid using other's existing dotfiles, so these are pretty much written from scratch with only the things that I care about.

## Install (New XDG-Compliant Method)

**Migration Process:**
```sh
# Backup existing config
mv ~/.config ~/.config-existing

# Clone dotfiles as new ~/.config
git clone <your-repo-url> ~/.config

# Manually migrate any useful configs from backup
# (cherry-pick what you need from ~/.config-existing)

# Setup shell configs (these remain separate from XDG)
echo <<<
[ -f ~/dotfiles/zshrc ] && source ~/dotfiles/zshrc
[ -f ~/dotfiles/fzf-git.sh/fzf-git.sh ] && source ~/dotfiles/fzf-git.sh/fzf-git.sh
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
>>> >> ~/.zshrc
```

**What Gets Tracked:**
- `alacritty/` - Terminal settings
- `gh/` - GitHub CLI preferences
- `git/` - Git configuration  
- `graphite/` - Git workflow tools
- `htop/` - System monitor preferences
- `nvim/` - Neovim configuration
- `tmux/` - Tmux configuration
- `wireshark/` - UI preferences

**What Gets Ignored:**
App data, caches, and sensitive authentication info are automatically ignored via `.gitignore`.

## Legacy Install (Symlink-Based - Deprecated)
<details>
<summary>Click to expand old symlink method</summary>

```sh
mkdir -p ~/.config/{tmux,nvim,git}
ln -s $HOME/dotfiles/tmux.conf $HOME/.config/tmux/tmux.conf
ln -s $HOME/dotfiles/init.vim $HOME/.config/nvim/init.vim
ln -s $HOME/dotfiles/gitignore_global $HOME/.config/git/gitignore_global
ln -s $HOME/dotfiles/gitconfig $HOME/.config/git/config
ln -s $HOME/dotfiles/shell_aliases $HOME/.shell_aliases
ln -s $HOME/dotfiles/p10k.zsh $HOME/.p10k.zsh
ln -s $HOME/dotfiles/claude-slash-commands $HOME/.claude/commands
```
</details>

## Install things
[`vim-plug`](https://github.com/junegunn/vim-plug#installation)
[`fzf.zsh`](https://github.com/junegunn/fzf/tree/master#using-git)
[`p10k`](https://github.com/romkatv/powerlevel10k#manual)

