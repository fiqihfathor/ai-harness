---
description: Turn an approved design into a step-by-step implementation plan
argument-hint: [design or feature to plan, if not already in context]
---

Turn the approved design into an implementation plan: $ARGUMENTS

## Process

1. If no design has been approved yet, check `docs/specs/` for a matching
   spec file first — don't assume it's only in conversation context (it may
   have survived from an earlier session). If none exists, run `/brainstorm`
   first; don't plan an unvalidated idea.
2. Break the work into an ordered, dependency-aware list of steps. Each step
   should be small enough to verify independently.
3. For each step, define a **verifiable checkpoint**: how to know it's done
   correctly (a test, a command, an observable behavior) — not just "looks
   right."
4. **Flag independence.** Mark which steps share no state or files with each
   other (true independence: different modules/files, no shared types, no
   ordering requirement) — this is metadata only, not an instruction to
   actually run them concurrently. Be conservative: if there's any doubt
   about shared state, mark it dependent. Most steps in a typical single-repo
   feature are *not* independent even when they look unrelated at a glance.
5. Call out which steps touch `docs/architecture.md`, `docs/tech-stack.md`, or
   `docs/runbook.md` so `/implement`'s doc-impact check has a head start.
6. Present the plan and get explicit approval.
7. **Persist the approved plan.** Write it to `docs/plans/YYYY-MM-DD-<topic>.md`
   (same date/topic slug as the matching spec, so the pair is easy to find),
   so it survives compaction or a new session:

   ```markdown
   # <Topic> — Implementation Plan

   **Date:** YYYY-MM-DD
   **Spec:** `docs/specs/YYYY-MM-DD-<topic>.md`
   **Status:** Approved

   ## Steps

   1. <step> — checkpoint: <how to verify> — independent: yes/no
   2. ...

   ## Parallelizable steps

   <list step numbers marked independent, or "none">. To actually run these
   concurrently, dispatch each as a separate subagent via the Agent tool (or
   the Workflow tool for a larger number of steps) -- this plan only flags
   the opportunity, /implement still executes sequentially by default.
   ```

   Update `docs/specs/YYYY-MM-DD-<topic>.md`'s "Plan" section to link back to
   this file. Like the spec, this is a per-task record (distinct from
   `docs/`'s standing project facts) — its relevance fades once implemented.

## Output

A numbered plan with checkpoints, approved by the user, written to
`docs/plans/`, ready for `/implement`.
