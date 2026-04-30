---
name: cc-history-query
description: >
  Search the user's past Claude Code conversation history for a specific focused fact. Trigger ONLY when the user
  explicitly asks to look in past conversations — phrases like "search our past conversations", "find that
  conversation where...", "what did I tell Claude about X", "did I mention Y before in chat", "look in my Claude
  history for Z". Greps conversation transcripts (JSONL), memory files, audit logs, and session metadata under
  ~/.claude and the Claude desktop app's local-agent-mode-sessions directory. Do NOT trigger on "have I worked on
  X before" or "what was the fix I did for Y" — those are questions about the codebase or git history, not the
  conversation log; check the code or git log instead.
---

# cc-history-query — Search Past Claude Conversations

Look up specific, focused facts from the user's past Claude Code conversation history.

This skill is **read-only** and **search-focused**. You are not ingesting, summarizing, or building anything — you are answering one targeted question by grepping conversation history and citing the matches.

## When to use this skill

Use it only when the user explicitly references their past chat history with Claude. Strong trigger phrases:

- "Search our past conversations for X"
- "Find that conversation where we talked about Y"
- "What did I tell Claude about Z?"
- "Did I mention <topic> in a previous session?"
- "Look in my Claude history for ..."

## When NOT to use this skill

Do not use it for questions that are really about code or git history, even if they sound related:

- "Have I worked on X before?" → check the codebase / `git log`
- "What was the fix I did for the auth bug?" → check `git log` / `git blame`
- "How does this project's auth work?" → read the code

If the user asks one of those, answer from code/git. Only fall back to this skill if they explicitly redirect ("no, look in our chat history").

## Where the data lives

Two source locations. **Search both.**

### Source 1: `~/.claude/` (CLI sessions)

```
~/.claude/
├── projects/<path-encoded-name>/
│   ├── <session-uuid>.jsonl        # conversation transcripts
│   └── memory/
│       ├── MEMORY.md
│       └── {user,feedback,project,reference}_*.md
├── sessions/<pid>.json             # session metadata (pid, sessionId, cwd, startedAt)
└── history.jsonl                   # global session log
```

### Source 2: `~/Library/Application Support/Claude/local-agent-mode-sessions/` (desktop app)

```
.../local-agent-mode-sessions/<outer-uuid>/<inner-uuid>/
├── local_<session-uuid>.json       # session metadata
└── local_<session-uuid>/
    ├── audit.jsonl                 # tool calls, commands, file accesses
    └── .claude/projects/<path-encoded-name>/<uuid>.jsonl   # transcript
```

## Search strategy: ripgrep first

Always start with `rg`. Do not read files top-to-bottom unless you have already narrowed to a small set of candidates.

### Step 1 — pick keywords

From the user's question, extract 1–3 distinctive keywords. Prefer rare/specific terms over common ones:

- "what did I tell Claude about the snowflake credential rotation" → `snowflake`, `credential rotation`
- "find the conversation where we discussed graphql federation" → `graphql federation`, `federation`

If the user gives a date, project hint, or cwd hint, scope the search to that subdirectory first.

### Step 2 — grep across all four source types

```bash
# 1. CLI conversation transcripts
rg -l --no-heading 'KEYWORD' ~/.claude/projects --glob '*.jsonl'

# 2. CLI memory files
rg -l --no-heading 'KEYWORD' ~/.claude/projects --glob '*.md'

# 3. Desktop app conversation transcripts (excluding audit logs)
rg -l --no-heading 'KEYWORD' "$HOME/Library/Application Support/Claude/local-agent-mode-sessions" \
    --glob '*.jsonl' --glob '!audit.jsonl'

# 4. Desktop app audit logs
rg -l --no-heading 'KEYWORD' "$HOME/Library/Application Support/Claude/local-agent-mode-sessions" \
    --glob 'audit.jsonl'
```

Use `-l` (list files) when you expect many hits. Drop `-l` and add `-n -C 2` for context lines when there are only a handful.

If `rg` returns nothing, try a looser keyword or word-stem before giving up. Don't fall back to slurping whole files.

### Step 3 — locate the relevant region within each candidate

Do **not** read the candidate from the top and stop when you find something that partially fits. Long sessions (300+ lines) commonly have a setup phase followed by a resolution phase an hour later — reading only the beginning means you summarize the setup and miss the answer.

**For each candidate file:**

1. Run `rg -n 'KEYWORD' /path/to/session.jsonl` with the user's specific keywords to get line numbers. This immediately shows *where* in the session the relevant content is.
2. Also search for resolution-signal words derived from the user's framing:
   - If user said "we debugged X" → also grep for `bug`, `fix`, `fork`, `patch`, `root cause`
   - If user said "we built Y" → also grep for `deploy`, `commit`, `done`, `works`
   - If user said "we decided Z" → also grep for `decision`, `chose`, `going with`
3. Read the region around the **highest-line-number match** — that's where the conversation resolved. Use `Read` with `offset`/`limit` to grab 20–30 lines of context there.

```bash
# Get all matching line numbers, look at both early and late matches
rg -n 'KEYWORD' /path/to/session.jsonl

# Then read the tail region — where the resolution happened
# (adjust offset to the last cluster of matches)
```

**Validate before reporting:** Before summarizing, check that your answer covers the user's framing. If the user said "we found a bug in X" and your summary never mentions a bug, you read the wrong region — keep reading.

## Parsing JSONL events

Each line is one event. Relevant event types:

| `type`                  | Read?  | Notes |
| ----------------------- | ------ | ----- |
| `user`                  | Yes    | `.message.content` is a string |
| `assistant`             | Yes    | `.message.content` is an array — pull `text` blocks, skip `thinking` and `tool_use` |
| `progress`              | Skip   | tool execution plumbing |
| `file-history-snapshot` | Skip   | file listings only |

When extracting, capture `timestamp`, `cwd`, and `sessionId` so you can cite the source precisely.

## Audit logs

Each line in `audit.jsonl` is one tool call:

```json
{"type":"tool_call","toolName":"Bash","input":{"command":"npm test"},"timestamp":"...","sessionId":"..."}
```

Useful when the user asks something like "what command did I run when we were debugging X" or "which file did Claude edit during the Y session." Watch for secrets in `input` fields — redact them before quoting.

## Memory files

Already structured. Frontmatter carries `name`, `description`, `type` (`user` / `feedback` / `project` / `reference`). Body has the distilled fact. If a memory file matches, quote the fact directly — it's already in final form.

`MEMORY.md` in each project's `memory/` directory is the index. Useful when the user asks "what does Claude remember about project X" — read the index first, then drill into specific entries.

## Answering the user

Format the answer as:

1. **Direct answer** — the fact, in 1–3 sentences. Lead with this.
2. **Source citations** — for each piece of supporting evidence, give:
   - file path (use `~/...` shorthand; full absolute path is fine too)
   - timestamp from the JSONL line (if applicable)
   - a short verbatim quote (1–2 sentences max)

Example:

> You told Claude on 2026-03-12 that the Snowflake creds rotate every 90 days, triggered by an internal compliance script.
>
> - `~/.claude/projects/-Users-scott-dev-foo/abc123.jsonl` @ 2026-03-12T10:14:00Z
>   > "snowflake creds rotate every 90 days — triggered by compliance/rotate.py cron"

If the search returns nothing, say so plainly. Do not invent a plausible answer from general knowledge.

**Do not confirm a match too early.** If the session is large and your summary doesn't cover the user's framing (e.g. they said "we found a bug" but your summary only covers the setup), keep reading — the answer is probably in the tail of the same session.

## Privacy and safety

- Quote sparingly. Do not dump raw transcript blocks.
- If a match contains what looks like a secret, token, password, or API key, redact it before quoting.
- If the user's question implies they want a bulk history dump rather than a focused lookup, stop and ask — this skill is for focused facts, not export.

## Reference

See `references/claude-data-format.md` for full data structure details.
