# Theme state: light or dark. Switched manually via `theme light|dark|toggle|auto`.
# Consumers read $THEME (exported) or the state file directly.
#
# State file: $XDG_STATE_HOME/theme/current (plain "light" or "dark")
# Broadcasts on change: tmux source-file, iTerm2 profile via OSC.
# Nvim watches the state file via fs_event; shells must `exec zsh` to reload.

_theme_state_dir="${XDG_STATE_HOME:-$HOME/.local/state}/theme"
_theme_state_file="$_theme_state_dir/current"

_theme_macos_system() {
    [[ "$(uname)" == "Darwin" ]] || return 2
    if defaults read -g AppleInterfaceStyle 2>/dev/null | grep -q Dark; then
        print dark
    else
        print light
    fi
}

_theme_default() {
    _theme_macos_system 2>/dev/null || print dark
}

_theme_ensure_state() {
    [[ -d "$_theme_state_dir" ]] || mkdir -p "$_theme_state_dir"
    [[ -f "$_theme_state_file" ]] || _theme_default >| "$_theme_state_file"
}

# Emits iTerm2 OSC 1337 SetProfile for the given mode. Wraps in DCS passthrough
# when inside tmux. Called both on theme change and on shell startup so new
# windows snap to the correct profile (iTerm's default-for-new-windows is fixed
# in prefs and we don't want to fight it).
_theme_emit_iterm() {
    local mode="$1" profile
    [[ -n "$ITERM_SESSION_ID" || "$LC_TERMINAL" == iTerm2 || "$TERM_PROGRAM" == iTerm.app ]] || return 0
    [[ "$mode" == light ]] && profile=Light || profile=Dark
    if [[ -n "$TMUX" ]]; then
        printf '\ePtmux;\e\e]1337;SetProfile=%s\a\e\\' "$profile"
    else
        printf '\e]1337;SetProfile=%s\a' "$profile"
    fi
}

# Aligns Claude Code's theme with the current mode. Only affects new sessions
# (settings are read at session startup). For running sessions, use /theme.
_theme_update_claude() {
    local mode="$1" settings="$HOME/.claude/settings.json"
    [[ -f "$settings" ]] || return 0
    command -v jq >/dev/null 2>&1 || return 0
    local tmp
    tmp=$(mktemp) || return 0
    if jq --arg t "$mode" '.theme = $t' "$settings" > "$tmp" 2>/dev/null; then
        mv "$tmp" "$settings"
    else
        rm -f "$tmp"
    fi
}

theme() {
    _theme_ensure_state
    local current target
    current=$(<"$_theme_state_file")
    target="${1:-status}"

    case "$target" in
        light|dark) ;;
        toggle)
            [[ "$current" == dark ]] && target=light || target=dark
            ;;
        auto)
            target=$(_theme_macos_system) || {
                print -u2 "theme: auto requires macOS"; return 1
            }
            ;;
        status|"")
            print "$current"; return 0
            ;;
        *)
            print -u2 "theme: usage: theme [light|dark|toggle|auto|status]"
            return 1
            ;;
    esac

    print "$target" >| "$_theme_state_file"
    export THEME="$target"

    # Broadcast to tmux (all sessions on the default server reload the conf)
    if [[ -n "$TMUX" ]] || { command -v tmux >/dev/null 2>&1 && tmux info >/dev/null 2>&1; }; then
        tmux source-file "${XDG_CONFIG_HOME:-$HOME/.config}/tmux/tmux.conf" >/dev/null 2>&1
    fi

    _theme_emit_iterm "$target"
    _theme_update_claude "$target"

    print "theme: $target (run 'exec zsh' in other shells; /theme in running claude-code)"
}

_theme_ensure_state
export THEME="$(<"$_theme_state_file")"
_theme_emit_iterm "$THEME"
