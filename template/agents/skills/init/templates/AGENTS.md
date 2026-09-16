# <Project Name>

<!-- Filled by the setup skill. Replace placeholders with real project info. -->

## Overview

<one-paragraph: what this project is, who uses it>

## Tech stack

<languages, frameworks, key libraries — see docs/tech-stack.md for the full picture>

## Commands

- Build: `<cmd>`
- Test:  `<cmd>`
- Lint:  `<cmd>`
- Run:   `<cmd>`

## Project docs

- `docs/constitution.md` — non-negotiable principles and rules
- `docs/project-overview.md` — what this project is, scope
- `docs/tech-stack.md` — what it's built with
- `docs/architecture.md` — system structure, diagrams
- `docs/dev-guide.md` — how to write code well in this stack (per technology)
- `docs/runbook.md` — how to operate and recover it
- `docs/adr/` — significant decisions and their rationale

These are the project's standing record. The `brainstorm` skill reads them before
proposing a design; the `implement` and `update-docs` skills keep them current.

`docs/specs/` and `docs/plans/` are a different category: per-task design and
plan records written by the `brainstorm` and `plan` skills, not part of this standing
record. Their relevance fades once implemented — they're an archive, not
something the `update-docs` skill keeps current.

## Harness layout

- `.claude/` — Claude Code extras (hooks, subagents, slash UX)
- `agents/skills/` — portable skills for any agent (Antigravity CLI, Codex, Cursor, OpenCode, etc.)
- `agents/templates/docs/` — doc skeletons used by the `setup` skill (kept next to the portable skills so manual/global installs can reach them)
- `hooks/` — portable git hooks: mechanical enforcement (secret scan, destructive-bash guard, conventional commits, ADR nudge) that runs regardless of which agent is driving
- `docs/` — generated project standing record and per-task specs/plans

## Working principles

These apply to all work in this project, not just a single task.

1. **Think before coding.** Don't make silent assumptions. If something is
   ambiguous, surface it and ask, or state the assumption explicitly and why
   you're making it. Name trade-offs instead of picking one quietly.

2. **Simplicity first.** Write the minimal code that solves what was actually
   asked. No speculative features, no extra abstraction for hypothetical future
   needs. YAGNI.

3. **Surgical changes.** Modify only what's necessary to accomplish the task.
   Match the existing code's style and conventions. Don't refactor unrelated
   code while you're in the area — flag it separately instead.

4. **Goal-driven execution.** Before starting, know what "done" looks like in
   a verifiable way (a test passing, a command succeeding, an observable
   behavior) — not just "looks right." Use that to know when to stop.

## Workflow

Skills to run in order for features/changes:
1. `brainstorm` — explore a new idea or problem into an approved design, persisted to `docs/specs/`
2. `plan` — turn an approved design into a step-by-step implementation plan, persisted to `docs/plans/`
3. `implement` — execute the plan (TDD if `docs/constitution.md` says so), with a doc-impact check at the end
4. `review` — review the current diff for bugs and quality issues

For bugs:
- `diagnose` — structured debugging loop for an existing bug

On demand:
- `update-docs` — reconcile `docs/` with the current codebase on demand
- `setup` — (re-)run the project docs interview
- `new-skill` — add a new skill/command/agent/hook consistent with this harness's conventions

*(Note: On Claude Code, these workflow steps correspond to the `/brainstorm`, `/plan`, `/implement`, `/review`, `/diagnose`, `/update-docs`, `/setup`, and `/new-skill` slash commands).*
