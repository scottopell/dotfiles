---
description: Reflect on Unclarities in conversation
---
## Purpose
From the *current* session’s chat history, think hard and surface the three most impactful misalignments between the user’s intent and Claude’s responses. Output must be exactly **three short paragraphs**, each focused on one distinct topic, aimed at improving future interactions.

## Scope of Evidence
- Use the full conversation in this session only.
- Treat explicit user corrections/steering as the primary signal (e.g., “actually…”, “not that…”, “use X”, “rerun with…”).
- Secondary signals: repeated follow-ups, re-asked questions, fixes to wrong assumptions, command retries, user-provided constraints that Claude ignored.

## Method (do this, in order)
1) **Collect incidents** where the user corrected, constrained, or redirected Claude. Capture: short quote ≤10 words, what Claude did, what was expected.
2) **Cluster** incidents into themes (e.g., requirements capture, command usage, code vs. explanation depth, assumptions, verbosity/format, tool limits).
3) **Rank** themes by impact, then frequency:
   Impact score = (correctness risk + time wasted + rework) on 1–3 scale. Break ties with frequency, then recency.
4) **Draft** exactly one paragraph per top theme (three total). Each paragraph:
   - Start with a **2–4 word topic label** in bold.
   - 2–3 sentences total (≤60 words).
   - Include **one** tiny session quote (≤10 words) to ground the point.
   - End with a **“Next time:”** sentence giving concrete guidance for the user and/or for CLAUDE.md/AGENTS.md steering.
5) **Validate output**: exactly 3 paragraphs, no headers, no bullets, no extras.

## Writing Rules
- Be specific and actionable; avoid platitudes.
- Neutral tone; assign responsibility precisely (user clarity vs. model behavior).
- Prefer guidance that can be turned into a one-line instruction or example prompt tweak.
- Do **not** propose edits or paste changes to CLAUDE.md/commands; only surface advice.
- No meta commentary, disclaimers, or summaries beyond the three paragraphs.

## Fallback Behavior (if few/no explicit corrections)
If <3 themes: infer from friction signals (repeated requests, reformulations, unanswered constraints). Still produce **exactly three** concise paragraphs covering: (1) Requirements capture, (2) Command/tool usage, (3) Output format/verbosity—ground each with the best available evidence from this session.

## Example Paragraph Template (do not print labels in final output)
**<Topic Label>.** Problem statement referencing session (“<short quote>”). Next time: <one sentence with specific user and/or agent guidance>.

## Output Contract (hard)
Print **only** the three paragraphs, separated by a blank line. Nothing before or after.
