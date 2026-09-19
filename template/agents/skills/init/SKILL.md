---
name: init
description: Bootstrap the ai-harness into a project that doesn't have it yet — creates AGENTS.md (and CLAUDE.md on request), the docs/ scaffold, and offers git hooks. Use when the user says "init harness", "set up AGENTS.md", "initialize this project", or when harness skills are installed globally but the project has no AGENTS.md/docs.
---

# init: bootstrap the harness into a project

You carry your own templates (in this skill's `resources/templates/` folder)
and helper scripts (in `scripts/`) — this works from ANY install: global skill
installs, manual copies, or a harness-init.sh install that skipped the
context files.

**Scripts are black boxes:** run them, read their stdout, don't read their
source. `scripts/append-context-block.sh` handles idempotent marker appending;
`scripts/next-adr-number.sh` computes the next ADR number.

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
   - No existing file → copy `resources/templates/AGENTS.md` to the
     project root.
   - Existing file → append the harness block with the script (never
     hand-edit markers yourself):
     ```sh
     bash <skill-dir>/scripts/append-context-block.sh \
        AGENTS.md <skill-dir>/resources/templates/AGENTS.md
     ```
     Exit message "already-merged" = done, skip silently.
   - Same logic for `CLAUDE.md` (only if Claude Code is one of the
     project's agents, or on explicit request).

4. **Docs scaffold**: create `docs/` entries ONLY for files that don't
   exist, copying from `resources/templates/docs/`. For every file that
   already exists, follow the setup skill's decision tree: keep as-is /
   merge missing sections / replace only on explicit user request with a
   `.bak` backup. Seed ADR number comes from the script:
   ```sh
   NEXT=$(bash <skill-dir>/scripts/next-adr-number.sh docs/adr)
   ```
   Use `$NEXT` as the seed ADR's number.

5. **Then run the `setup` skill** (if installed) to fill placeholders
   via the interview and reconcile the docs list. If `setup` is not
   available, fill what you can from the survey (project name, obvious
   build/test commands) and leave clean `TODO` markers for the rest —
   an honest TODO beats an invented fact.

6. **Report**: created / appended / skipped lists, and the next
   recommended skill (usually `setup`, then `brainstorm` for the first
   real task).

## Rules

- Never delete or rewrite user content. Append-only for context files.
- No file gets written without stating what will happen first.
- Works with zero network access — everything needed ships in
  `resources/`.
