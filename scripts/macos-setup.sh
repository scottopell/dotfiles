#!/bin/bash
# macOS system preferences for development
# Run: ./scripts/macos-setup.sh

set -e

# Ask for administrator password upfront
sudo -v

# Keep sudo alive
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

# === UI & Interface ===
defaults write NSGlobalDomain AppleShowScrollBars -string "Always"
defaults write com.apple.menuextra.battery ShowPercent -string "YES"
defaults write com.apple.dock tilesize -int 32
defaults write com.apple.dock autohide -bool false
defaults write com.apple.dock persistent-apps -array ""
defaults write com.apple.dock "mru-spaces" -bool "false"

# === Finder ===
defaults write com.apple.finder NewWindowTarget -string "PfLo"
defaults write com.apple.finder NewWindowTargetPath -string "file://${HOME}/"
defaults write com.apple.finder _FXShowPosixPathInTitle -bool true
defaults write NSGlobalDomain AppleShowAllExtensions -bool true
defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"
defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false
defaults write com.apple.finder WarnOnEmptyTrash -bool false
defaults write com.apple.finder FXPreferredViewStyle Nlsv
defaults write com.apple.finder ShowRecentTags -int 0
chflags nohidden ~/Library
sudo chflags nohidden /Volumes
defaults write NSGlobalDomain com.apple.springing.enabled -bool true
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true

# === Keyboard ===
defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false
defaults write NSGlobalDomain KeyRepeat -int 2
defaults write NSGlobalDomain InitialKeyRepeat -int 15
defaults write com.apple.keyboard.fnState -int 1

# === System ===
defaults write NSGlobalDomain NSDocumentSaveNewDocumentsToCloud -bool false
defaults write com.apple.LaunchServices LSQuarantine -bool false
sudo defaults write /Library/Preferences/com.apple.loginwindow AdminHostInfo HostName

# === Audio ===
defaults write com.apple.systemsound com.apple.sound.uiaudio.enabled -int 0
defaults write -g com.apple.sound.beep.feedback -bool false
sudo nvram SystemAudioVolume=" "
defaults write com.apple.BluetoothAudioAgent "Apple Bitpool Min (editable)" -int 40
defaults -currentHost write com.apple.ImageCapture disableHotPlug -bool YES

# === Screenshots ===
defaults write com.apple.screencapture type -string "png"

# === Cleanup ===
/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister -kill -r -domain local -domain system -domain user

echo "Done! Restart required for some changes to take effect."
