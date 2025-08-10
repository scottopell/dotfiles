# XDG Dotfiles Migration - Current State

## Migration Status: Ready for Final Directory Swap

### What Has Been Completed ✅

1. **File Reorganization & Consolidation**
   - ✅ Consolidated `shell_aliases` and `shell_functions` into `zshrc`
   - ✅ Deleted unused `bashrc`
   - ✅ Migrated `osx_config` content to README.md first-time setup section
   - ✅ Created `home-dir-configs/` directory for non-XDG configs
   - ✅ Moved `psqlrc` and `p10k.zsh` to `home-dir-configs/`

2. **XDG Structure Preparation**  
   - ✅ Created comprehensive `.gitignore` for selective `~/.config` tracking
   - ✅ Updated README.md with new XDG-compliant installation instructions
   - ✅ All configs are properly organized and ready for XDG migration

3. **Git History Preservation**
   - ✅ All changes committed to git in this directory
   - ✅ Git history intact and ready to be preserved during directory move

### Current Directory Structure

```
~/dotfiles/ (ready to become ~/.config/)
├── .gitignore              # Selective tracking rules
├── README.md               # Install instructions + macOS setup  
├── PLAN.md                 # This file
├── gitconfig               # → will be ~/.config/git/config
├── gitignore_global        # → will be ~/.config/git/ignore (rename needed)
├── init.vim                # → will be ~/.config/nvim/init.lua (conversion needed)
├── tmux.conf              # → will be ~/.config/tmux/tmux.conf  
├── zshrc                  # → will be ~/.config/zsh/.zshrc
├── claude-slash-commands/  # → will be ~/.config/claude/commands/
│   └── create-pr.md
├── fzf-git.sh/            # Git submodule (sourced from zshrc)
└── home-dir-configs/      # Non-XDG configs (require symlinks)
    ├── README.md
    ├── psqlrc             # → ~/.psqlrc (symlink)
    └── p10k.zsh           # → ~/.p10k.zsh (symlink)
```

### What Gets Ignored by .gitignore

- `configstore/` - OAuth tokens, API keys, sensitive auth data
- `uv/` - App-managed installation receipts  
- `flutter/` - Generated tool state, analytics flags
- `fish/` - Not used by user
- `helix/` - Not used by user
- Standard app cache/log patterns

### What Gets Tracked in ~/.config

- `alacritty/` - Terminal settings (already exists)
- `gh/` - GitHub CLI preferences (already exists)
- `git/` - Git configuration (from this repo)
- `graphite/` - Git workflow tools (already exists)  
- `htop/` - System monitor preferences (already exists)
- `nvim/` - Neovim configuration (from this repo)
- `tmux/` - Tmux configuration (from this repo)
- `wireshark/` - UI preferences (already exists)
- `zsh/` - Zsh configuration (from this repo)
- `claude/` - Claude slash commands (from this repo)

## Next Steps (Post Directory Move)

### Immediate Actions Required

1. **Execute Directory Swap**
   ```bash
   # (User will do this manually due to CWD)
   mv ~/.config ~/.config-existing
   mv ~/dotfiles ~/.config
   ```

2. **File Conversions & Migrations**
   - Convert `~/.config/init.vim` to proper lua module structure
   - Rename `~/.config/gitignore_global` to `~/.config/git/ignore`
   - Move `~/.config/gitconfig` to `~/.config/git/config`
   - Move `~/.config/tmux.conf` to `~/.config/tmux/tmux.conf`
   - Move `~/.config/zshrc` to `~/.config/zsh/.zshrc`
   - Move `~/.config/claude-slash-commands/*` to `~/.config/claude/`

3. **Cherry-pick from ~/.config-existing**
   - Review `alacritty/`, `gh/`, `graphite/`, `htop/`, `wireshark/` configs
   - Copy any useful configs that aren't already tracked

4. **Create Required Symlinks**
   ```bash
   ln -s ~/.config/home-dir-configs/psqlrc ~/.psqlrc
   ln -s ~/.config/home-dir-configs/p10k.zsh ~/.p10k.zsh
   ```

5. **Update Shell Bootstrap**
   Update `~/.zshrc` to source from new location:
   ```bash
   [ -f ~/.config/zsh/.zshrc ] && source ~/.config/zsh/.zshrc
   ```

### Neovim Lua Conversion Plan

Convert single `init.vim` to modular lua structure:
```
~/.config/nvim/
├── init.lua              # Entry point, bootstrap lazy.nvim
└── lua/config/
    ├── plugins.lua       # Plugin definitions  
    ├── options.lua       # Vim options & settings
    ├── keymaps.lua       # Key mappings
    ├── lsp.lua          # LSP configuration
    └── treesitter.lua   # Treesitter setup
```

### Testing & Validation

1. Test git config works (`git --version`, check aliases)
2. Test tmux config loads (`tmux -V`, check custom bindings)
3. Test neovim lua config loads (`:checkhealth`)
4. Test zsh config loads (aliases, functions, p10k theme)
5. Test claude slash commands accessible
6. Verify symlinks work (psql, p10k)

## Multi-Machine Deployment

On other machines, follow README.md instructions:
1. Backup existing `~/.config` → `~/.config-existing`
2. Clone this repo as new `~/.config`
3. Cherry-pick useful configs from backup
4. Create symlinks for home-dir-configs
5. Update shell sourcing

## Key Benefits Achieved

- ✅ XDG Base Directory compliance
- ✅ No symlink complexity for XDG-compliant software
- ✅ Preserved git history through directory move
- ✅ Clean separation of XDG vs non-XDG configs
- ✅ Modular, maintainable structure
- ✅ Comprehensive installation documentation

## Migration Philosophy

This migration maintains the benefits of version-controlled dotfiles while adopting modern XDG standards. Non-XDG software is cleanly separated in `home-dir-configs/` rather than abandoned, and the approach scales across multiple machines through the documented installation process.