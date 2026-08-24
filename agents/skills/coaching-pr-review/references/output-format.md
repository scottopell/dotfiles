# Output Format

Render the review as a single markdown document to stdout. Use this exact structure. If a section
has nothing worth saying, write "Nothing to flag." and move on — don't pad.

---

## Template

```
## PR Review: <repo>#<number>
**Author:** <name>  **Base:** <base branch> ← <head branch>  
**Files changed:** <count> | **+<additions>** / **-<deletions>**

---

### What this PR actually does

<2-5 sentences, pseudocode-level. Describe the change in plain algorithmic terms. Focus on the
"what" and "how" — not the "why" from the PR description. If the PR description is misleading or
incomplete vs what the code does, note the discrepancy here.>

---

### Design review

<This is the most important section. Focus on:>
<- Abstraction choices: are the boundaries in the right place?>
<- Naming: does the code say what it means?>
<- Coupling: what is now tangled together that wasn't before?>
<- Complexity budget: is the complexity proportional to the problem?>
<- Patterns: is the author following existing codebase conventions or introducing new ones?>

<Be specific. Reference files and functions by name. Use pseudocode to illustrate concerns.>

---

### Stats / domain concepts in play

<If the PR involves statistical methods, ML concepts, data science patterns, or mathematical
operations, explain them here in ELI5 terms. Use analogies. The goal is to give the reviewer
enough understanding to ask good questions in review.>

<If none are present, write "Nothing to flag." and move on.>

<Format each concept as:>
<**Concept name**: What it is in plain terms. Why it matters in this PR. >
<If the implementation looks off or the parameters seem arbitrary, note that too.>

---

### Operational concerns

<Think about what happens when this code runs in production:>
<- Failure modes: what breaks, and how loudly?>
<- Observability: can you tell what's happening from the outside?>
<- Rollback story: if this goes wrong, how do you undo it?>
<- Resource usage: any new allocations, goroutines, connections that could leak?>
<- Configuration: any magic numbers or implicit assumptions about the environment?>

---

### Correctness & edge cases

<Concrete things that could go wrong:>
<- Boundary conditions>
<- Nil/empty/zero-value handling>
<- Concurrency issues>
<- Error paths that lose information>

<Don't speculate. Only flag things you can point to in the diff.>

---

### Coaching notes

<This section is for the manager's eyes — thinking prompts, not directives to put in the PR.>

<For each note, format as:>

**Signal:** <what you observed in the code>  
**Read:** <what this might indicate about the author's growth, habits, or gaps>  
**Possible action:** <a lightweight suggestion the manager could consider — a question to ask,
a pairing opportunity, a stretch assignment, or just something to watch over time>

<Look for:>
<- Is the author attempting something new for them? (good sign — even if rough)>
<- Are they over-engineering or under-engineering relative to the problem?>
<- Do they think about the reader of their code, or just the compiler?>
<- Is there a pattern across recent PRs? (you won't have history, but you can note if
   this PR's style suggests a pattern worth watching)>
<- Are tests an afterthought or a first-class concern?>

<If nothing stands out, write "Nothing notable this time." — don't manufacture coaching.>
```

---

## Tone guidelines

- Write like a sharp colleague leaving a voice memo, not like a formal report.
- "This function swallows the error from X and returns nil" > "Error handling could be improved."
- "The new `ScoreAggregator` is doing three jobs" > "Consider separating concerns."
- It's fine to be blunt. The reader is an experienced eng manager, not the PR author.
- Keep the total review under ~800 words unless the PR is genuinely large. For small PRs (< 50 lines
  changed), aim for ~300 words.
