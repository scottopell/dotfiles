# Portable agent configuration

This directory contains vendor-neutral agent skills intended to work across compatible coding-agent hosts.

The tracked source is installed through a single link:

```text
~/.agents/skills -> ~/.config/agents/skills
```

Create or verify the link with:

```sh
~/.config/scripts/bootstrap-home.sh --dry-run
~/.config/scripts/bootstrap-home.sh
```

Claude-specific hooks, commands, status-line integration, plugins, history tooling, and runtime state are not part of the portable setup. Prior versions remain available in this repository's Git history.

`~/AGENTS.md` is intentionally machine-specific and is not managed by this repository. Different machines may carry different host-level guidance.
