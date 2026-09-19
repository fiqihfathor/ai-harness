---
name: brainstorm
description: Use when exploring intent and design before implementing, checking against existing project docs
---

# Brainstorm design

*On harnesses that expose skills as slash commands, this skill maps to one — invoke it by whatever name your harness uses.*

Help turn this idea into an approved design through dialogue: the user's request/target, if given in the invocation.

## Process

1. **Read project docs first** (if they exist): `docs/constitution.md`,
   `docs/architecture.md`, `docs/tech-stack.md`. These are the project's
   standing record — use them to ground the conversation.
2. **Ask clarifying questions one at a time** — purpose, constraints, success
   criteria. Prefer multiple choice when reasonable.
3. **Propose 2-3 approaches** with trade-offs and a recommendation.
4. **Check for conflicts.** If the direction the user wants conflicts with or
   diverges from `constitution.md`, `architecture.md`, or an existing ADR,
   stop and surface the conflict explicitly — do not quietly proceed or
   quietly ignore the doc. Ask the user how they want to resolve it (adjust
   the design, or knowingly supersede the existing decision).
5. **Present the design** in sections scaled to complexity; get approval after
   each section. **Feedback loop:** after each section, reflect the user's
   reaction back into the design before moving on — if they pushed back on a
   trade-off, the next section must incorporate it, not repeat the same
   assumption. Design approval is a conversation, not a formality.
6. **Architecturally significant decision?** Draft an ADR only when **all
   three** are true — don't draft one just because something touches
   architecture:
   - **Hard to reverse** — changing course later is costly, not a quick edit.
   - **Surprising without context** — someone reading the code later would
     ask "why was it done this way?" without an explanation.
   - **Genuine trade-off** — there were real alternatives, each with real
     downsides; this wasn't the only reasonable option.

   If all three hold, draft a Nygard-format ADR (Title, Status, Context,
   Decision, Consequences) using `docs/adr/README.md`'s conventions and the
   next available number. Show it to the user and ask before writing it to
   `docs/adr/`. If even one criterion is missing, skip the ADR — not every
   architectural touch needs one, and ADR-spam makes the real ones harder to
   find.

7. **Persist the approved design.** Once the user approves, write it to
   `docs/specs/YYYY-MM-DD-<topic>.md` (today's date, a short kebab-case topic
   slug) so it survives compaction or a new session — don't rely on it staying
   in conversation context. Structure:

   ```markdown
   # <Topic>

   **Date:** YYYY-MM-DD
   **Status:** Approved

   ## Problem / goal
   ## Approach chosen
   ## Alternatives considered
   ## Trade-offs / risks
   ## Open questions
   ## Plan
   (added once the plan skill runs: docs/plans/YYYY-MM-DD-<topic>.md)
   ```

   This is a per-task design record, distinct from `docs/` (which holds
   standing facts about the project as a whole — see `AGENTS.md`'s "Project
   docs" section). A spec's relevance fades once implemented; it's an archive,
   not something the `update-docs` skill keeps current. If a decision in it is
   significant enough for a permanent record, that's the ADR, not the spec.

8. **Self-review before handing off.** Read the written spec file fresh and
   check:
   - **Placeholders:** any stray "TBD", unfinished sections, or vague
     requirements left in? Fix them now.
   - **Internal consistency:** does any section contradict another (e.g. the
     approach chosen doesn't match what's in trade-offs)?
   - **Scope:** is this focused enough for one `plan` skill run, or does it
     actually bundle multiple independent pieces that should be separate
     specs?
   - **Ambiguity:** could any requirement be read two different ways? Make it
     explicit rather than leaving it open to interpretation.

   Fix anything found inline — don't just note it and move on.

9. **User reviews the written file.** Don't treat conversational approval and
   "the file is right" as the same thing — they can drift in translation.
   Point the user at the path and ask them to look at the actual file before
   moving to the `plan` skill: *"Spec written to `docs/specs/<file>`. Take a look and
   let me know if anything needs to change before we plan it."* Wait for
   confirmation (or fix and re-show) before proceeding.

## Output

A design the user has approved **and reviewed as a written file**, in
`docs/specs/`, ready to hand to the `plan` skill. If an ADR was warranted, it's either
written (with confirmation) or explicitly deferred.

## Principles

Apply the working principles from the project's context file (`AGENTS.md` or equivalent): think before coding, simplicity
first, surgical changes, goal-driven execution. One question at a time. Don't
invent project facts — if a doc doesn't exist yet, say so and proceed on what
the user tells you directly.
