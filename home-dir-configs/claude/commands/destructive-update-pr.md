---
allowed-tools: Bash(gh pr diff:*), Bash(gh pr edit:*)
description: Overwrite PR title/description based ONLY on the code diff - ignores all other sources
---
## The Diff (Your ONLY Input)

```
!`gh pr diff --patch | cat`
```

## Philosophy: The Diff Is The Only Truth

The code diff is your **SOLE INPUT**. Nothing else exists. Nothing else matters.

**YOU MUST IGNORE:**
- Commit messages (they lie, they're rushed, they're outdated)
- Existing PR title/description (it's what we're replacing)
- Issue references (the code is what shipped, not the plan)
- PR comments (opinions, not facts)
- Branch names (often stale or meaningless)

**WHY:** PR descriptions exist to tell reviewers what the code actually does. The only way to know what code does is to read it. Everything else is hearsay.

**DO NOT:**
- Use `git log` or read commit messages
- Use `gh pr view` or read existing PR content
- Reference issues or tickets
- Ask for more context
- Say "Let me analyze" or provide meta-commentary

**YOU MUST:**
1. Analyze the diff above
2. Generate title + description from the diff alone
3. Execute `gh pr edit` immediately

## Title Rules (50-72 chars)
- Imperative mood: "Add X", "Refactor Y", "Move Z"
- Capture the PRIMARY semantic change
- Examples:
  - "Move quota enforcement to analysis client layer"
  - "Replace polling with webhook-based updates"

## Description Format (MAX 500 WORDS)

```markdown
## Summary
[1-2 sentences: what changed at the highest level]

## Changed
- [Semantic change 1 - WHAT changed conceptually, not WHERE]
- [Semantic change 2]
- [3-6 bullets typical, 8 maximum]

## Why
[Optional: 1-2 sentences if motivation is obvious from code structure]
```

## Writing Rules

**FORBIDDEN:**
- File names: "Updated auth.ts"
- Function names: "Modified validateToken"
- Line counts: "+222 lines"
- Vague terms: "improved", "enhanced", "fixed"
- Location refs: "in the API handlers"

**REQUIRED:**
- Technical specifics: "Moved quota enforcement from API to client layer"
- Pattern names: "Added circuit breaker", "Extracted singleton"
- FROM→TO descriptions: "Tokens now validated at gateway instead of per-service"
- Concrete details: "Added tier limits: Anonymous (1), Free (10), Paid (1000)"

## Grouping

**GOOD:** "Standardized error handling across all API endpoints"
- Groups many similar changes into one conceptual bullet

**BAD:** Separate bullets for each null check in each handler
- Too granular, misses the forest for the trees

## Execute

After reading the diff and generating content:

```bash
gh pr edit --title "YOUR_TITLE" --body "YOUR_DESCRIPTION"
```

**START NOW - Execute gh pr edit. No preamble.**
