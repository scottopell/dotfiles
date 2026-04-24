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

    # Broadcast to iTerm2 via OSC profile switch. Works over SSH: the escape
    # travels to the local iTerm. Requires profiles literally named "Light" / "Dark".
    # Inside tmux, wrap in DCS passthrough so tmux forwards the OSC to iTerm.
    if [[ -n "$ITERM_SESSION_ID" || "$LC_TERMINAL" == iTerm2 || "$TERM_PROGRAM" == iTerm.app ]]; then
        local profile
        [[ "$target" == light ]] && profile=Light || profile=Dark
        if [[ -n "$TMUX" ]]; then
            printf '\ePtmux;\e\e]1337;SetProfile=%s\a\e\\' "$profile"
        else
            printf '\e]1337;SetProfile=%s\a' "$profile"
        fi
    fi

    print "theme: $target (run 'exec zsh' in other shells to reload prompt/FZF)"
}

_theme_ensure_state
export THEME="$(<"$_theme_state_file")"
