---
allowed-tools: Bash(git diff:*), Bash(git status:*), Bash(git add:*), Bash(git commit:*)
description: Create a semantic commit with all current changes using conceptual descriptions
---

## Context - Current Repository Changes

**All changes that will be committed:**
!`git diff HEAD`

**Untracked files:**
!`git ls-files --others --exclude-standard`

**Current status:**
!`git status --short`

## Your Task

Analyze the above changes and create a complete commit with a semantic, concept-focused commit message.

## Commit Message Philosophy

**Focus on WHAT changed conceptually, not WHERE in the codebase.**

Think: "What would someone reading the git log want to know about this change?"

## Commit Message Rules

### Subject Line (50-72 chars)
- Imperative mood: "Add", "Fix", "Refactor", "Move", "Extract", "Replace"
- Capture the PRIMARY semantic change
- NO file names or paths
- Examples:
  - ✅ "Add circuit breaker pattern to API client"
  - ✅ "Replace polling with webhook-based updates"
  - ❌ "Update auth.ts and session.ts"
  - ❌ "Fix bug in rate_limiter.rs"

### Body (optional, for complex changes)
- Explain WHY if not obvious from the diff
- Describe architectural decisions
- Use bullet points for multiple conceptual changes
- Focus on semantic changes, NOT file changes

### FORBIDDEN in commit messages:
- ❌ File names: "Updated auth.ts"
- ❌ Function names: "Modified validateToken()"
- ❌ Line counts: "+50 -30 lines"
- ❌ Vague terms: "improved", "enhanced", "various fixes"
- ❌ Implementation details: "Added if statement to check..."

### REQUIRED in commit messages:
- ✅ Technical specifics: "Switch from JWT to session cookies"
- ✅ Pattern names: "Extract repository pattern"
- ✅ Behavior changes: "Validation now happens before persistence"
- ✅ FROM→TO descriptions: "Move auth from middleware to service layer"

## Examples

### Good Commit Messages:
```
Add rate limiting with exponential backoff

Implements token bucket algorithm with configurable burst capacity.
Backoff increases from 1s to max 32s on consecutive failures.
```

```
Replace manual SQL queries with query builder pattern
```

```
Extract shared pagination logic into reusable hook

Consolidates three separate pagination implementations that were
duplicating the same cursor-based logic across different components.
```

### Bad Commit Messages:
```
Update files in src/api/ and fix bugs
```

```
Changes to auth.ts, session.ts, and middleware.ts
```

```
Various improvements and fixes
```

## Execution Steps

1. First, analyze the diff to understand the conceptual changes
2. Draft a semantic commit message following the rules above
3. Stage all changes: `git add .`
4. Create the commit with your semantic message
5. Show the resulting commit with `git show --stat HEAD`

## Important Notes

- If there are no changes to commit, inform the user and do not create an empty commit
- If changes include potentially sensitive files (.env, credentials, keys), warn the user before committing
- Focus on the "why" and "what" at a conceptual level, not the "how" at an implementation level

Now analyze the changes and create a semantic commit!