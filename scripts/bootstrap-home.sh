#!/bin/bash
# Install portable dotfile entry points into the current user's home directory.
# Existing files, directories, and different symlinks are never overwritten.

set -euo pipefail

dry_run=false
case "${1:-}" in
  "") ;;
  --dry-run) dry_run=true ;;
  *) echo "usage: $0 [--dry-run]" >&2; exit 2 ;;
esac

config_dir="${XDG_CONFIG_HOME:-$HOME/.config}"
agents_dir="$HOME/.agents"

links=(
  "$config_dir/agents/skills|$agents_dir/skills"
  "$config_dir/home-dir-configs/p10k.zsh|$HOME/.p10k.zsh"
  "$config_dir/home-dir-configs/psqlrc|$HOME/.psqlrc"
)

# Preflight every target before changing anything.
if [[ -e "$agents_dir" || -L "$agents_dir" ]]; then
  if [[ ! -d "$agents_dir" || -L "$agents_dir" ]]; then
    echo "refusing: $agents_dir exists and is not a normal directory" >&2
    exit 1
  fi
fi

for entry in "${links[@]}"; do
  source=${entry%%|*}
  target=${entry#*|}

  if [[ ! -e "$source" ]]; then
    echo "missing source: $source" >&2
    exit 1
  fi
  if [[ -L "$target" && "$(readlink "$target")" == "$source" ]]; then
    continue
  fi
  if [[ -e "$target" || -L "$target" ]]; then
    echo "refusing: $target already exists" >&2
    exit 1
  fi
done

run() {
  if $dry_run; then
    printf 'would run:'
    printf ' %q' "$@"
    printf '\n'
  else
    "$@"
  fi
}

if [[ ! -d "$agents_dir" ]]; then
  run mkdir -p "$agents_dir"
else
  echo "ok: $agents_dir already exists"
fi

for entry in "${links[@]}"; do
  source=${entry%%|*}
  target=${entry#*|}

  if [[ -L "$target" && "$(readlink "$target")" == "$source" ]]; then
    echo "ok: $target -> $source"
  else
    run ln -s "$source" "$target"
  fi
done
