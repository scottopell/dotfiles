# CLAUDE.md - dotfiles Repository Context

This is an XDG Base Directory compliant dotfiles repository that tracks configuration files in `~/.config`. The repository follows modern standards while maintaining compatibility with legacy tools through symlinks.

## Repository Overview

**Purpose**: Personal dotfiles repository tracking XDG-compliant configurations
**Philosophy**: Minimalist, security-conscious, written from scratch rather than copied
**Recent Activity**: Recently migrated to full XDG compliance with improved gitignore patterns

## Directory Structure

### Core Configurations (Tracked)
- `nvim/` - Neovim configuration with modular Lua structure
- `tmux/` - Tmux terminal multiplexer configuration
- `zsh/` - Zsh shell configuration with aliases and functions
- `git/` - Git configuration and global gitignore
- `claude/` - Claude AI slash commands
- `home-dir-configs/` - Non-XDG configs requiring home directory symlinks (psqlrc, p10k.zsh)

### Application Configs (Tracked when present)
- `alacritty/` - Terminal emulator settings
- `gh/` - GitHub CLI preferences
- `htop/` - System monitor preferences
- `wireshark/` - Network analyzer preferences
- `fzf-git.sh` - FZF git integration script

### Security & Gitignore Strategy
The repository automatically excludes:
- **Secrets**: `configstore/`, OAuth tokens, API keys
- **App State**: Installation receipts, analytics flags, generated data
- **Caches**: Application caches, logs, temporary files
- **Unused Tools**: Configs for tools not actively used

## Common Tasks

### Adding New Application Config
1. Check if config follows XDG Base Directory specification
2. If XDG-compliant: simply add to repository
3. If not XDG-compliant: place in `home-dir-configs/` and create symlink
4. Update `.gitignore` if config contains secrets or generated data

### Neovim Plugin Management
- Uses Lazy.nvim package manager
- Configuration in `nvim/lua/` following modular structure

### Shell Configuration
- Main zsh config sourced from `~/.config/zsh/.zshrc`
- Powerlevel10k theme configuration in `home-dir-configs/p10k.zsh`
- Custom aliases and functions in zsh configuration files

## Development Workflow
- Standard git workflow for configuration changes
- Test changes locally before committing
- Security-first approach: never commit secrets or sensitive data

## Key Principles
- **XDG Compliance**: Follow modern configuration standards
- **Security**: Never track secrets, tokens, or sensitive data
- **Simplicity**: Minimize symlinks and complexity
- **Portability**: Easy deployment across multiple machines
- **Maintainability**: Clean git history and clear organization
