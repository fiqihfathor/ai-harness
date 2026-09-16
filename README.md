# ai-harness

A reusable, markdown-driven **agent development harness**. It configures your
coding agent's existing engine — there's no agent loop to run, just files your
agent loads automatically. Copy the template into any project repo.

**Runs on any agent**: Claude Code, Antigravity CLI (agy), Codex, Cursor,
OpenCode, and anything else that reads the standard agent-skills format
(`SKILL.md`) or `AGENTS.md`.

## What you get

### Core workflow (any agent)

```
brainstorm ──► plan ──► implement ──► review
    │            │           │
 docs/specs/  docs/plans/  verification gate
              (persisted across sessions)
```

- **Karpathy-principled `CLAUDE.md` / `AGENTS.md`** — think before coding,
  simplicity first, surgical changes, goal-driven execution.
- **A disciplined workflow**: `brainstorm` → `plan` → `implement` → `review`,
  plus `diagnose` for existing bugs and `update-docs` for on-demand doc
  reconciliation. `implement` and `review` carry a verification gate — no
  claiming "done" or "no issues" without evidence run that turn.
- **Persistent specs and plans**: `brainstorm` writes the approved design to
  `docs/specs/`, `plan` writes the approved plan to `docs/plans/` — both
  survive compaction or a new session. Specs are per-task records that fade
  once implemented; docs/ is the standing record (see
  [Spec vs. docs](#spec-vs-docs)). `brainstorm` self-reviews the written
  spec (placeholders, contradictions, scope, ambiguity) and asks you to
  confirm the actual file before handing off — not just conversational
  approval.
- **A `setup` interview skill** that generates project-specific docs from
  templates: overview, tech stack, architecture (with Mermaid C4 diagrams),
  dev guide, runbook, constitution, and a seed ADR — and asks whether the
  project follows TDD, recording it in the constitution if so.
- **Constitution-driven TDD**: an opt-in `tdd` skill (red-green-refactor) —
  `implement` checks `docs/constitution.md` and invokes it deterministically
  when TDD is recorded there; never assumed otherwise.
- **An `ask-harness` router**: describes your situation, it names the skill
  to run and any missing prerequisite. Enforced complete by CI.
- **Mechanical enforcement, portable**: `hooks/` ships git-level hooks
  (secret scan, destructive-bash guard, conventional-commit prefix, ADR
  immutability nudge) that run regardless of which agent — or human — is
  driving git.

### Claude Code extras (`.claude/`)

- Slash-command UX: `/brainstorm` `/plan` `/implement` `/review` `/diagnose`
  `/update-docs` `/setup` `/new-skill`.
- Agent-engine hooks: deterministic safety floor (secret-scan,
  destructive-bash guard) firing on every tool call, plus workflow nudges.
- Two subagents: a read-only `code-reviewer`, and a `test-runner` that runs
  the suite and reports concise pass/fail.

## The three layers

| Layer | Path | Runs on | Nature |
|-------|------|---------|--------|
| **Portable skills** | `agents/skills/` + `AGENTS.md` | any agent (agy, Codex, Cursor, OpenCode, Claude Code, …) | workflow logic + principles |
| **Portable git hooks** | `hooks/` | git itself (any agent or human) | mechanical enforcement |
| **Claude Code extras** | `.claude/` | Claude Code only | engine hooks, slash UX, subagents |

The portable layers are a superset of the workflow logic; Claude users get
the same logic with tighter engine-level enforcement and nicer ergonomics.

## Usage

From this repo:

```sh
./harness-init.sh /path/to/your/project
```

Then, inside the project:

```sh
# enable git-level enforcement (any agent)
./hooks/install.sh

# point your agent at the skills (choose one):
#   Antigravity CLI : skills already at agents/skills/ (in-project), or copy
#                     to ~/.gemini/antigravity-cli/skills/ for global
#   Codex / others  : your harness's skills directory, or keep in-repo
#   Claude Code     : nothing to do — .claude/ is picked up automatically
```

## Why a harness, not just skills?

Skill marketplaces give you tools; a harness gives you **coherence**:

- **Spec vs. docs taxonomy** — standing project record (`docs/`) is curated;
  per-task specs/plans are an archive that fades. Agents read the right
  thing at the right time instead of stale specs.
- **Constitution-driven determinism** — whether TDD applies is recorded in
  `docs/constitution.md` once, checked mechanically every `implement`, not
  re-negotiated per session.
- **Verification gates with evidence that turn** — the number one failure
  mode of agent coding is claiming done without running anything. The gate
  requires an evidence run in the current turn.
- **Mechanical + advisory enforcement** — advisory discipline lives in
  skills; non-negotiable rules live in git hooks and engine hooks where
  available. Neither alone is enough.

## Spec vs. docs

`docs/` is the **standing record**: project-overview, tech-stack,
architecture, dev-guide, runbook, constitution, and ADRs. It is maintained
and kept current.

`docs/specs/` and `docs/plans/` are **per-task records**: the design and
plan a task was built from. They are written once, consumed by
`implement`, and then left as an archive — `update-docs` does not keep
them current, and agents should not treat them as facts about the project
after the task lands.

## Hooks

Portable (git-level, any agent — install with `hooks/install.sh`):

| Hook | Trigger | Effect |
|------|---------|--------|
| `secret-scan` | pre-commit | blocks commits containing AWS keys, GitHub tokens, obvious api keys |
| `no-destructive-bash` | pre-commit | blocks additions of `rm -rf /`, fork bombs, `curl \| sh` etc. to scripts |
| `conventional-prefix` | commit-msg | requires `feat:`/`fix:`/`docs:` … commit prefixes |
| `adr-immutability-nudge` | post-checkout | one-line reminder when a change touches `docs/adr/` |

Claude Code engine hooks (`.claude/hooks/`, automatic): secret-scan and
destructive-bash guard on every tool call, edit logging, conditional
format, setup nudge, ADR nudge.

## Extending

Run the `new-skill` skill (Claude Code: `/new-skill`) to add a new
command, skill, agent, or hook following this harness's conventions. CI
validates every `SKILL.md`'s frontmatter and that the `ask-harness` router
mentions every portable skill.
