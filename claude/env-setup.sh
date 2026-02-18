# Sourced by Claude Code before each Bash command (via CLAUDE_ENV_FILE).
# Refreshes SSH_AUTH_SOCK from tmux so commit signing works even after
# the SSH agent reconnects.
if [ -n "$TMUX" ]; then
    eval "$(tmux show-environment -s SSH_AUTH_SOCK 2>/dev/null)"
fi
