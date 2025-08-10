# Dotfiles XDG Migration Plan

## Overview
Migrate from symlink-based dotfiles management to tracking `~/.config` directly as a git repository for XDG Base Directory compliance.

## Current State Analysis
- Dotfiles repo at `~/dotfiles/` with symlinks to `~/.config/`
- Single large `init.vim` with embedded lua
- Manual symlink setup process
- Shell configs remain in `~/dotfiles/` (not XDG compliant by nature)

## Migration Steps

### Phase 1: Analysis & Planning
- [x] Document current dotfiles structure
- [x] Research XDG compliance requirements  
- [x] Create migration plan
- [x] Analyze existing `~/.config/` contents for conflicts
- [x] Identify what to keep vs migrate vs ignore
- [x] Create `.gitignore` for selective tracking

### Phase 2: Preparation
- [ ] Backup current `~/.config/` state
- [ ] Port current dotfiles to new structure

### Phase 3: Neovim Restructure  
- [ ] Split `init.vim` into proper lua modules:
  - `~/.config/nvim/init.lua` (main entry point)
  - `~/.config/nvim/lua/config/plugins.lua` (plugin definitions)
  - `~/.config/nvim/lua/config/keymaps.lua` (key bindings)
  - `~/.config/nvim/lua/config/lsp.lua` (LSP configuration)
  - `~/.config/nvim/lua/config/options.lua` (vim options)

### Phase 4: Migration
- [ ] Initialize `~/.config/` as git repository
- [ ] Move configs from `~/dotfiles/` to `~/.config/`
- [ ] Update shell sourcing to reference new locations
- [ ] Remove old symlinks
- [ ] Rename/archive `~/dotfiles/` directory

### Phase 5: Validation
- [ ] Test all configurations work
- [ ] Update install documentation
- [ ] Verify git tracking is selective and appropriate

## Target Structure
```
~/.config/           (git repo)
├── .gitignore       (selective tracking - ignore app data/caches)
├── alacritty/       (terminal settings)
├── gh/              (GitHub CLI preferences, aliases)
├── git/             (git configuration)
├── graphite/        (git workflow tools)
├── htop/            (system monitor preferences)
├── nvim/            (neovim configuration)
│   ├── init.lua
│   └── lua/config/
│       ├── plugins.lua
│       ├── keymaps.lua
│       ├── lsp.lua
│       └── options.lua
├── tmux/tmux.conf   (migrated from ~/dotfiles)
├── wireshark/       (UI layout, analysis preferences)
└── claude/
    └── commands/    (slash commands, migrated from ~/dotfiles)
```

### Ignored Directories (.gitignore)
- `configstore/` - OAuth tokens, API keys, sensitive auth data
- `uv/` - App-managed installation receipts
- `flutter/` - Generated tool state, analytics flags
- `fish/` - Not used by user
- `helix/` - Not used by user

## Shell Configs Strategy
Shell configs (`zshrc`, `shell_aliases`, etc.) will remain in a separate location since shells don't follow XDG spec. Options:
1. Keep in `~/dotfiles/` (rename to `~/shell-config/`)
2. Move to `~/.local/share/shell/`
3. Create `~/.config/shell/` (non-standard but organized)

## Risks & Considerations
- Existing `~/.config/` may have many untracked application configs
- Need careful `.gitignore` to avoid tracking sensitive data
- Shell integration needs updating
- Backup strategy important before migration

## Benefits
- No symlink management complexity
- XDG-compliant by default
- Better neovim organization
- Direct file editing without indirection
- Cleaner development workflow