# Home-directory configuration

These files are tracked under `~/.config` but must appear at fixed paths in the home directory:

| Tracked source | Home entry point |
|---|---|
| `~/.config/home-dir-configs/p10k.zsh` | `~/.p10k.zsh` |
| `~/.config/home-dir-configs/psqlrc` | `~/.psqlrc` |

Install them with the repository bootstrap:

```sh
~/.config/scripts/bootstrap-home.sh --dry-run
~/.config/scripts/bootstrap-home.sh
```

The bootstrap is idempotent for correct links and refuses to overwrite an existing file, directory, or different symlink.

Portable agent skills are documented separately in [`../agents/README.md`](../agents/README.md).
