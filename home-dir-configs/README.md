# home-dir-configs/

This directory contains configuration files that must be placed directly in the home directory (not in `~/.config/`) and requires symlinks.

## Purpose

While most modern software supports XDG-compliant config locations (like `~/.config/`), some applications still require their configuration files to be in specific locations in the home directory. This directory keeps these "legacy" configs organized within the dotfiles repo while maintaining the required symlink structure.

## Current Files

### `psqlrc` → `~/.psqlrc`
PostgreSQL client configuration. PostgreSQL doesn't support XDG Base Directory specification and expects the config at `~/.psqlrc`.

**Symlink Command:**
```bash
ln -s ~/dotfiles/home-dir-configs/psqlrc ~/.psqlrc
```

### `p10k.zsh` → `~/.p10k.zsh`  
Powerlevel10k Zsh theme configuration. While P10K has some XDG support for cache files, the main configuration file typically remains in the home directory.

**Symlink Command:**
```bash
ln -s ~/dotfiles/home-dir-configs/p10k.zsh ~/.p10k.zsh
```

## Installation

These symlinks are created automatically when following the main README.md installation instructions, but can also be created manually with the commands above.

## Philosophy

This approach maintains the benefits of version-controlled dotfiles while acknowledging the reality that not all software has adopted modern configuration standards. As software evolves to support XDG, configs can be moved from this directory to the main `~/.config/` structure.