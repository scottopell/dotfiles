---
name: cc-skill-extractor
description: >
  Mine the user's Claude Code conversation transcripts to find recurring patterns and codify
  them into reusable skills. Use when: the user says "extract this pattern into a skill",
  "codify this into a skill", "I do this a lot", "make a skill from my history", or describes
  a workflow they've been doing ad-hoc across conversations and wants formalized. The user
  may reference a specific pattern from the current conversation or describe one abstractly.
---

# Claude Code Skill Extractor

You are mining the user's Claude Code conversation history to find recurring patterns and
turn them into reusable skills. This is a collaborative, multi-step process -- not a
one-shot extraction.

## Data Model

Claude Code stores conversation transcripts as JSONL files in `~/.claude/projects/`.

### File layout

```
~/.claude/projects/
  <project-slug>/              # e.g., -Users-scott-opell-dev-myproject
    <session-uuid>.jsonl       # main conversation transcript
    <session-uuid>/
      subagents/
        agent-<id>.jsonl       # sub-agent transcripts (ignore for pattern mining)
```

**Always filter out** files under `/subagents/` directories -- those are sub-agent
transcripts, not the user's direct conversation.

### JSONL entry types

Each line is a JSON object with a `type` field:

- `"user"` -- user message. Content at `message.content` (string or array of blocks).
- `"assistant"` -- assistant message. Content at `message.content` (array of blocks).
- `"file-history-snapshot"` -- ignore these.

### Content blocks (assistant messages)

`message.content` is an array of blocks, each with a `type`:

- `{"type": "text", "text": "..."}` -- assistant text output
- `{"type": "tool_use", "name": "Agent", "input": {"description": "...", "prompt": "...", "subagent_type": "...", "run_in_background": bool}}` -- agent spawns
- `{"type": "tool_use", "name": "<other>", ...}` -- other tool calls

### Message ID grouping

**Critical quirk**: when an assistant message contains multiple tool calls, the JSONL
format splits them into separate entries that share the same `message.id`. To find
messages that spawn multiple agents simultaneously, you must group entries by
`message.id`, not treat each JSONL line as a separate message.

### User message content

`message.content` can be:
- A plain string (most common)
- An array of blocks: `[{"type": "text", "text": "..."}, ...]`

Always handle both formats.

### Useful fields

- `message.id` -- unique message ID, shared across split entries
- Project slug is the directory name under `~/.claude/projects/`
- Session ID is the JSONL filename (UUID)

## Extraction Process

### Step 1: Understand the pattern

Before touching any data, get clear on what you're looking for. The user will either:
- Describe a pattern abstractly ("I often spawn multiple agents with different personas")
- Reference something from the current conversation ("codify what we just did")
- Point to a specific behavior ("the thing where I break work into phases for sub-agents")

From this, identify:
- **What the pattern looks like in transcripts** -- keywords in user messages, structural
  signals (e.g., multiple Agent tool calls, specific tool names, recurring phrases)
- **What makes an instance "good"** -- how to distinguish strong executions from weak ones

### Step 2: Search transcripts

Use Python scripts via Bash to search. The data is too large for grep -- you need to
parse JSONL and inspect structured fields.

**Two search strategies, use both:**

1. **Keyword search on user messages**: find messages where the user describes or requests
   the pattern. Cast a wide net with regex alternation, then manually filter false positives.

2. **Structural search on assistant behavior**: find sessions where the assistant exhibits
   the pattern (e.g., sessions with N+ Agent tool calls, specific tool combinations,
   specific agent descriptions).

Start broad, then narrow. Report hit counts to the user before diving deep.

### Step 3: Extract conversation context

For the top sessions (ranked by signal density), extract the full conversation flow
around each pattern instance:
- The user message that triggered it
- The assistant's response (text + tool calls)
- The agent prompts (these encode how the pattern was executed)
- The user's reaction (approval, correction, follow-up)

This is where the real data lives. Agent prompts show exactly how the pattern was
operationalized. User corrections show what went wrong. User approval shows what worked.

### Step 4: Analyze for variants and quality

Across all instances, identify:
- **Modes/variants**: does the pattern have distinct subtypes? (e.g., implementation
  delegation vs QA sweep vs brainstorm panel)
- **What worked**: which instances produced the best outcomes? What did they have in common?
- **What failed**: where did the pattern break down? Why?
- **User friction**: where did the user have to re-explain or correct the approach?
  These are the exact things the skill should eliminate.

### Step 5: Present findings and co-design

Present the analysis to the user:
- How many instances you found and across which projects
- The taxonomy of variants
- The best execution (with specifics -- quote the prompts)
- The friction points the skill should eliminate
- Your proposed skill design

Then iterate with the user on the design. Use AskUserQuestion for key design decisions
that have real trade-offs.

### Step 6: Build the skill

Write the SKILL.md to `~/.claude/skills/<skill-name>/SKILL.md`. If you found an
exceptionally good execution, save it as a reference at `references/<name>.md`.

The skill should encode:
- When to trigger (from the user's natural language patterns)
- The complete methodology (not just "do the thing" but the specific steps, heuristics,
  and anti-patterns discovered from the transcript analysis)
- The decisions that were co-designed with the user
- Anti-patterns learned from failure cases in the history

## Search Script Patterns

Here are tested Python patterns for common searches. Run these via Bash.

### Find sessions by agent call count

```python
import json, glob, os
from collections import defaultdict

projects_dir = os.path.expanduser("~/.claude/projects")
all_files = glob.glob(os.path.join(projects_dir, "**", "*.jsonl"), recursive=True)
main_sessions = [f for f in all_files if "/subagents/" not in f]

for f in main_sessions:
    agent_calls = 0
    with open(f) as fh:
        for line in fh:
            line = line.strip()
            if not line: continue
            try: entry = json.loads(line)
            except: continue
            if entry.get("type") == "assistant":
                msg = entry.get("message", {})
                content = msg.get("content", [])
                if isinstance(content, list):
                    for block in content:
                        if isinstance(block, dict) and block.get("type") == "tool_use" and block.get("name") == "Agent":
                            agent_calls += 1
    if agent_calls >= THRESHOLD:
        print(f"{agent_calls} agents: {f}")
```

### Search user messages by keyword

```python
import json, glob, os, re

pattern = re.compile(r"PATTERN_HERE", re.IGNORECASE)
projects_dir = os.path.expanduser("~/.claude/projects")
all_files = glob.glob(os.path.join(projects_dir, "**", "*.jsonl"), recursive=True)
main_sessions = [f for f in all_files if "/subagents/" not in f]

for f in main_sessions:
    with open(f) as fh:
        for line in fh:
            line = line.strip()
            if not line: continue
            try: entry = json.loads(line)
            except: continue
            if entry.get("type") != "user": continue
            msg = entry.get("message", {})
            content = msg.get("content", "")
            text = ""
            if isinstance(content, str): text = content
            elif isinstance(content, list):
                for block in content:
                    if isinstance(block, dict) and block.get("type") == "text":
                        text += block.get("text", "")
            if text and pattern.search(text):
                project = f.split("/projects/")[1].split("/")[0]
                print(f"[{project}] {text[:300]}")
```

### Group agent calls by message ID (find multi-agent spawns)

```python
import json, glob, os
from collections import defaultdict

projects_dir = os.path.expanduser("~/.claude/projects")
all_files = glob.glob(os.path.join(projects_dir, "**", "*.jsonl"), recursive=True)
main_sessions = [f for f in all_files if "/subagents/" not in f]

for f in main_sessions:
    msg_agents = defaultdict(list)
    with open(f) as fh:
        for line in fh:
            line = line.strip()
            if not line: continue
            try: entry = json.loads(line)
            except: continue
            if entry.get("type") == "assistant":
                msg = entry.get("message", {})
                msg_id = msg.get("id", "")
                content = msg.get("content", [])
                if isinstance(content, list):
                    for block in content:
                        if isinstance(block, dict) and block.get("type") == "tool_use" and block.get("name") == "Agent":
                            msg_agents[msg_id].append(block.get("input", {}))
    for msg_id, agents in msg_agents.items():
        if len(agents) >= 2:
            print(f"[{os.path.basename(f)}] {len(agents)} agents in one message:")
            for a in agents:
                print(f"  {a.get('description', '')}")
```

## What NOT to Do

- **Don't just grep and slap words together.** The value is in analyzing *how* the
  pattern was executed across instances -- variants, quality differences, failure modes.
  A skill built from one example is shallow. A skill built from 20 instances encodes
  real operational knowledge.

- **Don't skip the co-design step.** Present findings and iterate with the user. They
  know which instances were good and which were painful. Your job is to surface the data;
  the user makes the design calls.

- **Don't build the skill before you understand the pattern.** The extraction and analysis
  must come first. If you jump to writing SKILL.md before reading the transcripts, you'll
  produce generic instructions instead of battle-tested methodology.

- **Don't include every variant in the skill.** Some variants are better served as separate
  skills. If the taxonomy reveals genuinely different workflows that share a surface-level
  similarity, propose splitting them.
