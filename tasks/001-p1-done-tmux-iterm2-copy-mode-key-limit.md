---
created: 2026-03-03
priority: p1
status: done
---

# tmux copy-mode: exactly 3 keypresses then stalls in iTerm2

## Summary

After switching from Alacritty to iTerm2, all copy-mode navigation (j, k, h, l,
arrow keys, C-u, C-d, etc.) stalled after exactly 3 keypresses. The 4th keypress
of any kind would not register. Worked fine in a normal shell pane; only affected
copy-mode.

## Context

**Affected config:** `tmux/tmux.conf`
**tmux version:** 3.5a
**iTerm2 version:** 3.6.6

### Diagnostic path

Initial hypothesis was terminal key-repeat delivery (Alacritty sends a sustained
stream; iTerm2 throttles). Applied `-r` flag to copy-mode-vi bindings (j/k/h/l).
Did not fix it.

Key diagnostic tests that narrowed the root cause:

1. **Shell pane:** holding j repeats forever — iTerm2 is delivering key events fine.
2. **Copy-mode, Down arrow (multi-byte):** also stops at 3 — not j/k binding-specific.
3. **Copy-mode, manual tapping:** 4th manual tap also fails — not OS key-repeat specific.
4. **Copy-mode, C-u (halfpage-up, opposite direction):** also stops at 3 — not
   directional, not a content boundary.

All copy-mode key actions, regardless of key, sequence type, or direction, stopped
after exactly 3. Shell panes were unaffected. This narrowed the cause to a
tmux/iTerm2 interaction specific to copy-mode.

### Root cause

`tmux show-options -g terminal-features` showed:

```
terminal-features[0] xterm*:clipboard:ccolour:cstyle:focus:title
```

The `focus` feature causes tmux to send `\033[?1004h` to the outer terminal,
enabling focus event reporting. This mode change only fires for terminals whose
`$TERM` matches `xterm*`.

- **Alacritty** (previous terminal): used `TERM=alacritty` — does not match `xterm*`,
  focus feature never activated, no `\033[?1004h` sent, copy-mode worked fine.
- **iTerm2**: uses `TERM=xterm-256color` — matches `xterm*`, focus feature activated,
  `\033[?1004h` sent at client connect time.

Once iTerm2 receives `\033[?1004h`, it changes key event delivery behavior for that
pty in a way that creates an implicit acknowledgment expectation. Shell panes satisfy
this via key echo (the shell echoes the character back, which iTerm2 reads as
"application processed input"). Copy-mode does not echo keys — tmux consumes them
internally — so iTerm2 stalls after delivering 3 unacknowledged events.

The number 3 appears to be iTerm2's internal unacknowledged-event buffer depth
when in focus-reporting mode.

### Confirmed by

Running an independent tmux server (`tmux -L test new-session`) with the patched
config, which re-reads terminal-features fresh at client connect. Copy-mode key
repeat worked correctly with `focus` removed.

## Fix / Acceptance Criteria

- [x] In `tmux/tmux.conf`, replace the default xterm* `terminal-features` entry
      with one that omits `focus`:

```tmux
set -g terminal-features 'xterm*:clipboard:ccolour:cstyle:title'
```

This prevents tmux from sending `\033[?1004h` to iTerm2. Focus event reporting
is never enabled, iTerm2's key delivery stays in normal mode, and copy-mode
keypresses are unlimited.

## Notes

- `set -g` (not `-ga`) replaces `terminal-features[0]`. The other default entries
  (`screen*:title`, `rxvt*:ignorefkeys`) are at [1] and [2] and are unaffected.
- Requires a full tmux server restart (`tmux kill-server && tmux`) — sourcing the
  config is not sufficient because terminal-features are applied at client connect
  time, not on source. Use `tmux -L test new-session` to test without killing an
  existing session.
- The `-r` flags added to copy-mode-vi h/j/k/l during diagnosis are harmless but
  ineffective — `-r` is a no-op in key tables where no prefix is required (copy-mode).
- `focus-events` (the tmux pane option for forwarding focus events to pane processes)
  is separate from `terminal-features focus` (which controls whether tmux enables
  focus reporting on the outer terminal at all).
