---
name: serial-sub-agent
description: >
  Orchestrate complex implementation tasks by decomposing them into focused, serial sub-agent
  phases. The parent stays at the strategy/QA layer while sub-agents handle contained implementation
  chunks. Use when: the user says "use sub-agents", "preserve context", "delegate to agents",
  "break this into phases", "serial agents", "use agents to implement", or when you receive a
  multi-phase plan that would consume significant context to implement directly. Also trigger when
  the user asks you to implement a plan and the plan has 3+ distinct steps that touch different
  files or concerns. Also trigger mid-conversation when the user redirects you to use sub-agents
  instead of implementing directly.
---

# Serial Sub-Agent Orchestration

You are an orchestrator. Your job is to decompose work, delegate implementation to sub-agents,
review their output, and maintain the big picture. You do NOT implement directly -- you plan,
delegate, verify, and integrate.

The two goals of this pattern:
1. **Preserve context** -- sub-agents burn their own context on implementation details while
   the parent stays focused on the big picture and cross-cutting concerns.
2. **QA/oversight** -- the parent reviews each phase's output independently, catching mistakes
   a single long-running implementation would bury.

## Core Behavior

When this skill activates, execute the full loop: decompose, delegate all phases serially,
auto-generate and run QA phases, then report. Do not pause between phases to ask the user for
permission to continue. The user wants heads-down execution with a summary at the end.

If you feel the urge to stop and ask "shall I proceed to phase N?" -- don't. Just proceed.
The user will interrupt you if they need to. Pausing between phases wastes the user's time
and defeats the purpose of delegation.

## Phase Decomposition

Look at the work to be done. Sometimes the user hands you a pre-decomposed plan with explicit
phases. Sometimes they describe a goal and you need to decompose it yourself. Read the situation:

- **User provides phases**: respect their breakdown. Map each to a sub-agent task.
- **User provides a goal/plan without phases**: decompose it yourself before starting.
- **Mid-conversation redirect** ("use sub-agents to preserve context"): take whatever you were
  about to do and reframe it as phases for delegation.

Each phase must be:

- **Self-contained**: completable without knowledge of other phases' implementation details
- **Verifiable**: has a concrete "done when" condition you can check
- **Scoped to files**: name the exact files the agent will read and modify
- **Ordered by dependency**: later phases build on earlier phases, never the reverse

Track phases with TaskCreate so the user can see progress. Mark each completed as you go.

Decomposition heuristics:
- One concern per agent (don't mix "refactor X" with "add feature Y")
- If a phase touches more than 5 files, consider splitting it
- Group by blast radius: low-risk mechanical changes first, high-risk logic changes later
- Phases are always serial -- each one completes before the next starts

## Writing Sub-Agent Prompts

The sub-agent has zero context from your conversation. Brief it like a colleague who just
walked into the room.

**Every prompt must include:**
- What to do (the task, stated precisely)
- Which files to read first (absolute paths)
- Which files to modify (absolute paths)
- What NOT to change (guard rails -- especially important for adjacent code)
- The "done when" condition

**Include when relevant:**
- What prior phases changed (so the agent builds on current state, not stale assumptions)
- Test commands to run for self-verification
- Known gotchas, constraints, or conventions from the codebase
- Error messages or context that motivated this phase

A vague prompt produces vague work. "Refactor the config module" is bad. "Extract the
validation logic from config.go lines 45-120 into a new validate() function that returns
(Config, error), update the 3 call sites in cmd/, run `go test ./...`" is good.

## Reviewing Sub-Agent Output

After each agent completes:

1. **Read the modified files** -- don't rely on the agent's self-reported summary
2. **Run verification** if the phase has tests or build steps
3. **Check the "done when" condition**
4. **Mark the task completed** and move to the next phase

If something is wrong:
- Small fix (a few lines): fix it yourself, it's cheaper than a new agent
- Significant issue: spawn a focused follow-up agent explaining what the previous one got
  wrong and what specifically to fix

## Automatic QA Phases

After all implementation phases complete, generate and execute QA phases. These are
verification-only -- they should not modify code unless fixing a bug they discover.

Auto-generate QA phases based on what was built:

- **Build/compile check**: does the project still build? Run the build command.
- **Test suite**: run existing tests. If new code was added without tests, flag it.
- **Cross-cutting consistency**: if multiple phases touched related code, verify they
  agree (e.g., JSON fields written in one place match what's read in another, function
  signatures match their call sites, config keys are consistent).
- **Edge cases**: if the implementation has obvious edge cases (empty input, error paths,
  boundary conditions), verify they're handled.

Skip QA phases that don't apply. If the work was a 2-file refactor with passing tests,
a single "run tests" QA phase suffices. Don't manufacture busywork.

Name QA phases with a letter prefix: QA-1, QA-2, etc.

## Completion

After all implementation and QA phases:

- Produce a summary: what was done, what was verified, any loose ends
- If QA found issues that were fixed, note what they were
- If anything needs manual follow-up (e.g., "you'll need to run the migration"), say so

## What NOT to Do

- **Don't delegate understanding.** If you can't decompose the work, you don't understand it
  well enough. Research first (Explore agents), then decompose, then delegate implementation.

- **Don't over-decompose.** If a task is 3 edits to 1 file, just do it yourself. Sub-agents
  have overhead. The break-even is roughly when a phase would consume 15%+ of your remaining
  context to implement directly.

- **Don't parallelize.** The goal is not speed -- it's preserving the parent's context
  while maintaining oversight. Each phase completes before the next starts.

- **Don't skip review.** The entire value of this pattern is double-checking. Fire-and-forget
  adds overhead without adding quality.

- **Don't lose the thread.** After 3+ completed phases, keep a mental tally of what's changed
  from the original plan. If you're drifting, note it in the completion summary.
