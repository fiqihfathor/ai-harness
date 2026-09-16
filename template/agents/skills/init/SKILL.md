---
name: init
description: Bootstrap the ai-harness into a project that doesn't have it yet — creates AGENTS.md (and CLAUDE.md on request), the docs/ scaffold, and offers git hooks. Use when the user says "init harness", "set up AGENTS.md", "initialize this project", or when harness skills are installed globally but the project has no AGENTS.md/docs.
---

# init: bootstrap the harness into a project

You carry your own templates (in this skill's `templates/` folder) — this
works from ANY install: global skill installs, manual copies, or a
harness-init.sh install that skipped the context files.

## Process

1. **Survey the project first.** Check for: existing `AGENTS.md`,
   `CLAUDE.md`, `docs/` content, git repo, README, build files. Existing
   files are the project's source of truth — you are here to ADD, never
   to replace.

2. **Report what you found**, then propose the plan:
   - which files will be created,
   - which existing files will be referenced or left alone,
   - whether git hooks (`hooks/install.sh`, if the repo carries the
     portable hooks) should be enabled.

3. **AGENTS.md**:
   - No existing file → copy `templates/AGENTS.md` to the project root.
   - Existing file → APPEND the harness block wrapped in idempotent
     markers (see below), never overwrite. If a marker block already
     exists, skip ("already initialized").
   - Same logic for `CLAUDE.md` (only if Claude Code is one of the
     project's agents, or on explicit request).

4. **Docs scaffold**: create `docs/` entries ONLY for files that don't
   exist, copying from `templates/docs/`. For every file that already
   exists, follow the setup skill's decision tree: keep as-is / merge
   missing sections / replace only on explicit user request with a
   `.bak` backup. Seed ADR uses the next available number if
   `docs/adr/` already has ADRs.

5. **Then run the `setup` skill** (if installed) to fill placeholders
   via the interview and reconcile the docs list. If `setup` is not
   available, fill what you can from the survey (project name, obvious
   build/test commands) and leave clean `TODO` markers for the rest —
   an honest TODO beats an invented fact.

6. **Report**: created / appended / skipped lists, and the next
   recommended skill (usually `setup`, then `brainstorm` for the first
   real task).

## Idempotent append marker

```
<!-- ai-harness:begin:v1 -->
…harness content (working principles, workflow, docs pointers)…
<!-- ai-harness:end:v1 -->
```

Outside the markers: user content, untouchable. Re-running `init` on a
marked file = no-op.

## Rules

- Never delete or rewrite user content. Append-only for context files.
- No file gets written without stating what will happen first.
- Works with zero network access — everything needed ships in
  `templates/`.
