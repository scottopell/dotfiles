dotfiles
========

XDG Base Directory compliant dotfiles. Written from scratch, not forked.

## Setup

```sh
# Back up an existing ~/.config first.
git clone https://github.com/scottopell/dotfiles ~/.config
git -C ~/.config submodule update --init --recursive

# Inspect and install non-XDG entry points.
~/.config/scripts/bootstrap-home.sh --dry-run
~/.config/scripts/bootstrap-home.sh

# Manually add this line to the machine-managed ~/.zshrc:
[ -f "$HOME/.config/zsh/.zshrc" ] && source "$HOME/.config/zsh/.zshrc"
```

`~/.zshrc` is intentionally not managed by the repository or bootstrap. This keeps portable dotfiles separate from MDM, package-manager, and machine-specific shell initialization. Add the source line in the appropriate place without replacing existing content.

The bootstrap refuses to overwrite existing paths. It installs `~/.p10k.zsh`, `~/.psqlrc`, and `~/.agents/skills`. `~/AGENTS.md` remains machine-specific and unmanaged.

Update an existing checkout with:

```sh
git -C ~/.config pull --ff-only
git -C ~/.config submodule update --init --recursive
~/.config/scripts/bootstrap-home.sh
```

## Structure

- `nvim/` - Neovim (Lazy.nvim, modular lua)
- `tmux/` - Tmux
- `zsh/` - Zsh aliases and functions
- `git/` - Git config and global gitignore
- `agents/` - Portable agent skills installed at `~/.agents/skills`
- `home-dir-configs/` - Non-XDG configs requiring home-directory symlinks

## Host tools

Install tools manually before enabling the corresponding configuration. On macOS, the core baseline is:

```sh
brew install git tmux neovim fzf ripgrep tree-sitter-cli uv
```

Uv may instead be installed with its official installer. The tracked `dev.py` requires `uv`; Neovim's configured Tree-sitter parsers require `tree-sitter-cli`. Keep tmux current because the tracked config intentionally uses modern tmux options.

Language runtimes and language servers are project-driven. Install Node, Rust, Go, Python versions, `typescript-language-server`, `gopls`, and similar tools only when a project requires them. Neovim enables a configured language server only when its executable is available.

Optional shell helpers are guarded and become available when their commands are installed, including `kubectl`, `pngpaste`, `7z`, and `unrar`.

## macOS preferences

Review the script before running it, then apply the selected user-level preferences:

```sh
~/.config/scripts/macos-setup.sh
```
