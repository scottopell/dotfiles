dotfiles
========

XDG Base Directory compliant dotfiles. Written from scratch, not forked.

## Setup

```sh
# Clone as ~/.config (backup existing first if needed: mv ~/.config ~/.config.bak)
git clone https://github.com/scottopell/dotfiles ~/.config
cd ~/.config && git submodule update --init --recursive

# Symlinks for non-XDG configs
ln -s ~/.config/home-dir-configs/psqlrc ~/.psqlrc
ln -s ~/.config/home-dir-configs/p10k.zsh ~/.p10k.zsh

# Source zsh config
echo '[ -f ~/.config/zsh/.zshrc ] && source ~/.config/zsh/.zshrc' >> ~/.zshrc
```

## Structure

- `nvim/` - Neovim (Lazy.nvim, modular lua)
- `tmux/` - Tmux
- `zsh/` - Zsh aliases and functions
- `git/` - Git config and global gitignore
- `claude/` - Claude Code slash commands
- `home-dir-configs/` - Non-XDG configs requiring ~/symlinks (psqlrc, p10k.zsh)

## macOS Setup

```sh
# System preferences
./scripts/macos-setup.sh

# Tools
brew install git tmux neovim fzf ripgrep
$(brew --prefix)/opt/fzf/install
```
