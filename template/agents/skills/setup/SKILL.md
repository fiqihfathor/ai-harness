---
name: setup
description: Interview the user about this project and generate project-specific docs (overview, tech stack, architecture, runbook, constitution, ADR) plus fill AGENTS.md / CLAUDE.md placeholders. Use once when adopting the harness in a project, or to refresh docs later.
---

# Project setup interview

*Claude Code users: this is /setup.*

This skill bootstraps the project's standing documentation. It is project-scoped
and one-shot (run once per project, or rarely to refresh) — distinct from
the `brainstorm` skill, which is task-scoped and run for every feature.

## Process

1. **Locate the templates.** Read each skeleton in `agents/templates/docs/`:
   `constitution.md`, `project-overview.md`, `tech-stack.md`, `architecture.md`,
   `dev-guide.md`, `runbook.md`, `adr/README.md`,
   `adr/0001-record-architecture-decisions.md`.

2. **Interview the user**, one question at a time, covering what each
   template needs:
   - Project name, one-line purpose, primary users, scope / out-of-scope
   - Languages, frameworks, datastores, external services, deployment
   - High-level architecture: main components/containers and how they connect
     (enough to sketch the Mermaid diagrams in `architecture.md`)
   - For each distinct technology/domain actually in use (e.g. an API
     framework, a RAG pipeline, an agent-orchestration framework, a frontend
     framework): conventions, recommended patterns, common commands, and known
     footguns specific to that technology in this project (for `dev-guide.md`).
     If you have relevant domain skills or knowledge available, use them to
     draft accurate guidance; otherwise use WebSearch/documentation lookup
     rather than guessing. One section per technology actually present —
     never add a section for something the project doesn't use.
   - How to run/build/test locally; how to diagnose and recover from common
     failures (for the runbook)
   - Project principles / non-negotiables (for the constitution)
   - **Does this project follow TDD** (write a failing test before
     implementation code)? If yes, record it as an explicit engineering rule
     in `docs/constitution.md` (e.g. "All feature/bugfix work follows TDD —
     see the `tdd` skill for the red-green-refactor loop."). The `implement`
     skill checks this rule and invokes the `tdd` skill when present — if it's not
     recorded, the `implement` skill won't assume TDD.
   - Any decisions already made worth recording as ADRs beyond the seed ADR

   Don't ask about everything in one message — work through it conversationally.
   It's fine to batch closely related, low-stakes questions.

3. **Never fabricate project facts.** If the user doesn't know or skips a
   question, leave that section's `TODO` in place rather than guessing. A
   `TODO` is a correct, honest output; an invented fact is not.

4. **Write the filled docs to the project's `docs/` directory** (create it if
   missing), mirroring the templates' structure:
   - `docs/constitution.md`
   - `docs/project-overview.md`
   - `docs/tech-stack.md`
   - `docs/architecture.md` (with real Mermaid diagrams reflecting what the
     user described)
   - `docs/dev-guide.md` (one section per technology actually in use)
   - `docs/runbook.md`
   - `docs/adr/README.md`
   - `docs/adr/0001-record-architecture-decisions.md`

5. **Fill `AGENTS.md` (and `CLAUDE.md` if present) placeholders** (project name, overview, build/test/lint/run
   commands) based on the interview. Leave the working principles section as-is.

6. **Reconcile the context files with the actual docs layout**: the
   "Project docs" list in AGENTS.md/CLAUDE.md must reference the files
   that exist, by their real names and paths. If the project keeps an
   equivalent under a different name (e.g. `docs/ops.md` instead of
   `docs/runbook.md`), reference the project's name and note the mapping.
   Remove references to doc types the project deliberately doesn't have.
   If the context file was installed via `--merge`, edit only the harness
   block's docs list, never the surrounding user content.

7. **Report back**: what was created, and a short list of remaining `TODO`s the
   user should fill in later (e.g. via the `update-docs` skill or by hand).

## Notes

- Existing docs are the project's source of truth. Read every file in
  `docs/` FIRST. For each file, decide WITH the user (never silently):
  (a) keep as-is — the harness will reference it; (b) merge — add missing
  sections from the template while preserving existing content; or
  (c) replace — only on explicit user request, backing up the original
  to `<name>.bak` first. Never write a docs file that already has
  content without an explicit per-file decision.
- Seed ADR numbering: check `docs/adr/` for existing numbered ADRs and
  use the NEXT available number (e.g. if `0003-…` exists, the seed
  becomes `0004-…`). Never hardcode `0001-` when the directory has ADRs.
- This skill produces the project's first complete doc set; the `brainstorm` and
  `implement` skills keep it current afterward (see "Living docs" — they always ask
  before editing).
