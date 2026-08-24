#!/bin/bash
# macOS system preferences for development
# Run: ./scripts/macos-setup.sh

set -e

# === UI & Interface ===
defaults write com.apple.menuextra.battery ShowPercent -string "YES"
defaults write com.apple.dock tilesize -int 32
defaults write com.apple.dock "mru-spaces" -bool "false"

# === Finder ===
defaults write com.apple.finder NewWindowTarget -string "PfLo"
defaults write com.apple.finder NewWindowTargetPath -string "file://${HOME}/"
defaults write com.apple.finder _FXShowPosixPathInTitle -bool true
defaults write NSGlobalDomain AppleShowAllExtensions -bool true
defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"
defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false
defaults write com.apple.finder FXPreferredViewStyle Nlsv
defaults write com.apple.finder ShowRecentTags -int 0
chflags nohidden ~/Library
defaults write NSGlobalDomain com.apple.springing.enabled -bool true
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true

# === Keyboard ===
defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false
defaults write NSGlobalDomain KeyRepeat -int 2
defaults write NSGlobalDomain InitialKeyRepeat -int 15

# === System ===
defaults write NSGlobalDomain NSDocumentSaveNewDocumentsToCloud -bool false

# === Devices ===
defaults -currentHost write com.apple.ImageCapture disableHotPlug -bool YES

echo "Done. Some changes take effect after the affected application restarts or at the next login."
