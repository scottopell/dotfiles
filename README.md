dotfiles
========

Nothing exciting or groundbreaking, just my dotfiles following XDG Base Directory specification.

I try to avoid using other's existing dotfiles, so these are pretty much written from scratch with only the things that I care about.

## Installation

### Fresh Install
```sh
# Clone dotfiles directly as ~/.config
git clone https://github.com/yourusername/dotfiles ~/.config

# Update git submodules 
cd ~/.config && git submodule update --init --recursive

# Create symlinks for home directory configs
ln -s ~/.config/home-dir-configs/psqlrc ~/.psqlrc
ln -s ~/.config/home-dir-configs/p10k.zsh ~/.p10k.zsh

# Update ~/.zshrc to source config
echo '[ -f ~/.config/zsh/.zshrc ] && source ~/.config/zsh/.zshrc' >> ~/.zshrc
```

### Migration from Existing ~/.config

If you already have a `~/.config` directory with existing configurations:

```sh
# 1. Backup your existing config
mv ~/.config ~/.config-existing

# 2. Clone this repo as new ~/.config  
git clone https://github.com/yourusername/dotfiles ~/.config
cd ~/.config && git submodule update --init --recursive

# 3. Create symlinks for home directory configs
ln -s ~/.config/home-dir-configs/psqlrc ~/.psqlrc
ln -s ~/.config/home-dir-configs/p10k.zsh ~/.p10k.zsh

# 4. Update ~/.zshrc to source config
echo '[ -f ~/.config/zsh/.zshrc ] && source ~/.config/zsh/.zshrc' >> ~/.zshrc

# 5. Use Claude to help migrate your existing configs (see below)
```

### Config Migration Assistant

Use this Claude prompt to help migrate configurations from your backup:

```
I have backed up my existing ~/.config to ~/.config-existing and cloned new XDG-compliant dotfiles to ~/.config. 

Please help me:
1. Review what's in ~/.config-existing and identify useful configurations to migrate
2. For each useful config, determine if it should be:
   - Copied to ~/.config and tracked in git
   - Added to ~/.config/.gitignore (if it contains secrets/cache/binary data)
   - Left in backup (if obsolete)
3. Handle any conflicts with existing configs in my new dotfiles
4. Update .gitignore as needed for app-specific configs that shouldn't be tracked

My backup is at ~/.config-existing. Please start by listing what's there and we can go through each directory.
```

## What Gets Tracked

This repository tracks these XDG-compliant configurations:

- `git/` - Git configuration and global gitignore
- `nvim/` - Neovim configuration (modular lua structure)  
- `tmux/` - Tmux configuration
- `zsh/` - Zsh configuration with aliases and functions
- `claude/` - Claude AI slash commands
- `home-dir-configs/` - Non-XDG configs (psqlrc, p10k) that require home directory symlinks

Additional configs that may exist on your system and get tracked:
- `alacritty/` - Terminal settings
- `gh/` - GitHub CLI preferences  
- `graphite/` - Git workflow tools
- `htop/` - System monitor preferences
- `wireshark/` - Network analyzer preferences

## What Gets Ignored

The `.gitignore` automatically excludes:

- **Secrets & Auth**: `configstore/`, OAuth tokens, API keys
- **App State**: Installation receipts, analytics flags, generated data  
- **Caches**: Application caches, logs, temporary files
- **Unused Tools**: Configs for tools not in use (fish, helix, etc.)

This ensures only meaningful configuration is tracked while keeping sensitive data secure.

## First-Time macOS Setup

### System Preferences & UI Customization
Run these commands to set up macOS preferences for development:

```bash
#!/bin/bash
# Ask for administrator password upfront
sudo -v

# Keep sudo alive
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

# === UI & Interface ===
# Always show scrollbars
defaults write NSGlobalDomain AppleShowScrollBars -string "Always"

# Show battery percentage in menu bar
defaults write com.apple.menuextra.battery ShowPercent -string "YES"

# Set dock size to small but usable
defaults write com.apple.dock tilesize -int 32

# Keep dock visible (change to true to auto-hide)
defaults write com.apple.dock autohide -bool false

# Clear all dock apps (start fresh)
defaults write com.apple.dock persistent-apps -array ""

# Don't rearrange Spaces based on recent usage
defaults write com.apple.dock "mru-spaces" -bool "false"

# === Finder Configuration ===
# Open home folder for new Finder windows
defaults write com.apple.finder NewWindowTarget -string "PfLo"
defaults write com.apple.finder NewWindowTargetPath -string "file://${HOME}/"

# Show full POSIX path in Finder title bar
defaults write com.apple.finder _FXShowPosixPathInTitle -bool true

# Show all filename extensions
defaults write NSGlobalDomain AppleShowAllExtensions -bool true

# Search current folder by default
defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"

# Disable extension change warning
defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false

# Disable trash warning
defaults write com.apple.finder WarnOnEmptyTrash -bool false

# List view as default
defaults write com.apple.finder FXPreferredViewStyle Nlsv

# Remove recent tags from sidebar
defaults write com.apple.finder ShowRecentTags -int 0

# Show ~/Library and /Volumes folders
chflags nohidden ~/Library
sudo chflags nohidden /Volumes

# Enable spring loading for directories
defaults write NSGlobalDomain com.apple.springing.enabled -bool true

# Don't create .DS_Store on network/USB volumes
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true

# === Keyboard & Input ===
# Disable press-and-hold for accent characters (enable key repeat)
defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false

# Fast keyboard repeat rate
defaults write NSGlobalDomain KeyRepeat -int 2
defaults write NSGlobalDomain InitialKeyRepeat -int 15

# Use F1, F2, etc. as standard function keys
defaults write com.apple.keyboard.fnState -int 1

# === System & Security ===
# Save to disk by default (not iCloud)
defaults write NSGlobalDomain NSDocumentSaveNewDocumentsToCloud -bool false

# Disable "Are you sure you want to open" dialog
defaults write com.apple.LaunchServices LSQuarantine -bool false

# Show hostname when clicking login screen clock
sudo defaults write /Library/Preferences/com.apple.loginwindow AdminHostInfo HostName

# === Audio & Media ===
# Disable interface sound effects
defaults write com.apple.systemsound com.apple.sound.uiaudio.enabled -int 0

# Disable sound feedback for volume changes
defaults write -g com.apple.sound.beep.feedback -bool false

# Disable boot chime
sudo nvram SystemAudioVolume=" "

# Better Bluetooth audio quality
defaults write com.apple.BluetoothAudioAgent "Apple Bitpool Min (editable)" -int 40

# Prevent Photos from auto-opening when devices connect
defaults -currentHost write com.apple.ImageCapture disableHotPlug -bool YES

# === Screenshots ===
# Save screenshots as PNG
defaults write com.apple.screencapture type -string "png"

# === Cleanup ===
# Remove duplicates from "Open With" menu
/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister -kill -r -domain local -domain system -domain user

echo "macOS setup completed! Restart required for some changes to take effect."
```

### Install Required Tools
```bash
# Install Homebrew (if not installed)
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install essential tools
brew install git tmux neovim fzf ripgrep

# Install fzf shell integration
$(brew --prefix)/opt/fzf/install

# Install Powerlevel10k theme
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ~/powerlevel10k
```

### Additional Setup
- Configure 1Password for SSH signing (if using)
- Set up development directories  
- Configure terminal app preferences
- Run `p10k configure` for theme setup

## Philosophy

This setup maintains the benefits of version-controlled dotfiles while adopting modern XDG standards. Non-XDG software is cleanly separated in `home-dir-configs/` rather than abandoned, and the approach scales across multiple machines through git.

Key principles:
- **XDG Compliance**: Follow standards for config organization
- **Security**: Never track secrets, tokens, or sensitive data
- **Simplicity**: Minimize symlinks and complexity  
- **Portability**: Easy deployment across multiple machines
- **History**: Preserve git history through migrations