---
name: prs-for-busy-folks
description: Generate a scannable PR title and description from a code diff for busy reviewers, then apply it via `gh pr edit`. The core rule: describe CONCEPTS (what changed and why), not file lists — busy reviewers already have the file list, they need the semantic summary that answers "what would I want to know before reviewing this?" Use this skill whenever the user wants to write, update, rewrite, or summarize a pull request description, including phrases like "write a PR description", "update the PR body", "summarize this PR", "make a PR title", "draft PR writeup", or asks for a PR writeup on the current branch's open PR. Also trigger proactively when the user is wrapping up work on a branch and mentions they need to update a PR before requesting review.
---

# PRs for Busy Folks

Turn a PR diff into a semantic summary a time-pressed reviewer can scan in 30 seconds and immediately know what they're about to look at.

## Audience and intent

The reader of this PR description is a senior engineer who has ten other tabs open. They don't want a file list — they already have one (it's the diff). They want the answer to: **what changed, and why?**

Every rule in this skill exists to serve that reader. When in doubt, ask yourself: "Does this line help the reader decide how to review, or is it just restating what GitHub is already showing them?"

## Workflow

1. **Get the diff.** If it's not already in context, run `gh pr diff --patch` via Bash. For large PRs the terminal output can be truncated — if you suspect truncation, pipe to a tempfile and read that instead.
2. **Draft title and body** following the rules below.
3. **Apply the update** by running `gh pr edit --title "..." --body "..."` via Bash. Execute it — don't print the command as text and stop.

## Title

- **50-72 characters**, imperative mood ("Add X", "Move Y", "Replace Z").
- Capture the *primary* semantic change — the one thing you'd tell a teammate in a hallway.

Good:
- `Move quota enforcement to analysis client layer`
- `Replace polling with webhook-based updates`
- `Consolidate duplicate pagination into shared hook`

Bad:
- `Updates to auth.ts and related files` (file-level, not semantic)
- `Improvements` (vague — improvements to what?)

## Description structure

Under 500 words. Three sections, the third optional:

### Summary (1-2 sentences)
The one-liner that shows up in PR lists. High-level: what changed, in a sentence.

### Changed (4-6 bullets, 8 max)
Each bullet is a **semantic** change — a concept, not a file. Group aggressively: if three endpoints got the same null check, that's one bullet ("Added null checks to all auth endpoints"), not three.

Target 4-6 bullets. Split a bullet only when the changes are conceptually distinct, not just physically separate. If you find yourself writing eight bullets, ask whether some belong grouped under a higher-level concept.

### Why (optional, 1-2 sentences)
Include only when the motivation isn't obvious from the diff. If a reviewer can infer it from the code, skip it — padding dilutes the important parts.

## The core rule: concepts, not files

A reviewer opening the PR can already see the files. What they can't see is what the author was *trying to do*. That's the description's job.

**Things to avoid** — these waste attention:
- File names ("Updated auth.ts and session.ts") — the diff already has these
- Function names ("Modified validateToken") — too granular, and likely to rot
- Line counts or diff stats ("+222, -240 lines") — meaningless without context
- Vague words ("improved", "enhanced", "better", "fixed") — doesn't tell the reader what to look for or how to judge whether it worked
- Location references ("in the API handlers", "across components") — again, the diff shows this

**Things to include** — these compress the diff into meaning:
- Architectural moves, framed as FROM→TO ("Moved quota enforcement from API handlers to analysis clients")
- Pattern names ("Added circuit breaker", "Extracted singleton", "Consolidated into shared hook")
- Technology swaps ("Switched from JWT to OAuth2")
- Data flow shifts ("Quota now checked before API calls instead of after")
- Specific new capabilities with scannable numbers ("Added tier-based daily limits: Anonymous 1, Free 10, Paid 1000")

The FROM→TO framing is especially powerful for moves and refactors — it tells the reviewer in one line what used to be true, what is true now, and implicitly why the diff is the shape it is.

## Examples

### Architecture change

**Good:** "Moved quota enforcement to analysis clients with automatic refund on failure paths"
- FROM→TO implied, new behavior stated, no file names.

**Bad:** "Updated ClaudeClient and OllamaClient to check quota (+222, +263 lines)"
- Names files, counts lines, doesn't explain what conceptually changed.

### Abstraction removal

**Good:** "Replaced LlmQuotaTracker abstraction with direct enforcement in clients"
- Names what was removed, where the logic went, architectural call is implicit.

**Bad:** "Deleted src/rate_limit/llm_quota.rs (131 lines)"
- A file deletion is a fact, not a summary. Doesn't say what replaced it or why.

### Feature addition

**Good:** "Added tier-based daily limits (Anonymous: 1, Free: 10, Paid: 1000, Admin: 10000)"
- The *capability*, plus specific numbers a reviewer can sanity-check against product intent.

**Bad:** "Added rate limiting configuration in config.rs and applied in rate_limiter.rs"
- Files and plumbing, not the capability.

## Full before/after

**Before (263 words, heavy on file lists):**

```
## Summary
Moved LLM quota enforcement from API handlers to analysis client layer,
eliminated unnecessary abstractions, and fixed critical bugs.

## Changed
- **Moved quota enforcement to analysis clients** - ClaudeClient and
  OllamaClient now check quota before API calls, with automatic refund on
  all failure paths
- **Deleted LlmQuotaTracker abstraction** - Inlined into analysis clients
  for clearer flow (131 lines removed)
- **Added tier-based daily limits** - Anonymous (1), Free (10), Paid
  (1000), Admin (10,000) requests per day
- **Enhanced GenerationContext** - Now carries RequestingPrincipal
- **Fixed integer overflow** - Rate limiter uses saturating_sub()
- **Simplified API handlers** - Removed 240+ lines from nowcast and
  personas endpoints
- **Rewrote quota tests** - All tests use RateLimiter directly (11+ cases)

## Files Changed
**Core changes:** src/analysis/claude.rs (+222), src/analysis/ollama.rs
(+263), src/analysis/context.rs (+111)
**API simplification:** src/api/nowcast.rs (-240), src/api/personas.rs (-224)
**Deleted:** src/rate_limit/llm_quota.rs (131 lines)
```

**After (94 words, conceptual):**

```
## Summary
Quota enforcement moved from API handlers to analysis clients for
deterministic, automatic checking with refund-on-failure guarantees.

## Changed
- Quota now enforced at analysis client layer (before API calls) instead
  of API handler layer (after)
- Eliminated LlmQuotaTracker abstraction — enforcement logic lives
  directly in clients
- Added tier-based daily limits: Anonymous (1), Free (10), Paid (1000),
  Admin (10000)
- Enhanced GenerationContext to carry RequestingPrincipal for quota
  decisions
- Rate limiter now uses saturating arithmetic to prevent integer overflow
- Semantic cache keys now include data_sources for better hit rates

## Why
Enforcement at the consumption point makes quota bypass impossible and
simplifies API handlers.
```

The second version is a third the length and tells the reviewer strictly more about what actually changed.

## Before you apply

Quick self-check:
- Title in imperative mood, 50-72 chars?
- Description under 500 words, 4-6 bullets typical?
- Zero file names, line counts, or vague words like "improved"?
- Every bullet describes a concept a reviewer couldn't trivially read off the diff?
- If the diff looked truncated, did you note "Diff may be incomplete" at the end?

Then run `gh pr edit --title "..." --body "..."` via Bash. Execute it — don't print the command and stop.
