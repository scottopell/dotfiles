#!/bin/bash
input=$(cat)
message=$(echo "$input" | jq -r '.message // "Claude Code Notification"')

if command -v terminal-notifier &>/dev/null; then
  terminal-notifier -title "Claude Code" -message "$message" \
    -appIcon "https://registry.npmmirror.com/@lobehub/icons-static-png/latest/files/dark/claude-color.png" \
    -activate org.alacritty
else
  osascript -e "display notification \"$message\" with title \"Claude Code\""
fi
