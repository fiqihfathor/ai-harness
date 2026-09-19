---
name: ask-harness
description: Router for the ai-harness skill set. Use when the user is unsure which harness skill to run, asks "what should I use for X", mentions a workflow step vaguely (e.g. "design this", "ship this", "docs are stale"), or at the start of a new task in a harness-equipped project. Maps situations to skills and explains the flow.
---

# ask-harness: pick the right skill

You are the router over this harness's skills. Read the user's situation,
pick the right entry point, and say which skill to run and why — in one or
two sentences, then ask for a go-ahead. Do not start the work yourself.

## The map

```
new idea / vague feature request
        │
        ▼
   brainstorm ──► writes docs/specs/<date>-<slug>.md, self-reviews it,
        │          you confirm the actual file
        ▼
      plan ──────► writes docs/plans/<date>-<slug>.md, step-by-step,
        │          flags parallelizable steps
        ▼
   implement ───► executes plan steps in order; checks docs/constitution.md
        │          first — TDD only if the constitution records it; ends
        │          with a doc-impact check and a verification gate (no
        │          "done" without an evidence run this turn)
        ▼
     review ─────► reviews the current diff for bugs/quality; reports
                   findings by severity before merging anything
```

Off the main line:

- **bug exists, cause unknown** → `diagnose` (reproduce → minimise →
  hypothesise → fix loop). Do not jump to `implement` for bugs.
- **docs drifted from code** → `update-docs` (reconcile docs/ with the
  current codebase). Also the closing step of any `implement` that
  changed documented behavior.
- **project has no AGENTS.md/docs at all** → `init` FIRST. It bootstraps
  AGENTS.md (+CLAUDE.md on request) and the docs/ scaffold from
  self-contained templates, then hands off to `setup`.
- **project has no docs/ yet (AGENTS.md exists)** → `setup` FIRST. It
  interviews the user and generates overview, tech-stack, architecture,
  dev-guide, runbook, constitution, and a seed ADR. Everything else
  assumes these exist.
- **want to extend the harness itself** → `new-skill` (new command,
  skill, subagent, or hook, following harness conventions).
- **constitution says TDD** → `implement` will invoke `tdd`
  automatically; users can also invoke `tdd` directly for out-of-band
  work.
- **task is simple (scope fits 1-2 sentences, one code area, no design
  choice, small blast radius)** → go straight to `implement` with the
  task description — skip `brainstorm`/`plan`. See "Task sizing" in
  AGENTS.md for the full rule. The verification gate still applies.
- **changes are on the diff, pre-merge** → `review` the current diff
  before finishing any feature line.

## Decision rules

1. No approved spec → never `plan`. No approved plan → never `implement`.
   Say what's missing and route to `brainstorm` / `plan` instead.
2. The user's session goal is unclear between two skills → ask one
   question, then route. Do not guess twice.
3. Specs and plans survive in `docs/specs/` and `docs/plans/` across
   sessions — if the user mentions prior work, check those folders
   before routing to `brainstorm` again.
4. On harnesses with slash-command UX, the same flows may exist as commands
   (/brainstorm, /plan, /implement, /review, /diagnose, /update-docs,
   /setup); prefer whichever invocation style the user used.

## Response format

- One line: the skill to run and why.
- If a prerequisite is missing (no spec, no plan, no docs/), one line
  saying what to run first.
- Then wait for a go-ahead.

On harnesses without slash commands, this router corresponds to asking the agent directly;
the slash commands remain available.
