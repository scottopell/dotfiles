---
name: asking-questions
description: >
  Methodology for using AskUserQuestion to help the user work through a fuzzy decision
  -- one where they know they're stuck but haven't articulated the structure of the
  choice yet. The job is to decompose the decision into sub-decisions and ask about
  the one with the most downstream leverage. Use when the user says "ask me questions",
  "help me think through this", "use AskUserQuestion", or hands you something like
  "I'm not sure what the right move is for X -- help me figure it out." Also
  referenced by CLAUDE.md for default AskUserQuestion behavior.
---

# Asking Questions Well

You're reaching for this skill because the user has a fuzzy decision on their hands --
they know they're stuck, they don't yet know what the real choices are, and they want
you to help them find the structure. Your job is not to gather their preferences. It
is to **compress uncertainty**: ask the question whose answer collapses the most
downstream ambiguity.

Think of it like 20 questions. With 20 well-chosen questions you can identify any
concept on earth; with 20 lazy ones you can't narrow down a houseplant. The skill is
in picking the axis of maximum leverage, not in asking more.

## Decompose Before You Ask

A fuzzy decision is never one decision. It's a cluster of sub-decisions the user
hasn't separated yet. "Conversation terminal state transitions" hides at least: what
counts as terminal, what triggers the transition, what's preserved across it, what's
visible to the user, whether it's reversible. Five decisions stacked on top of each
other, each with their own trade-offs.

Before drafting any questions, find the structure. The work is to identify:

- **The decision** -- what is the user actually trying to decide?
- **The hidden sub-decisions** -- what smaller choices are bundled inside it?
- **The load-bearing one** -- if exactly one sub-decision were answered, which answer
  would most constrain the others?

The third is the whole game. Not every sub-decision has equal leverage. Some answers
propagate: once you know *what triggers the transition*, half the remaining questions
resolve themselves. Other answers are cosmetic: knowing *what the state is called*
doesn't narrow anything. Ask the load-bearing axis first.

A working test: "If the user answered this question, would the remaining questions
still all need to be asked -- or would some evaporate?" If none evaporate, the
question is low-leverage. Think again.

Subsequent questions should be **conditioned on earlier answers**, not asked in
parallel. If question 2 would have been the same regardless of how question 1 was
answered, you're hedging rather than narrowing.

## Worked Example

User: "I'm not sure what the right move is for conversation terminal state transitions
-- help me think through this."

Decomposition:

- *Decision:* how the system behaves when a conversation moves into a terminal state
  (archived, closed, expired, abandoned).
- *Sub-decisions:* (a) which states count as terminal? (b) what triggers entry --
  user action, timeout, external signal? (c) what's preserved -- history, attachments,
  metadata? (d) is it reversible -- can a terminal conversation be revived? (e) what
  does the user see -- hidden, greyed, in an archive view?
- *Load-bearing:* (d) reversibility. If terminal is truly terminal, preservation can
  be cheap and the UI can hide aggressively. If terminal is reversible, preservation
  must be richer, the UI has to afford rediscovery, and the trigger becomes
  higher-stakes because mistakes are recoverable rather than catastrophic. Every
  other sub-decision reweights based on this one.

First question is about reversibility. The rest are conditioned on the answer.

If the first question had been (a) "what states count as terminal?" -- plausible, but
lower-leverage -- the user would have answered, and the remaining four questions
would need to be asked with their trade-offs unchanged. No compression happened.
That's the test.

## Framing Individual Questions

Decomposition picks the right question. These rules make sure it lands.

### Frame around behavior, not mechanisms
The user decides based on what they want to happen, not how it works internally. If
the mechanism matters, put it in the option description. The question itself is about
outcomes.

Bad: "Should we use NFKC normalization or a diagnostic-only code path?"
Good: "When a patch fails because of invisible character differences, should the
system auto-fix silently or warn and fail?"

### Each option earns its place
Two to three options, each with a concrete reason you'd pick it -- the trade-off, the
constraint, the consequence -- not a restatement of the label. Options must be
meaningfully different. If two options only differ in a detail the user doesn't care
about, collapse them. Mark "Recommended" when you have a justified opinion; don't be
neutral for its own sake.

### Everything the user needs to evaluate goes in the options
Not in the question text. If you find yourself writing a paragraph above the options,
that content belongs *inside* the options as labels, descriptions, or previews. The
question text is for framing; the options are for deciding.

### Use preview fields for concrete artifacts
Layouts, code snippets, config examples -- put them in `preview`. The UI renders them
side-by-side, which makes comparison effortless. Don't describe a layout in prose when
you can show it.

## Anti-Patterns

### Parallel independent questions
The single strongest signal that decomposition didn't happen. If question 2 doesn't
depend on the answer to question 1, you're asking a batch of hedges rather than
narrowing a space. Stop, find the axis with leverage, ask *that* alone.

### "What do you want to do?"
The laziest question. It pushes all the cognitive load to the user without narrowing
anything. If you're asking this, you haven't done the decomposition step.

### Asking for information you could look up
Don't ask "what branch?" when `git branch` answers it. Only ask for things that live
in the user's head.

### Options that are really a slider
"Keep all three / keep two / keep one / keep none" is a volume knob, not a decision.
Reframe as a multiSelect: "Which of these do you actually use?"

### Technical framing when behavior framing would work
Even with a technical user, outcomes produce faster and more confident answers than
implementations. Ask "should it auto-fix or fail?" not "should we use NFKC
normalization?"
