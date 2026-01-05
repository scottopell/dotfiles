# tmux-ptree.sh
# Source from .zshrc or .bashrc
# Works: bash/zsh, macOS/Linux

_tmux_ptree_is_descendant() {
  local pid=$1 ancestor=$2
  while [[ $pid -gt 1 ]]; do
    [[ $pid -eq $ancestor ]] && return 0
    pid=$(ps -o ppid= -p "$pid" 2>/dev/null | tr -d ' ')
    [[ -z $pid ]] && return 1
  done
  return 1
}

_tmux_ptree_children() {
  ps -eo pid=,ppid= 2>/dev/null | awk -v p="$1" '$2==p {print $1}'
}

# Returns true for background/noise processes we should ignore
_tmux_ptree_is_noise() {
  case "$1" in
    *gitstatusd*|*gitstatus*|-zsh|zsh|bash|-bash) return 0 ;;
    *) return 1 ;;
  esac
}

tmux_ptree() {
  [[ -n "$ZSH_VERSION" ]] && setopt local_options no_xtrace no_verbose 2>/dev/null

  local scope="-a" show_idle=1 show_orphans=1 max_cmd=70 verbose=0

  while [[ $# -gt 0 ]]; do
    case $1 in
      -s) scope="-s" ;;
      -b|--busy) show_idle=0 ;;
      --no-orphans) show_orphans=0 ;;
      -v|--verbose) verbose=1 ;;
      -w|--wide) max_cmd=200 ;;
      -h|--help)
        cat <<'HELP'
tmux_ptree - Show process trees for tmux panes

Usage: tmux_ptree [options]

Options:
  -s           Current session only (default: all sessions)
  -b, --busy   Only show panes with running processes
  -v, --verbose  Show full command lines
  -w, --wide   Wider output (200 chars)
  --no-orphans Hide orphan processes
  -h, --help   Show this help

Output format:
  PID [elapsed] command...
  Elapsed time shows how long the process has been running.

Examples:
  tmux_ptree -b        # Find panes with stuff running
  tmux_ptree -s -b     # Current session, busy panes only
  kill <PID>           # Kill a stuck process shown in output
HELP
        return 0 ;;
      *) echo "Unknown option: $1"; return 1 ;;
    esac
    shift
  done

  tmux list-panes $scope -F '#{session_name}:#{window_index}.#{pane_index} #{pane_pid} #{pane_tty}' | (
    while IFS=' ' read -r target root_pid tty; do
      children=$(_tmux_ptree_children "$root_pid")

      # Filter out shell children (zsh/bash subprocesses aren't "real" work)
      real_children=""
      for cpid in $children; do
        cmd_name=$(ps -o comm= -p "$cpid" 2>/dev/null)
        if ! _tmux_ptree_is_noise "$cmd_name"; then
          real_children="$real_children $cpid"
        fi
      done
      real_children="${real_children# }"  # trim leading space

      num_children=$(echo "$real_children" | wc -w | tr -d ' ')
      [[ -z "$real_children" ]] && num_children=0

      [[ $show_idle -eq 0 && $num_children -eq 0 ]] && continue

      # Collect and filter orphans
      orphan_list=""
      for p in $(ps -t "$tty" -o pid= 2>/dev/null | tr -d ' '); do
        if ! _tmux_ptree_is_descendant "$p" "$root_pid"; then
          cmd_name=$(ps -o comm= -p "$p" 2>/dev/null)
          if ! _tmux_ptree_is_noise "$cmd_name"; then
            orphan_list="${orphan_list}${p}
"
          fi
        fi
      done
      orphan_list="${orphan_list%$'\n'}"

      printf '\n== %s ==\n' "$target"

      if [[ $num_children -eq 0 ]]; then
        printf '  (idle)\n'
      else
        printf '  shell %s\n' "$root_pid"
        for cpid in $real_children; do
          info=$(ps -o etime=,command= -p "$cpid" 2>/dev/null | head -1)
          [[ -z "$info" ]] && continue  # process exited
          etime=${info%% *}
          cmd=${info#* }
          if [[ $verbose -eq 1 ]]; then
            printf '  %s [%s] %s\n' "$cpid" "$etime" "$cmd"
          else
            printf '  %s [%s] %.70s\n' "$cpid" "$etime" "$cmd"
          fi

          # Grandchildren
          for gcpid in $(_tmux_ptree_children "$cpid"); do
            info=$(ps -o etime=,command= -p "$gcpid" 2>/dev/null | head -1)
            [[ -z "$info" ]] && continue
            etime=${info%% *}
            cmd=${info#* }
            if [[ $verbose -eq 1 ]]; then
              printf '    └─%s [%s] %s\n' "$gcpid" "$etime" "$cmd"
            else
              printf '    └─%s [%s] %.64s\n' "$gcpid" "$etime" "$cmd"
            fi
          done
        done
      fi

      # Orphans section
      if [[ $show_orphans -eq 1 && -n "$orphan_list" ]]; then
        num_orphans=$(echo "$orphan_list" | grep -c . 2>/dev/null || echo 0)
        printf '  orphans (%s):\n' "$num_orphans"
        echo "$orphan_list" | while read -r opid; do
          [[ -z "$opid" ]] && continue
          info=$(ps -o etime=,command= -p "$opid" 2>/dev/null | head -1)
          [[ -z "$info" ]] && continue
          etime=${info%% *}
          cmd=${info#* }
          if [[ $verbose -eq 1 ]]; then
            printf '    %s [%s] %s\n' "$opid" "$etime" "$cmd"
          else
            printf '    %s [%s] %.65s\n' "$opid" "$etime" "$cmd"
          fi
        done
      fi
    done
  )
}

(return 0 2>/dev/null) && echo "tmux_ptree loaded. Run: tmux_ptree -h"
