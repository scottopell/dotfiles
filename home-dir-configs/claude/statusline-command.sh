#!/usr/bin/env bash
# Claude Code status line - mirrors p10k left prompt (dir + vcs) plus model info

input=$(cat)

cwd=$(echo "$input" | jq -r '.workspace.current_dir // .cwd')
model=$(echo "$input" | jq -r '.model.display_name')

# Abbreviate home directory with ~
short_dir="${cwd/#$HOME/\~}"

# Git branch and status (skip locks to avoid blocking)
git_part=""
if git -C "$cwd" --no-optional-locks rev-parse --is-inside-work-tree &>/dev/null 2>&1; then
  branch=$(git -C "$cwd" --no-optional-locks symbolic-ref --short HEAD 2>/dev/null \
           || git -C "$cwd" --no-optional-locks rev-parse --short HEAD 2>/dev/null)
  if [ -n "$branch" ]; then
    # Check for uncommitted changes
    if git -C "$cwd" --no-optional-locks diff --quiet 2>/dev/null \
       && git -C "$cwd" --no-optional-locks diff --cached --quiet 2>/dev/null; then
      dirty=""
    else
      dirty="*"
    fi
    git_part=" \033[2m·\033[0m \033[33m${branch}${dirty}\033[0m"
  fi
fi

# Color model name by tier
case "$model" in
  *Opus*)   model_color="\033[35m" ;;   # magenta
  *Sonnet*) model_color="\033[36m" ;;   # cyan
  *Haiku*)  model_color="\033[32m" ;;   # green
  *)        model_color="\033[37m" ;;   # white
esac

printf "%b" "${short_dir}${git_part} \033[2m·\033[0m ${model_color}${model}\033[0m"
