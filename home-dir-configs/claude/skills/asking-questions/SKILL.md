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

## One Round Is Rarely Enough

Decomposition isn't a one-shot. After the first answer lands, the design space changes
shape -- some sub-decisions collapse, others that weren't visible before come into
focus. Re-decompose at the new scope and ask the next load-bearing question. The
natural shape of this work is rounds, not a single question.

Within a round, you can ask more than one question -- but only if they're genuinely
orthogonal load-bearing axes at this scope. If question 2's framing would shift based
on question 1's answer, it belongs in the next round.

Stop when the next plausible question wouldn't reshape what you'd draft. Not when you
have "enough information" -- that's always available -- but when the structure has
stopped responding to further questions. If you can still name a question whose answer
would change the design, ask it.

## Worked Example

User: "I'm not sure what the right move is for conversation terminal state transitions
-- help me think through this."

**Decomposition:**

- *Decision:* how the system behaves when a conversation moves into a terminal state
  (archived, closed, expired, abandoned).
- *Sub-decisions:* (a) which states count as terminal? (b) what triggers entry --
  user action, timeout, external signal? (c) what's preserved -- history, attachments,
  metadata? (d) is it reversible? (e) what does the user see -- hidden, greyed, in an
  archive view?
- *Load-bearing:* (d) reversibility. If terminal is truly terminal, preservation can
  be cheap and the UI can hide aggressively. If reversible, preservation must be
  richer, the UI has to afford rediscovery, and triggers become higher-stakes. Every
  other sub-decision reweights based on this one.

**Round 1.** Ask about reversibility. Suppose the user answers "truly terminal."

That answer collapses some sub-decisions and reshapes others. Preservation no longer
needs to support revival. Rediscovery UX evaporates. What's now load-bearing is the
*trigger* (because mistakes are unrecoverable, entry has to be intentional or very
safe) and *visibility* (do users need to see archived conversations at all, or are
they gone-gone?). These are orthogonal -- visibility doesn't shift based on the
trigger answer, and vice versa.

**Round 2.** Ask both, in the same round. Suppose: trigger = user action only;
visibility = archive view available.

Now preservation is back in scope -- the archive view needs *something* to show, so
"what's preserved" is no longer cheap. And the question of *which states count as
terminal* is finally tractable: with an archive view and user-initiated entry, the
distinction between "archived" and "deleted" becomes a meaningful product question.

**Round 3.** Ask about preservation depth and how many terminal states to expose.

*Stopping check:* what's the next plausible question? Icon for the archive button.
Sort order in the archive view. These don't reshape the design -- they're tuning.
Stop, draft.

If the first question had been (a) "what states count as terminal?" instead --
plausible, but lower-leverage -- the user would have answered, and the remaining
sub-decisions would still need to be asked with their trade-offs unchanged. No
compression. That's the test for picking the right axis within a round, and it's the
same test that tells you to keep going across rounds.

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

### Parallel questions that should have been sequenced
Within a round, parallel questions are fine *if* each is load-bearing on a different
axis at the current scope. The failure mode is asking in parallel two questions where
question 2's framing would have shifted based on question 1's answer. Test: would
you have written question 2 the same way regardless of how question 1 was answered?
If no, sequence them across rounds.

### Stopping after the first good answer
The most common failure mode of this skill. You pick the load-bearing question, get a
clean answer, and the temptation is to jump to drafting. But one answer rarely
stabilizes the design -- it usually reveals the *next* load-bearing axis. Apply the
stopping rule honestly: only stop when the next plausible question wouldn't reshape
what you'd draft.

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
