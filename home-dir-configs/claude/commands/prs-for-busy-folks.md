---
allowed-tools: Bash(gh pr diff:*), Bash(gh pr edit:*)
description: Generate scannable PR title/description from code diff for busy reviewers
---
## Context
- Current PR diff (net changes vs base branch): !`gh pr diff`

## Your task
Analyze the above diff and generate a scannable, information-dense PR title and description for busy reviewers.

## Core Philosophy

**Busy reviewers need semantic summaries, not file lists.**

Your job is to translate code diffs into conceptual descriptions that answer: "What changed and why?"

Think: "What would I want to know before reviewing this code?"

## Title Rules (50-72 chars)
- Imperative mood: "Add X", "Refactor Y", "Move Z"
- Capture the PRIMARY semantic change
- Examples:
  - "Move quota enforcement to analysis client layer"
  - "Replace polling with webhook-based updates"
  - "Consolidate duplicate pagination into shared hook"

## Description Rules (MAX 500 WORDS)

### Structure

**Section 1: Summary (1-2 sentences)**
High-level overview of what changed. This is what shows up in PR lists.

**Section 2: Changed (3-7 bullets)**
Each bullet describes a SEMANTIC/CONCEPTUAL change, NOT a file.

**Section 3: Why (optional, 1-2 sentences)**
Only include if the motivation is obvious from code structure. Omit if unclear.

### Writing Rules

**FORBIDDEN patterns:**
- ❌ File names: "Updated auth.ts and session.ts"
- ❌ Function names: "Modified validateToken function"
- ❌ Line counts: "+222, -240 lines"
- ❌ Diff stats: "131 lines removed"
- ❌ Vague terms: "improved", "enhanced", "better", "fixed"
- ❌ Location references: "in the API handlers", "across components"

**REQUIRED patterns:**
- ✅ Technical specifics: "Moved quota enforcement from API layer to client layer"
- ✅ Pattern names: "Added circuit breaker pattern", "Extracted singleton"
- ✅ Technology changes: "Switched from JWT to OAuth2"
- ✅ Architectural decisions: "Consolidated three pagination implementations into usePagination hook"
- ✅ Data flow changes: "Quota now checked before API calls instead of after"
- ✅ FROM→TO descriptions: "Enforcement moved from handlers to clients"

## Detailed Examples

### Example 1: Architecture Change

**Good:** "Moved quota enforcement to analysis clients with automatic refund on failure paths"
- ✅ Describes WHERE it moved FROM→TO
- ✅ Describes WHAT behavior (automatic refund)
- ✅ No file names

**Bad:** "Updated ClaudeClient and OllamaClient to check quota (+222, +263 lines)"
- ❌ Lists files
- ❌ Lists line counts
- ❌ Doesn't explain the conceptual change

### Example 2: Abstraction Removal

**Good:** "Replaced LlmQuotaTracker abstraction with direct enforcement in clients"
- ✅ Describes WHAT was removed
- ✅ Describes WHERE it went
- ✅ Explains the architectural decision

**Bad:** "Deleted src/rate_limit/llm_quota.rs (131 lines)"
- ❌ Just lists a file deletion
- ❌ Doesn't explain why or what replaced it

### Example 3: Feature Addition

**Good:** "Added tier-based daily limits (Anonymous: 1, Free: 10, Paid: 1000, Admin: 10000)"
- ✅ Describes the new capability
- ✅ Includes specific, scannable details
- ✅ No file references

**Bad:** "Added rate limiting configuration in config.rs and applied in rate_limiter.rs"
- ❌ Lists files instead of describing the feature
- ❌ Implementation details instead of capabilities

### Example 4: Algorithm Change

**Good:** "Rate limiter now uses saturating arithmetic to prevent integer overflow"
- ✅ Describes WHAT changed
- ✅ Explains WHY (prevent overflow)
- ✅ Technical and specific

**Bad:** "Fixed bug in rate_limiter.rs"
- ❌ Vague term "fixed bug"
- ❌ File reference
- ❌ Doesn't explain what was wrong or how it's solved

## Full Example Rewrite

### What NOT to write (BAD - 263 words with file lists):
```
## Summary
Moved LLM quota enforcement from API handlers to analysis client layer, eliminated unnecessary abstractions, and fixed critical bugs.

## Changed
- **Moved quota enforcement to analysis clients** - ClaudeClient and OllamaClient now check quota before API calls, with automatic refund on all failure paths
- **Deleted LlmQuotaTracker abstraction** - Inlined into analysis clients for clearer flow (131 lines removed)
- **Added tier-based daily limits** - Anonymous (1), Free (10), Paid (1000), Admin (10,000) requests per day
- **Enhanced GenerationContext** - Now carries RequestingPrincipal for quota checks
- **Fixed integer overflow** - Rate limiter now uses saturating_sub() for safe timestamp calculations
- **Simplified API handlers** - Removed 240+ lines of quota pre-charging from nowcast and personas endpoints
- **Rewrote quota tests** - All tests now use RateLimiter directly with MockStorage (11+ test cases)

## Files Changed
**Core changes:** src/analysis/claude.rs (+222), src/analysis/ollama.rs (+263), src/analysis/context.rs (+111)
**API simplification:** src/api/nowcast.rs (-240), src/api/personas.rs (-224)
**Deleted:** src/rate_limit/llm_quota.rs (131 lines)
```

### What TO write (GOOD - 94 words, no file lists):
```
## Summary
Quota enforcement moved from API handlers to analysis clients for deterministic, automatic checking with refund-on-failure guarantees.

## Changed
- Quota now enforced at analysis client layer (before API calls) instead of API handler layer (after)
- Eliminated LlmQuotaTracker abstraction - enforcement logic lives directly in clients
- Added tier-based daily limits: Anonymous (1), Free (10), Paid (1000), Admin (10000)
- Enhanced GenerationContext to carry RequestingPrincipal for quota decisions
- Rate limiter now uses saturating arithmetic to prevent integer overflow
- Semantic cache keys now include data_sources for better hit rates

## Why
Enforcement at the consumption point makes quota bypass impossible and simplifies API handlers.
```

## Final Checklist
- [ ] Title is 50-72 characters, imperative mood
- [ ] Description is under 500 words
- [ ] NO file names mentioned (unless the file itself is the point)
- [ ] NO line counts or diff stats
- [ ] NO vague terms like "improved" or "enhanced"
- [ ] Bullets describe CONCEPTS not locations
- [ ] Specific technical terms used throughout
- [ ] Each bullet answers "what changed" at the right abstraction level

## Execute

After generating the title and description, update the PR:
```bash
gh pr edit --title "YOUR_TITLE" --body "YOUR_DESCRIPTION"
```
