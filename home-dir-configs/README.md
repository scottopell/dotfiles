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

### `claude/` → `~/.claude/`
Claude Code CLI configuration directory. Claude Code expects its config at `~/.claude/`.

**Symlink Command:**
```bash
ln -s ~/.config/home-dir-configs/claude ~/.claude
```

**What's tracked:**
- `hooks/notify.sh` - macOS notification script for Claude Code hooks (install `terminal-notifier` via brew for click-to-activate)

**What's ignored** (in `.gitignore`):
- `settings.json` - Too volatile (model preferences, plugins change frequently)
- `settings.local.json` - Machine-specific permissions
- `plugins/` - Downloaded plugin cache
- `stats-cache.json` - Usage statistics

**Optional: Enable macOS notifications**

To receive native macOS notifications when Claude Code needs attention, add this to your `~/.claude/settings.json`:

```json
{
  "hooks": {
    "Notification": [
      {
        "matcher": "",
        "hooks": [
          {
            "type": "command",
            "command": "/Users/YOUR_USERNAME/.claude/hooks/notify.sh"
          }
        ]
      }
    ]
  }
}
```

Replace `YOUR_USERNAME` with your actual username, or use the full path from `echo ~/.claude/hooks/notify.sh`.

## Installation

These symlinks are created automatically when following the main README.md installation instructions, but can also be created manually with the commands above.

## Philosophy

This approach maintains the benefits of version-controlled dotfiles while acknowledging the reality that not all software has adopted modern configuration standards. As software evolves to support XDG, configs can be moved from this directory to the main `~/.config/` structure.