---
name: uv-script
description: Write self-contained, single-file Python scripts using uv and PEP 723 inline metadata. Use this skill whenever writing a Python script, CLI tool, one-off automation, or helper that should run without a virtualenv or requirements.txt -- especially when the user says "script", "single-file", "uv", or asks for something quick in Python that needs third-party packages.
---
# Self-Contained Python Scripts with uv + PEP 723

When writing Python scripts, make them self-contained and directly executable
using `uv` and PEP 723 inline script metadata. The script carries its own
dependency declarations and runs on any machine with `uv` installed -- no
virtualenv, no requirements.txt, no setup steps.

## Required Structure

```python
#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.13"
# dependencies = [
#     "httpx>=0.27",
# ]
# ///
```

Then `chmod +x script.py` and run as `./script.py`.

## Shebang

`#!/usr/bin/env -S uv run --script`

The `-S` flag is required so that `env` splits the argument string and passes
`run --script` as separate arguments to `uv`. Without `-S`, the OS treats
`uv run --script` as a single binary name and the script fails to execute.

## PEP 723 Inline Metadata Block

The block is delimited by `# /// script` and `# ///`. Content between the
delimiters is TOML, with each line prefixed by `# `. `uv` parses this block,
creates a cached virtual environment with the declared dependencies, and runs
the script inside it. The environment is keyed by content hash, so re-runs
after the first are near-instant.

### Available Fields

All fields are optional. The block itself is optional if there are no
dependencies, but include it anyway with at least `requires-python` so the
intent is clear.

| Field | Type | Purpose |
|---|---|---|
| `requires-python` | string | Python version constraint, e.g. `">=3.13"`. If the system Python doesn't match, `uv` automatically downloads a compatible one. Always set this to `">=3.13"`. |
| `dependencies` | array of strings | PEP 508 dependency specifiers, same format as `pyproject.toml`. Use `>=` lower bounds for reproducibility without over-constraining. Use `==` pins only when exact reproducibility matters more than getting patches. |
| `[tool.uv]` | table | uv-specific configuration. Supports `exclude-newer` (ISO 8601 date to cap resolution), `index` (array of `{name, url}` tables for custom package indexes), and `sources` (per-package source overrides for git/local/index sources). |
| `[tool.uv.sources.<pkg>]` | table | Override where a specific package is fetched from. Supports `git` (with optional `rev`/`tag`/`branch`), `path`, `url`, or `index` keys. Useful for private packages or pinning to a git commit. |

### Example with all fields

```python
# /// script
# requires-python = ">=3.13"
# dependencies = [
#     "httpx>=0.27",
#     "polars>=1.0",
#     "my-internal-lib>=0.5",
# ]
#
# [tool.uv]
# exclude-newer = "2025-03-01T00:00:00Z"
#
# [[tool.uv.index]]
# name = "internal"
# url = "https://pypi.internal.example.com/simple"
#
# [tool.uv.sources.my-internal-lib]
# index = "internal"
# ///
```

### Example sourcing a dependency from git

```python
# /// script
# requires-python = ">=3.13"
# dependencies = [
#     "some-tool",
# ]
#
# [tool.uv.sources.some-tool]
# git = "https://github.com/org/some-tool.git"
# tag = "v0.4.2"
# ///
```

## uv CLI Commands

Beyond just running scripts, `uv` has commands that help manage them:

- **`uv add --script script.py requests`** -- adds `requests` to the PEP 723
  dependencies block in `script.py`. Handles creating the block if it doesn't
  exist, and appending if it does. Prefer this over hand-editing the metadata
  block when adding deps to an existing script.
- **`uv run --with somepackage script.py`** -- temporarily adds a dependency at
  runtime without modifying the script. Useful for one-off debugging (e.g.,
  `uv run --with ipdb script.py` to drop into a debugger).

## Python 3.13+ Is the Floor

Since `requires-python = ">=3.13"`, use modern syntax freely. There is no need
to write backwards-compatible patterns:

- `match` statements instead of if/elif chains for structural matching
- `StrEnum` for string enums (stdlib `enum` module)
- `type` statement for type aliases (`type Vector = list[float]`)
- `ExceptionGroup` and `except*` for concurrent error handling
- f-strings everywhere (including nested f-strings, which work since 3.12)
- Union types as `X | Y` (not `Union[X, Y]`)
- Built-in generics: `list[int]`, `dict[str, Any]` (not `List`, `Dict`)

## Prefer Stdlib Over PyPI

Before adding a dependency, check whether the stdlib already covers it. Fewer
deps means faster first-run and fewer things that can break. Common stdlib
modules that eliminate popular PyPI packages:

- `tomllib` -- TOML parsing (replaces `tomli`)
- `sqlite3` -- local database (replaces reaching for `sqlalchemy` in simple cases)
- `csv` / `json` -- data format handling
- `dataclasses` -- structured data (replaces `attrs` / `pydantic` for simple cases)
- `zoneinfo` -- timezone handling (replaces `pytz`)
- `pathlib` -- file path manipulation (replaces `os.path`)
- `argparse` -- CLI argument parsing (replaces `click` / `typer` for simple CLIs)
- `urllib.request` -- basic HTTP when you just need a GET and don't want `httpx`

Only pull in a PyPI package when the stdlib equivalent would be significantly
more verbose or missing critical functionality (e.g., `httpx` for anything
beyond trivial GET requests, `polars`/`pandas` for dataframes).

## After Writing the Script

Set the execute bit: `chmod +x script.py`. The script won't run without it.
