---
description: Execute an approved plan step by step, then check doc impact
argument-hint: [plan to execute, if not already in context]
---

Execute the approved plan: $ARGUMENTS

## Process

1. If no plan is in context, check `docs/plans/` for a matching file before
   asking — it may have survived from an earlier session. If none exists, run
   `/plan` first; don't implement an unplanned change.
2. **Check for TDD before starting.** Read `docs/constitution.md`. If it
   specifies TDD (or the user has otherwise asked for it this session),
   invoke the `tdd` skill and follow its red-green-refactor loop for each
   unit of behavior in the plan. If the constitution doesn't mention TDD,
   don't assume it — proceed without forcing the loop.
3. Work through the plan's steps **in order, sequentially, by default** —
   even if some are marked independent in the plan's "Parallelizable steps"
   section. If there are several and the user wants them done concurrently,
   mention the option and dispatch each as a separate subagent via the Agent
   tool (or Workflow tool for many) — but don't do this automatically; shared
   state is easy to get wrong, and silent parallel execution makes the
   verification gate below ambiguous (whose output do you trust on conflict?).
   Pause at each checkpoint and confirm it's actually met (run the
   test/command — don't just assert it). When a checkpoint involves running
   the test suite, delegate to the `test-runner` subagent to keep verbose test
   output out of the main context; treat its pass/fail report as the
   verification.
4. Keep changes surgical: modify only what's necessary, match existing style,
   don't refactor unrelated code (see `CLAUDE.md` principles).
5. If something doesn't match expectations mid-step, stop and report it
   rather than improvising past it silently.
6. **Doc-impact check (end of implementation):** review what changed. If it
   affects `docs/architecture.md`, `docs/tech-stack.md`, or `docs/runbook.md`,
   propose the specific edits as a diff and ask before writing — never update
   docs silently. If the change introduces or removes a technology, propose
   adding/removing the matching `docs/dev-guide.md` section (structural only —
   don't rewrite other sections' content). If a change conflicts with
   `docs/constitution.md` or an existing ADR, surface that as a conflict
   requiring a decision (typically a new superseding ADR), not a routine edit.
7. Once the plan is fully done and verified, update the plan file's
   **Status** to `Done` and the matching spec's **Status** to `Implemented` —
   otherwise they'd read as perpetually pending to anyone looking later.

## Verification gate

Never claim "done", "fixed", "passing", or "working" without having just run
the evidence for it — a test, a build, a lint, a reproduction of the original
issue — and shown the actual output, not a paraphrase of expected output. If
you haven't run it this turn, you don't get to claim it. If verification
isn't possible (no test exists, command unavailable), say so explicitly
instead of asserting success anyway.

## Output style

Use high-signal terse narration: report actions and results, not intentions
("done X", not "I'm going to do X"). Normal grammar, no filler — not
telegraphic/caveman style. This applies only to your conversational narration.
Code, comments, commit messages, and any docs you write stay normal, complete
quality — terseness never degrades an artifact, only the chatter around it.

**Safety exception:** drop the terse style and use normal, complete language
for security warnings, confirming an irreversible action, or explaining a
complex multi-step sequence — these are exactly the moments where a
compressed fragment risks being misread. Resume terse narration once past
them.
