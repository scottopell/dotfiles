#!/bin/bash
input=$(cat)
message=$(echo "$input" | jq -r '.message // "Claude Code Notification"')

if command -v terminal-notifier &>/dev/null; then
  terminal-notifier -title "Claude Code" -message "$message" -activate org.alacritty
else
  osascript -e "display notification \"$message\" with title \"Claude Code\""
fi
