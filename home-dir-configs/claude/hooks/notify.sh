#!/bin/bash
input=$(cat)
message=$(echo "$input" | jq -r '.message // "Claude Code Notification"')
osascript -e "display notification \"$message\" with title \"Claude Code\""
