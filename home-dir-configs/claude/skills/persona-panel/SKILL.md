---
name: persona-panel
description: >
  Spawn a panel of agents with distinct personas to review, critique, brainstorm, or debate
  an artifact from multiple perspectives. Use when: the user says "give them personas", "make
  them disagree", "panel of experts", "get multiple perspectives", "chorus of reviewers",
  "brainstorm with personas", "advisory board", or asks for diverse viewpoints on a design
  decision, document, plan, code review, or problem. Also trigger when the user asks you to
  spawn 2+ agents with different roles, lenses, or expertise areas.
---

# Persona Panel

Spawn a panel of agents with constructed personas to analyze an artifact from multiple angles.
Every persona runs in parallel. You synthesize the results into a consolidated report.

## Process

### 1. Identify the artifact and goal

Before constructing personas, be precise about:
- **The artifact**: what exactly are the personas reviewing? A document, a PR diff, a design
  decision, a problem statement, a plan, a naming question? Extract or construct it as a
  self-contained brief that each persona will receive.
- **The goal**: what kind of output does the user want? Bug-finding, design feedback,
  creative options, stress-testing, trade-off analysis?
- **The user's directive**: did they say "make them disagree"? "give them personas"?
  "brainstorm"? The verb shapes persona construction.

### 2. Classify the request

The type of work determines the *axis of differentiation* between personas:

| Type | Differentiation axis | Example |
|------|---------------------|---------|
| **Document/plan review** | What each persona optimizes for | Correctness vs clarity vs feasibility vs politics |
| **Code review/audit** | Correctness dimension | Concurrency, data integrity, API contract, performance, security |
| **Design decision** | Design philosophy | Simplicity vs completeness, pragmatic vs principled, different architectural schools |
| **Brainstorm** | Professional lens | Technical, business, creative, user-facing, domain-specific |
| **Naming/framing** | Audience perspective | Developer, marketer, end-user, technical writer |

### 3. Determine count and depth

**Count** -- infer from scope:
- Focused artifact (single function, short doc, binary choice): 2-3 personas
- Complex artifact (full plan, large PR, multi-faceted problem): 4-5 personas
- The user can always override by specifying a number

**Depth** -- infer from stakes:

**Deep characters** for high-stakes design decisions, architectural debates, or brainstorms
where you need genuinely committed, distinctive viewpoints. These get:
- A fictional name
- A 2-3 sentence backstory establishing their expertise and philosophical position
- A stated principle or prior that will naturally produce tension with other panelists
- Known blind spots or biases (makes their perspective more authentic and useful)

**Professional identities** for reviews, audits, and lower-stakes analysis. These get:
- A title and expertise area
- A "your sole job is to..." statement
- What they should focus on and what they should ignore

The dividing line: if the personas need to *commit to a position* (design debate, brainstorm),
use deep characters. If they need to *find things* (bugs, issues, gaps), use professional
identities.

### 4. Construct personas

For each persona, write a complete agent prompt containing:

1. **Identity block**: who they are, what they care about, what they optimize for
2. **Shared brief**: the artifact being reviewed (identical across all personas)
3. **Scoped mandate**: what specifically this persona should focus on and what to ignore
4. **Output format**: what their report should look like

**Critical for "make them disagree"**: when the user wants productive conflict, give each
persona a *stated prior* -- a principle they believe that is genuinely in tension with
another persona's principle. Not strawman disagreement, but the kind of real trade-off
where smart people legitimately land on different sides.

Example of good tension:
- Persona A believes "correctness is non-negotiable; complexity is the price you pay"
- Persona B believes "simplicity is correctness; complex systems fail in complex ways"

Example of bad tension (strawman):
- Persona A: "testing is important"
- Persona B: "testing is not important"

### 5. Launch all personas in parallel

Spawn all agents simultaneously using `run_in_background: true`. Every persona gets the
full artifact. Do not wait between spawns.

### 6. Synthesize into consolidated report

After all agents return, produce a single consolidated report structured as:

**Where they agree** -- brief, since consensus is less interesting. Note it and move on.

**Where they disagree** -- this is the valuable part. For each point of disagreement:
- State the tension clearly
- Quote or paraphrase each side's position
- If one side is more convincing, say so and say why
- If it's a genuine trade-off, frame it as a decision the user needs to make

**Ranked recommendations** -- your synthesis, informed by all perspectives. Lead with
your recommendation, not a menu. The user hired a panel to help them decide, not to
defer the decision back to them.

Do NOT just concatenate the persona outputs. The synthesis must demonstrate that you
read and weighed every perspective.

## Prompt template

Use this structure for each persona prompt. Adapt the identity block to the depth level.

```
You are [IDENTITY BLOCK].

[SHARED BRIEF -- the artifact, problem statement, or material being reviewed]

Your job is to [SCOPED MANDATE -- what to focus on, what to ignore].

[For "disagree" mode: Your core belief is [STATED PRIOR]. Argue from this position
honestly -- don't soften it to be diplomatic. If you see a genuine flaw in your own
position, note it, but don't abandon the position.]

Report your findings as:
- Top 3 observations (most important first)
- Your overall assessment (1-2 sentences)
- One thing the other reviewers will probably miss that you caught
```

## What NOT to do

- **Don't create yes-men.** If every persona comes back with "looks great!", the personas
  were too similar or too shallow. Real experts have different priors and notice different
  things.

- **Don't summarize prematurely.** Read every persona's full output before synthesizing.
  The best insight is often buried in the persona you least expected it from.

- **Don't create more than 5 personas.** Diminishing returns set in hard. If you think you
  need 6+, you probably need to narrow the artifact or split into two panels.

- **Don't confuse coverage with conflict.** Code auditors covering different correctness
  dimensions (concurrency, storage, API) aren't disagreeing -- they're covering ground.
  That's fine, but it's a different mode than philosophical debate. Don't force fake
  disagreement where orthogonal coverage is what's actually needed.
