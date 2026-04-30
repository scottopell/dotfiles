# Claude Code Data Format — Detailed Reference

## Projects Directory

`~/.claude/projects/` contains one directory per project the user has opened with Claude Code. Directory names encode the absolute path:

```
/Users/name/Documents/projects/my-app → -Users-name-Documents-projects-my-app
```

To recover the original path: replace leading `-` with `/`, then replace remaining `-` cautiously (dashes also appear in directory names). The `cwd` field in session/conversation data gives you the canonical path — prefer reading `cwd` over decoding the directory name.

### Conversation JSONL Files

Located at `~/.claude/projects/<project-dir>/<session-uuid>.jsonl`.

Each line is one event. Relevant event types:

| `type`                  | What it is                  | Worth reading?                           |
| ----------------------- | --------------------------- | ---------------------------------------- |
| `user`                  | User message                | Yes — what the user asked or said        |
| `assistant`             | Assistant response          | Yes — pull `text` blocks from content    |
| `progress`              | Tool execution progress     | No — internal plumbing                   |
| `file-history-snapshot` | File state at session start | No — just file listings                  |

#### User message structure

```json
{
  "type": "user",
  "message": { "role": "user", "content": "the user's message as a string" },
  "timestamp": "2026-03-15T10:30:00.000Z",
  "sessionId": "uuid",
  "cwd": "/Users/name/Documents/projects/my-app"
}
```

#### Assistant message structure

```json
{
  "type": "assistant",
  "message": {
    "role": "assistant",
    "content": [
      { "type": "thinking", "text": "internal reasoning (skip)" },
      { "type": "text", "text": "The actual visible response" },
      {
        "type": "tool_use",
        "id": "...",
        "name": "Read",
        "input": { "file_path": "..." }
      }
    ]
  },
  "timestamp": "2026-03-15T10:30:05.000Z"
}
```

**Extraction strategy:** Only pull `text` type blocks from assistant content arrays. The `thinking` blocks are internal reasoning; `tool_use` blocks are mechanical actions — neither is what the assistant said to the user.

### Memory Files

Located at `~/.claude/projects/<project-dir>/memory/`.

Each memory file has YAML frontmatter:

```markdown
---
name: descriptive-name
description: one-line summary used for relevance matching
type: user|feedback|project|reference
---

The memory content. For feedback/project types, structured as:
rule/fact, then **Why:** and **How to apply:** lines.
```

**Memory types and what they hold:**

| Type        | Contains                                 | Useful for queries like                       |
| ----------- | ---------------------------------------- | --------------------------------------------- |
| `user`      | User's role, preferences, expertise      | "what does Claude know about me"              |
| `feedback`  | Workflow corrections and confirmations   | "what coding-style rule did I tell Claude"    |
| `project`   | Active work, goals, decisions, deadlines | "what's the status of project X"              |
| `reference` | Pointers to external resources           | "where do I track Y" / "what's the URL for Z" |

`MEMORY.md` in each memory directory is an index with one-line summaries. Read it first to triage which individual memory files are worth opening.

### Session Metadata

Located at `~/.claude/sessions/<pid>.json`. Light metadata:

```json
{
  "pid": 12345,
  "sessionId": "uuid",
  "cwd": "/Users/name/Documents/projects/my-app",
  "startedAt": "2026-03-15T10:30:00.000Z",
  "kind": "interactive",
  "entrypoint": "cli"
}
```

Useful for narrowing a search by date or project — e.g., "find sessions in the foo repo from last Tuesday" → grep these files for matching `cwd` and `startedAt`, then open the corresponding transcripts.

### Global History

`~/.claude/history.jsonl` — append-only log of all sessions. Use for timeline reconstruction or for "list all sessions in date range" queries.

## Desktop App: local-agent-mode-sessions

The Claude desktop app stores local agent mode sessions at:

```
~/Library/Application Support/Claude/local-agent-mode-sessions/<outer-uuid>/<inner-uuid>/
```

Each session contains:

- `local_<session-uuid>.json` — session metadata (`sessionId`, `cwd`, `startedAt`, `model`, `title`)
- `local_<session-uuid>/audit.jsonl` — audit log of every tool call (Read, Write, Bash, Edit, MCP calls)
- `local_<session-uuid>/.claude/projects/<path-encoded-name>/<uuid>.jsonl` — conversation transcript (same format as CLI)

### Audit Log Records

Each line is a JSON record of one agent action:

```json
{
  "type": "tool_call",
  "toolName": "Bash",
  "input": {"command": "npm test"},
  "output": "...",
  "timestamp": "2026-04-10T14:22:00Z",
  "sessionId": "..."
}
```

The audit log tells you *what happened*; the conversation transcript tells you *why*. When both are available for the same session, use them together.

## Processing Order for Searches

For maximum efficiency when answering a focused query:

1. **Memory files first** — Pre-distilled, highest signal-to-noise. A hit here is often the final answer.
2. **MEMORY.md indexes** — Fast triage of what each project knows before diving into bodies.
3. **Conversation JSONL** — Rich but verbose; rely on `rg` to narrow before opening.
4. **Audit logs** — Best for "what command/file" questions rather than "what was discussed."
5. **Session metadata** — Use only to filter by project/date when you need to scope a broader search.
