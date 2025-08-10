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

# Setup shell configs and legacy symlinks
echo <<<
[ -f ~/.config/zsh/.zshrc ] && source ~/.config/zsh/.zshrc
[ -f ~/dotfiles/fzf-git.sh/fzf-git.sh ] && source ~/dotfiles/fzf-git.sh/fzf-git.sh
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
>>> >> ~/.zshrc

# Create symlinks for home directory configs
ln -s ~/dotfiles/home-dir-configs/psqlrc ~/.psqlrc
ln -s ~/dotfiles/home-dir-configs/p10k.zsh ~/.p10k.zsh
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
brew install git tmux nvim fzf

# Install vim-plug for Neovim
sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs \
       https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'

# Install fzf shell integration
$(brew --prefix)/opt/fzf/install

# Install Powerlevel10k
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
```

### Additional Setup
- Configure 1Password for SSH signing (if using)
- Set up development directories
- Configure terminal app preferences

