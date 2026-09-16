# ai-harness

A reusable, markdown-driven Claude Code dev harness. It configures Claude
Code's existing engine — there's no agent loop to run, just files Claude Code
loads automatically. Copy the template into any project repo to get:

- **Karpathy-principled `CLAUDE.md`** — think before coding, simplicity first,
  surgical changes, goal-driven execution.
- **A lightweight workflow**: `/brainstorm` → `/plan` → `/implement` → `/review`,
  plus `/diagnose` for existing bugs and `/update-docs` for on-demand doc
  reconciliation. `/implement` and `/review` carry a verification gate — no
  claiming "done" or "no issues" without evidence run that turn.
- **Persistent specs and plans**: `/brainstorm` writes the approved design to
  `docs/specs/`, `/plan` writes the approved plan to `docs/plans/` — both
  survive compaction or a new session. Different from `docs/` itself: specs
  and plans are per-task records that fade once implemented, not standing
  project facts (see [Spec vs. docs](#spec-vs-docs)). `/brainstorm` self-reviews
  the written spec (placeholders, contradictions, scope, ambiguity) and asks
  you to confirm the actual file before handing off to `/plan` — not just
  your conversational approval.
- **A `/setup` interview skill** that generates project-specific docs from
  templates: overview, tech stack, architecture (with Mermaid C4 diagrams),
  dev guide, runbook, constitution, and a seed ADR — and asks whether the
  project follows TDD, recording it in the constitution if so.
- **An opt-in `tdd` skill** (red-green-refactor) — `/implement` checks
  `docs/constitution.md` and invokes it deterministically when TDD is
  recorded there; never assumed otherwise. (BDD/DDD were considered and
  deliberately left out — see the spec doc for why.)
- **`/plan` flags independent steps** as metadata and points to the
  Agent/Workflow tool for manual parallel dispatch, without building a
  parallel-execution mechanism into the harness — `/implement` still runs
  sequentially by default.
- **A `new-skill` meta-skill** to extend the harness itself (new command,
  skill, subagent, or hook) consistently with its own conventions.
- **Two subagents**: a read-only `code-reviewer`, and a `test-runner` that
  runs the test suite and reports concise pass/fail.
- **Conservative `settings.json` permissions** plus a small set of hooks:
  a deterministic safety floor (secret-scan, destructive-bash guard) and
  workflow nudges (`/setup` reminder, ADR-immutability reminder, conditional
  formatting). See [Hooks](#hooks) below.

This is a per-project template, not a global `~/.claude` setup — it lives
alongside your existing global config and doesn't depend on it.

## Portable skills (any agent)

The harness includes a portable agent skills layer in `agents/skills/` alongside the existing `.claude/` layout. Any agent supporting the standard agent-skills format (`SKILL.md` with YAML frontmatter `name` and `description`) can read and execute these skills — including Antigravity CLI, Codex, Cursor, OpenCode, and others.

The 9 portable skills mirror the full harness workflow and capabilities:

- **Workflow skills (6):** `brainstorm`, `plan`, `implement`, `review`, `diagnose`, `update-docs`
- **Existing skills (3):** `setup`, `tdd`, `new-skill`

### Installation & Usage

- **Antigravity CLI:** Copy skill directories to `~/.gemini/antigravity-cli/skills/` (e.g. copy `template/agents/skills/tdd` to `~/.gemini/antigravity-cli/skills/harness-tdd`) for global use, or use `.agents/skills/` or `agents/skills/` in-project.
- **Codex / Cursor / OpenCode / Other agents:** Point your agent at `agents/skills/` within the project, or copy skills to your agent's global skills directory (such as `~/.agents/skills/`).
- **Claude Code:** Claude Code users still get the richer `.claude/` layer automatically (hooks, subagents, slash commands UX like `/brainstorm`, `/plan`, etc.) in addition to the portable skills and `AGENTS.md`.

## Usage

From this repo:

```sh
./harness-init.sh /path/to/your/project
```

Or from inside the target project:

```sh
/path/to/ai-harness/harness-init.sh
```

Flags:

- `--dry-run` — show what would happen, write nothing.
- `--force` — overwrite existing files (backs up the original to `*.bak` first).

The script never overwrites existing files by default — re-running it on an
already-initialized repo just fills in anything missing.

## After init

Inside the project, in Claude Code:

1. Run `/setup` once to interview you about the project (including whether it
   follows TDD) and generate `docs/project-overview.md`, `docs/tech-stack.md`,
   `docs/architecture.md`, `docs/dev-guide.md`, `docs/runbook.md`,
   `docs/constitution.md`, and `docs/adr/`, and to fill in `CLAUDE.md`'s
   placeholders.
2. For each new piece of work: `/brainstorm` → `/plan` → `/implement` → `/review`.
3. Hit a bug in existing code? Use `/diagnose` — reproduce, hypothesise,
   instrument, fix with a regression test, cleanup.
4. Run `/update-docs` periodically, or whenever you suspect the docs have
   drifted from the codebase.

### `/setup` vs `/brainstorm`

`/setup` is project-scoped and runs once (or rarely, to refresh) — it
documents what the project *is*. `/brainstorm` is task-scoped and runs for
every change — it designs what you're about to *build*, reading the existing
docs first and flagging conflicts along the way. It only drafts an ADR when a
decision is hard to reverse, surprising without context, *and* a genuine
trade-off — all three, not just "touches architecture" — to avoid burying the
load-bearing decisions in ADR-spam.

### Spec vs. docs

`docs/` (overview, tech-stack, architecture, runbook, constitution, dev-guide)
answers "what **is** this project" — a standing record kept current by
`/update-docs` and `/implement`'s doc-impact check. A spec (`docs/specs/`) and
plan (`docs/plans/`) answer "what are we building **this time**, and how" — a
point-in-time record whose relevance fades once implemented; it's an archive,
not something actively kept current. A decision significant enough to matter
permanently gets promoted to an ADR — the spec itself doesn't.

## Living docs

Docs are kept current two ways: `/implement` runs a doc-impact check at the
end of each change, and `/update-docs` reconciles docs with the codebase on
demand. Both always propose a diff and ask before writing — nothing is
updated silently. Conflicts with `docs/constitution.md` or an existing ADR
are surfaced as conflicts requiring an explicit decision, not routine edits.

## Hooks

| Hook | Event | What it does |
|---|---|---|
| `secret-scan.sh` | `PreToolUse` (`Write\|Edit`) | Denies a write that looks like it contains a secret/key/token. Best-effort regex, not a full scanner. |
| `block-dangerous-bash.sh` | `PreToolUse` (`Bash`) | Hard-denies destructive patterns regardless of permission settings: `rm -rf /`/home, fork bombs, disk-level writes — and, deliberately conservative, **all** `git push` (not just force), `git reset --hard`, `git clean -f`, `git branch -D`, `git checkout .`/`git restore .`. |
| `setup-nudge.sh` | `SessionStart` | One-line reminder to run `/setup` if `docs/` doesn't exist yet. Silent once it does. |
| `adr-immutability-nudge.sh` | `PreToolUse` (`Edit`) | Soft reminder when editing an existing `docs/adr/NNNN-*.md` file — ADRs are historical, only the Status line should change. |
| `conditional-format.sh` | `PostToolUse` (`Edit\|Write`) | Runs the project's own formatter (prettier/biome/ruff/gofmt) on the edited file, only if that formatter's config already exists in the repo. |
| `log-edit.sh` | `PostToolUse` (`Edit\|Write`) | Logs edited file paths to `.claude/edits.log`. The original example hook. |

The first two are a deterministic safety floor — they hold regardless of what
the model decides that turn. The rest reinforce the harness's own workflow or
are convenience no-ops when not applicable. All are plain bash, no required
dependencies (`jq` used when present, with a fallback).

## Layout

```
ai-harness/
├── README.md
├── harness-init.sh
└── template/
    ├── CLAUDE.md
    ├── AGENTS.md
    ├── agents/
    │   └── skills/                  # portable skills (brainstorm, plan, implement, review, diagnose, update-docs, setup, tdd, new-skill)
    └── .claude/
        ├── settings.json
        ├── hooks/                  # see Hooks above
        ├── templates/docs/         # doc skeletons (source for /setup)
        ├── commands/                # /brainstorm /plan /implement /review /diagnose /update-docs
        ├── skills/                  # setup, tdd (opt-in), new-skill (meta)
        └── agents/                  # code-reviewer, test-runner
```

## Out of scope

No MCP server config (that belongs in a project's own `.mcp.json`), no global
`~/.claude` integration, no Agent SDK program — this is config only.
