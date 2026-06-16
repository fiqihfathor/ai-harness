# ai-harness — Per-Project Claude Dev Harness Template

**Date:** 2026-06-16
**Status:** Approved (design, revised)

## Summary

A reusable, markdown-driven development harness you drop into any project repo.
It scaffolds: Karpathy-principled instructions (`CLAUDE.md`), a lightweight
superpowers-style workflow (slash commands), a `/setup` interview skill, and a
**project documentation system** (doc templates that the interview fills into the
repo's `docs/`). It configures the existing Claude Code engine — there is **no
agent loop to code**.

The harness lives in this dotfiles directory as a source of truth. A small
`harness-init.sh` script copies the template into a target repo. This is a
**config-based**, **per-project** harness (copy in, not a global `~/.claude`).

## Goals

- One-command scaffolding of a consistent dev harness into any project.
- Karpathy coding-discipline principles baked into `CLAUDE.md`.
- A self-contained, lightweight workflow loop: brainstorm → plan → implement →
  review, plus diagnose for existing bugs.
- A `/setup` interview that generates **project-specific engineering docs**
  (overview, tech stack, architecture, runbook, ADRs) from harness-owned templates.
- Doc templates grounded in real engineering standards (Nygard ADRs, arc42-lite +
  C4 architecture, SRE runbook).
- A deterministic safety floor via hooks (secret-scan, destructive-command
  guard) that holds regardless of model behavior that turn, plus small
  workflow-reinforcing hooks (`/setup` nudge, ADR-immutability reminder,
  conditional formatting).
- A `test-runner` subagent so `/implement`'s checkpoint verification doesn't
  bloat the main context with verbose test output.
- A verification gate in `/implement` and `/review`: no claiming "done" or
  "no issues" without evidence run that turn — borrowed in spirit from
  superpowers' `verification-before-completion`, embedded inline to stay
  self-contained rather than depending on the global skill.
- An opt-in `tdd` skill (red-green-refactor), configured per project via
  `/setup` and recorded in `docs/constitution.md`; `/implement` checks the
  constitution and invokes the skill deterministically rather than hoping it
  auto-triggers — self-contained, doesn't assume a global TDD skill exists.
- Persistent, per-task design records: `/brainstorm` writes the approved
  design to `docs/specs/`, `/plan` writes the approved plan to `docs/plans/`
  — both survive context compaction or a new session, without depending on
  superpowers' spec/plan file convention being available globally.
- `/plan` flags independent steps as metadata and points to the
  Agent/Workflow tool for manual parallel dispatch — without building a
  parallel-execution mechanism into the harness itself, since real
  concurrent code changes carry a correctness risk (shared-state/file races)
  that the platform's existing tools handle better than a markdown plan can.
- A `new-skill` meta-skill for extending the harness itself (new command,
  skill, subagent, or hook) consistent with its established conventions.
- Small but meaningful. Self-contained: it does not depend on any globally
  installed plugins/skills.

## Non-Goals

- No agent loop / Python or TypeScript program (config only).
- No global `~/.claude` stow/symlink integration.
- No MCP server config (belongs in `.mcp.json`; easy to add per project later).
- No symlink deployment (copy only, so projects diverge and commit normally).
- Not a maximalist framework (no hundreds of skills/agents). Lean by design.

## Architecture

Source-of-truth `template/` + a copy script. Claude Code is the engine; our
files configure it. Doc skeletons are **harness-owned templates** stored under
`.claude/templates/docs/`; the `/setup` interview reads them and writes
**filled-in docs** to the repo's top-level `docs/`.

```
ai-harness/
├── README.md                         # what it is + usage
├── harness-init.sh                   # copies template/ into a target repo
└── template/
    ├── CLAUDE.md                     # Karpathy principles + pointer to docs/
    └── .claude/
        ├── settings.json             # permissions + hooks (see Component: hooks)
        ├── templates/
        │   └── docs/                 # harness-owned doc skeletons (source)
        │       ├── constitution.md
        │       ├── project-overview.md
        │       ├── tech-stack.md
        │       ├── architecture.md   # arc42-lite + C4
        │       ├── dev-guide.md      # per-stack coding conventions, sectioned
        │       ├── runbook.md        # SRE runbook
        │       └── adr/
        │           ├── README.md
        │           └── 0001-record-architecture-decisions.md
        ├── commands/                 # lightweight superpowers-style workflow
        │   ├── brainstorm.md         # explore intent → design; persists docs/specs/
        │   ├── plan.md               # design → step-by-step plan; persists docs/plans/
        │   ├── implement.md          # execute plan; TDD check; ends with doc-impact check
        │   ├── review.md             # review the current diff
        │   ├── update-docs.md        # reconcile docs/ with the codebase on demand
        │   └── diagnose.md           # structured debugging loop for an existing bug
        ├── skills/
        │   ├── setup/
        │   │   └── SKILL.md          # /setup: interview → fill docs/ + CLAUDE.md
        │   ├── tdd/
        │   │   └── SKILL.md          # red-green-refactor loop, invoked by /implement
        │   └── new-skill/
        │       └── SKILL.md          # helps add a new command/skill/agent/hook consistently
        ├── hooks/
        │   ├── log-edit.sh                  # PostToolUse: logs edited paths
        │   ├── secret-scan.sh               # PreToolUse: blocks writing secrets
        │   ├── block-dangerous-bash.sh       # PreToolUse: blocks destructive commands
        │   ├── setup-nudge.sh                # SessionStart: nudge to run /setup
        │   ├── adr-immutability-nudge.sh     # PreToolUse: reminder on editing an ADR
        │   └── conditional-format.sh         # PostToolUse: formats if a formatter is configured
        └── agents/
            ├── code-reviewer.md      # read-only reviewer subagent
            └── test-runner.md        # runs tests, reports concise pass/fail
```

**Data flow:**

1. `harness-init.sh /path/to/project` copies `CLAUDE.md` and `.claude/` into the
   project. It does **not** create `docs/` — that is generated by `/setup`.
2. When Claude Code starts in the project, it auto-loads `CLAUDE.md`,
   `.claude/settings.json`, `.claude/commands/*`, `.claude/skills/*/SKILL.md`,
   and `.claude/agents/*`. The `templates/docs/` files are data, not auto-loaded
   config.
3. Running `/setup` interviews the user, then reads `.claude/templates/docs/*`
   and writes filled-in docs to the repo's `docs/` (creating it if missing), and
   fills the placeholders in `CLAUDE.md`.

## Component: `harness-init.sh`

Usage:

```
./harness-init.sh [TARGET_DIR]      # TARGET_DIR defaults to current directory
```

Behavior:

1. Resolve `TARGET_DIR` (default `.`); error if it does not exist.
2. Resolve the template path relative to the script's own location, so it works
   regardless of the caller's working directory.
3. For each payload file: if it already exists in the target, **skip and warn**
   (never clobber). Otherwise copy it.
4. Print a summary of created vs. skipped files.
5. Exit non-zero on a fatal condition (e.g. bad target dir).

Flags:

- `--force` — overwrite existing files; writes a `.bak` copy first.
- `--dry-run` — print actions, change nothing.
- `-h` / `--help` — usage.

Implementation notes: pure bash, `set -euo pipefail`, no external dependencies.
Copy (not symlink). Non-destructive by default. Copies `CLAUDE.md` and the whole
`.claude/` tree (including `templates/docs/`); does not touch `docs/`.

## Component: `template/CLAUDE.md`

Carries the Karpathy coding-discipline principles inline, plus a project-context
section and a pointer to the docs. Structure:

- **Working principles** (Karpathy-inspired):
  1. *Think before coding* — surface assumptions, confusion, and trade-offs;
     don't guess silently.
  2. *Simplicity first* — minimal code that solves only what was asked; no
     speculative features.
  3. *Surgical changes* — modify only what's necessary; match existing style;
     don't refactor unrelated code.
  4. *Goal-driven execution* — define verifiable success criteria and loop until met.
- **Project context** — short placeholders (name, overview, commands) that
  `/setup` fills, plus a "Project docs" section linking to `docs/constitution.md`,
  `docs/project-overview.md`, `docs/tech-stack.md`, `docs/architecture.md`,
  `docs/dev-guide.md`, `docs/runbook.md`, and `docs/adr/`.

## Component: workflow commands (`.claude/commands/`)

A lightweight, self-contained superpowers-style loop. Each is a slash command
(frontmatter `description` + prompt body):

- **`/brainstorm`** — explore intent, constraints, and success criteria; propose
  2–3 approaches; converge on a design. Output: a short design summary.
  **Doc-aware:** reads `docs/constitution.md`, `docs/architecture.md`, and
  `docs/tech-stack.md` first; if the proposed design conflicts with or diverges
  from them, surfaces the conflict and asks the user before proceeding.
  **ADR criteria (all three required, not just "touches architecture"):**
  hard to reverse, surprising without context, and a genuine trade-off (real
  alternatives existed, each with real downsides). Only when all three hold
  does it draft a Nygard ADR in `docs/adr/` (proposed for confirmation, not
  written silently) — this avoids ADR-spam burying the load-bearing decisions.
  **Persists the approved design** to `docs/specs/YYYY-MM-DD-<topic>.md` (see
  Component: `docs/specs/` and `docs/plans/`) so it survives compaction or a
  new session. **Self-review before handoff:** rereads the written file for
  stray placeholders, internal contradictions, scope creep (should this be
  more than one spec?), and ambiguity — fixes inline, doesn't just flag.
  **Separate file-review gate:** conversational approval and "the file is
  right" aren't treated as the same thing; asks the user to look at the
  actual written file and confirm before handing off to `/plan`. (Both
  adapted from superpowers' `brainstorming` skill, where they exist as an
  explicit spec self-review checklist and a user-review-the-file gate;
  deliberately *not* adopted from the same skill: auto-committing the spec
  to git, which would conflict with this harness's established
  ask-before-committing norm, and the hard-gate/anti-rationalization framing,
  which would push this command toward superpowers' heavier ceremony rather
  than staying lean.)
- **`/plan`** — turn an approved design into an ordered, dependency-aware,
  step-by-step implementation plan with verifiable checkpoints. Checks
  `docs/specs/` for a matching file if no design is in context, rather than
  assuming `/brainstorm` ran in the same session. **Flags independence**: marks
  which steps share no state/files with each other as metadata only (not an
  instruction to run them concurrently — conservative by default, since most
  steps in a typical single-repo feature aren't truly independent even when
  they look unrelated). Includes a "Parallelizable steps" section pointing to
  the Agent tool (or Workflow tool for many steps) for manual dispatch if the
  user wants to act on it — deliberately a pointer, not a built dispatch
  mechanism: real concurrent execution risks shared-state/file races that a
  markdown plan can't safely resolve on its own, and the platform (Agent SDK's
  `Agent`/`Workflow` tools) and global skills (`dispatching-parallel-agents`,
  `subagent-driven-development`) already do this better than reimplementing it
  here would. **Persists the approved plan** to `docs/plans/YYYY-MM-DD-<topic>.md`,
  linked back from the spec.
- **`/implement`** — checks `docs/plans/` for a matching file if none is in
  context. Executes steps **in order, sequentially, by default** even if some
  are flagged independent — only dispatches in parallel via the Agent/Workflow
  tool if the user explicitly opts in, never automatically (silent parallel
  execution would make the verification gate below ambiguous: whose output do
  you trust on conflict?). **TDD check:** reads `docs/constitution.md`; if it
  specifies TDD, invokes the `tdd` skill and follows its red-green-refactor
  loop per unit of
  behavior — doesn't assume TDD if the constitution doesn't mention it.
  Executes the plan step by step, pausing at checkpoints; keeps changes
  surgical (ties back to CLAUDE.md principles). When a checkpoint involves
  running the test suite, delegates to the `test-runner` subagent so verbose
  test output doesn't bloat the main context. On completion, updates the
  plan's and spec's **Status** fields (`Done`/`Implemented`) so they don't
  read as perpetually pending. **Ends with a doc-impact
  check:** determines whether the change affects `architecture.md`,
  `tech-stack.md`, or `runbook.md`, and proposes targeted doc updates (always
  asking before writing — see Living docs). If a technology was added or
  removed, also proposes adding/removing the matching `dev-guide.md` section
  (structural only — existing sections' content is not rewritten here).
  **Terse output (embedded):** uses high-signal terse narration (see Output
  style), with a **safety exception**: reverts to normal, complete language
  for security warnings, confirming an irreversible action, or explaining a
  complex multi-step sequence — moments where a compressed fragment risks
  being misread. **Verification gate:** never claims "done"/"fixed"/"passing"
  without having just run the evidence for it and shown the actual output
  that turn — if verification isn't possible, says so rather than asserting
  success. (Equivalent in spirit to superpowers' `verification-before-completion`
  skill, embedded inline rather than as a separate skill.)
- **`/review`** — review the current `git diff HEAD` for correctness bugs,
  security issues, and simplifications; cite file:line; concise. **Terse output
  (embedded):** high-signal terse (see Output style), with the same **safety
  exception** for security findings — those are written out in full, normal
  language, not compressed. **Verification gate:** doesn't claim "no issues
  found" without having traced through the diff, and doesn't claim a proposed
  fix is correct without verifying it or explaining why it's confident without
  running it.
- **`/diagnose`** — structured six-phase debugging loop for an existing bug:
  (1) build a fast, deterministic feedback loop first: failing test, repro
  script, or similar; (2) reproduce and capture the exact symptom; (3)
  hypothesise 3–5 ranked, falsifiable explanations before changing code; (4)
  instrument — one variable at a time, breakpoints preferred over scattered
  logs; (5) fix with a regression test written before the fix; (6) cleanup
  (remove instrumentation) + a short postmortem, flagging doc gaps for
  `/update-docs` or a new ADR rather than letting them go unrecorded. Added
  deliberately to keep the harness self-contained (consistent with
  `/brainstorm`/`/plan` existing despite global equivalents) rather than
  relying on a global debugging skill that may not be present everywhere this
  template is used.
- **`/update-docs`** — on-demand reconciliation: compares `docs/` against the
  current codebase (recent diffs, structure, dependencies), then proposes
  targeted edits to bring docs back in sync. For `dev-guide.md`, the check is
  **structural only**: add/remove a section if `tech-stack.md` gained or lost
  a technology, but never silently re-research or rewrite existing section
  content — a deeper content refresh is a separate, explicit request (e.g.
  "refresh the RAG section of dev-guide.md"). Always proposes a diff and asks
  before writing.

## Component: `/setup` interview skill (`.claude/skills/setup/SKILL.md`)

A model-invoked skill (also callable as `/setup`) that:

1. Interviews the user about the project (purpose, audience, tech stack,
   architecture at a high level, run/operate steps, key decisions, principles,
   whether the project follows TDD, and — per technology actually in use —
   conventions/patterns/commands/footguns for `dev-guide.md`). If TDD is
   wanted, records it as an explicit engineering rule in `docs/constitution.md`
   (e.g. "All feature/bugfix work follows TDD — see the `tdd` skill"); if not
   answered, no TDD rule is recorded and `/implement` won't assume it.
2. Reads the skeletons in `.claude/templates/docs/`.
3. Writes filled-in docs to the repo's `docs/` (creating it if missing), using
   the user's answers. For `dev-guide.md`, uses available domain knowledge or
   WebSearch/documentation lookup to draft accurate per-technology guidance
   rather than guessing, sectioned only for technologies actually present.
   Leaves clearly-marked TODOs where input is missing rather than inventing
   facts.
4. Fills the placeholders in `CLAUDE.md` (project name, overview, commands).
5. Reports what it created and what still needs human input.

Principle: never fabricate project facts; ask or leave a TODO.

## Component: `tdd` skill (`.claude/skills/tdd/SKILL.md`)

Red-green-refactor loop, opt-in per project. Not invoked by description-match
alone — `/implement` explicitly checks `docs/constitution.md` and invokes it
deterministically when TDD is recorded there, the same composition pattern
used for the `test-runner` subagent delegation. Content: write a failing test
before implementation code, write the minimum to pass it, refactor only with
tests green, repeat per small unit of behavior — kept to the core loop rather
than mattpocock's deeper reference material (mocking strategy, interface
design, refactoring heuristics), to stay lean. Being a skill rather than text
embedded in `/implement` means its content is lazy-loaded — projects that
don't use TDD never pay its context cost.

**Why not BDD too:** considered and deliberately rejected. BDD formal tooling
(Gherkin/Cucumber-style Given-When-Then) is far less universal in practice
than TDD, and its core value — defining acceptance criteria before
implementation — is already covered informally by `CLAUDE.md`'s "goal-driven
execution" principle and `/plan`'s per-step verifiable checkpoints. Adding a
second methodology toggle for it would be over-engineering relative to actual
need. DDD was also considered and rejected as a *skill* for the same reason
it doesn't compete with TDD: it's a modeling discipline (ubiquitous language,
bounded contexts), not a test-first loop — it belongs in `constitution.md`/
`dev-guide.md` content and `/brainstorm`'s judgment, not a parallel skill.

## Component: `new-skill` skill (`.claude/skills/new-skill/SKILL.md`)

A meta-skill for extending the harness itself: adding a new command, skill,
subagent, or hook. Distinct from generic skill-authoring skills (Claude
Code's own docs, or `superpowers:writing-skills` if installed) by adding
harness-specific value: a decision table for picking the right artifact type
(command vs. skill vs. subagent vs. hook, matched to what actually
distinguishes them — determinism, lazy-loading, context isolation, or
unconditional enforcement), and reminders to apply this harness's established
conventions where relevant (verification gate, terse-narration +
safety-exception, doc-awareness with ask-before-write, read-only tool
restriction for analysis subagents, the hook stdin-JSON contract). Ends with
the same "verify before claiming done" discipline as the rest of the harness.

## Component: `docs/specs/` and `docs/plans/`

Per-task design/plan records, persisted by `/brainstorm` and `/plan` so they
survive context compaction or a new session — distinct from `docs/`'s
standing, continuously-current project facts (see "Spec vs. docs" below).
Not generated from a `.claude/templates/docs/` skeleton like the other docs;
their structure is described inline in the `brainstorm.md`/`plan.md` command
prompts and generated fresh per task (paired by a shared `YYYY-MM-DD-<topic>`
filename).

- **`docs/specs/YYYY-MM-DD-<topic>.md`** — Date, Status (Approved →
  Implemented), Problem/goal, Approach chosen, Alternatives considered,
  Trade-offs/risks, Open questions, and a link to the matching plan once one
  exists.
- **`docs/plans/YYYY-MM-DD-<topic>.md`** — Date, link to the matching spec,
  Status (Approved → Done), numbered steps each with a verifiable checkpoint.

**Spec vs. docs:** `docs/` (project-overview, tech-stack, architecture,
runbook, constitution, dev-guide) answers "what **is** this project" — a
standing record kept current by `/update-docs` and `/implement`'s doc-impact
check. A spec/plan answers "what are we building **this time**, and how" — a
point-in-time record whose relevance fades once implemented; it's an archive,
not something actively kept current. If a decision inside a spec is
significant enough to matter permanently, that's promoted to an ADR (which
*is* part of the standing record) — the spec itself isn't.

## Component: doc templates (`.claude/templates/docs/`)

Grounded in researched standards. Each is a skeleton with guidance comments.

- **`constitution.md`** — project principles / non-negotiables (e.g. quality
  bars, security rules, "always do / never do"). Referenced by CLAUDE.md. The
  Engineering rules section's example includes an opt-in TDD line that
  `/setup` fills in if the project wants it, and `/implement` checks before
  invoking the `tdd` skill.
- **`project-overview.md`** — what the project is, the problem it solves, who
  uses it, scope and non-scope.
- **`tech-stack.md`** — languages, frameworks, key libraries, datastores,
  external services, and why each was chosen.
- **`architecture.md`** — condensed arc42 + C4, with **Mermaid diagrams**:
  a System Context diagram (C4 L1) and a Container diagram (C4 L2) as Mermaid
  `flowchart`/`graph` skeletons (portable, GitHub-rendered; not the experimental
  `C4Context` syntax), an optional Component diagram (C4 L3) for parts that
  warrant it, important runtime/data flows, and a cross-cutting concerns /
  constraints section. Not the full 12-section arc42.
- **`dev-guide.md`** — how to write code well in *this* project's actual
  stack: one section per technology/domain actually present (e.g. API
  framework, RAG pipeline, orchestration framework), each with conventions,
  recommended patterns, a commands cheat-sheet, and known footguns. Distinct
  from `tech-stack.md` (what's installed — descriptive) and from
  `constitution.md` (non-negotiable rules — normative): this is advisory,
  technology-specific guidance. Generated once by `/setup`, using available
  domain knowledge or WebSearch/documentation lookup rather than guessing.
  Deliberately **not** bundled domain skills (e.g. `fastapi-expert`,
  `rag-architect`): the goal is the one-time *output* such expertise would
  produce, captured as a project artifact that needs nothing installed to be
  useful later — not the reusable capability itself, which would duplicate
  skills the user already has globally and drift out of sync.
- **`runbook.md`** — SRE shape: service summary & owner, triggers/symptoms,
  diagnostics with commands, dashboard/log links, escalation contacts, recovery
  steps, and a post-recovery verification checklist.
- **`adr/README.md`** — what ADRs are and how to add one (one decision per file,
  numbered `NNNN-title.md`, Nygard format).
- **`adr/0001-record-architecture-decisions.md`** — seed ADR (Nygard:
  Title · Status · Context · Decision · Consequences) recording the decision to
  use ADRs.

## Component: `template/.claude/agents/`

Two subagents. Verified frontmatter fields: `name`, `description`, `tools`
(comma-separated), `model`.

- **`code-reviewer.md`** — read-only (`Read`, `Grep`, `Glob`). Reviews for
  quality, security, maintainability against the project's own conventions
  (`CLAUDE.md`, `docs/constitution.md` if present). Never edits files.
- **`test-runner.md`** — `Bash`, `Read`, `Grep`. Finds and runs the project's
  test command, reports a concise pass/fail summary (counts, failing test +
  error + likely cause). Used by `/implement` to keep verbose test output out
  of the main conversation when verifying a checkpoint.

```markdown
---
name: code-reviewer
description: Read-only code review for quality, security, maintainability. Use after changes.
tools: Read, Grep, Glob
model: sonnet
---
You are a code review specialist... (concise review instructions)
```

## Component: `template/.claude/settings.json`

Conservative permissions plus the full hook set (below). Verified against
current settings docs: `permissions` holds `allow`/`deny`/`ask` arrays with
priority `deny > allow > ask`; `hooks` is keyed by event → matcher → handler.

```jsonc
{
  "permissions": {
    "allow": [
      "Read", "Grep", "Glob",
      "Bash(git status)", "Bash(git diff:*)", "Bash(git log:*)"
    ],
    "ask": [
      "Bash(rm:*)"
    ],
    "deny": [
      "Read(./.env)", "Read(./.env.*)", "Read(./**/*secret*)"
    ]
  },
  "hooks": {
    "SessionStart": [
      { "matcher": "startup|resume", "hooks": [
        { "type": "command", "command": "${CLAUDE_PROJECT_DIR}/.claude/hooks/setup-nudge.sh" }
      ]}
    ],
    "PreToolUse": [
      { "matcher": "Write|Edit", "hooks": [
        { "type": "command", "command": "${CLAUDE_PROJECT_DIR}/.claude/hooks/secret-scan.sh" }
      ]},
      { "matcher": "Bash", "hooks": [
        { "type": "command", "command": "${CLAUDE_PROJECT_DIR}/.claude/hooks/block-dangerous-bash.sh" }
      ]},
      { "matcher": "Edit", "hooks": [
        { "type": "command", "command": "${CLAUDE_PROJECT_DIR}/.claude/hooks/adr-immutability-nudge.sh" }
      ]}
    ],
    "PostToolUse": [
      { "matcher": "Edit|Write", "hooks": [
        { "type": "command", "command": "${CLAUDE_PROJECT_DIR}/.claude/hooks/log-edit.sh" },
        { "type": "command", "command": "${CLAUDE_PROJECT_DIR}/.claude/hooks/conditional-format.sh" }
      ]}
    ]
  }
}
```

## Component: `template/.claude/hooks/`

Hook contract (verified against current docs): hooks receive a JSON payload on
**stdin** (e.g. `tool_input.file_path`, `tool_input.command`); `PreToolUse`
blocks a tool call via `{"hookSpecificOutput":{"hookEventName":"PreToolUse",
"permissionDecision":"deny","permissionDecisionReason":"..."}}` printed to
stdout with exit 0; `PostToolUse` cannot block (the tool already ran) but can
add `additionalContext`; `SessionStart` can inject `additionalContext` at
session start. `${CLAUDE_PROJECT_DIR}` is available as an env var; the edited
file path is not. All scripts: pure bash, `jq` when available with a grep
fallback so there's no hard dependency, never crash the hook chain (`|| true`
where a sub-command might fail), and stay silent (no output) when there's
nothing to report — only `secret-scan.sh` and `block-dangerous-bash.sh` ever
deny.

- **`log-edit.sh`** (`PostToolUse`, `Edit|Write`) — appends edited file paths
  to `.claude/edits.log`. The original illustrative example.
- **`secret-scan.sh`** (`PreToolUse`, `Write|Edit`) — best-effort regex check
  (AWS keys, GitHub/Slack tokens, private-key headers, JWTs, generic
  `api_key=`-style assignments) over the raw stdin payload; denies the write if
  matched. Not a replacement for a real scanner (e.g. `gitleaks`) — swap one in
  for stronger coverage. Complements the existing `deny: Read(./.env)` rule,
  which stops reading secrets but not writing new ones.
- **`block-dangerous-bash.sh`** (`PreToolUse`, `Bash`) — hard-denies a short,
  best-effort list of destructive patterns regardless of permission settings.
  **System-level:** recursive force-delete of `/`/home, fork bombs, disk-level
  `dd`/`mkfs` writes, world-writable `chmod -R 777 /`. **Git (deliberately
  conservative):** *all* `git push` (not just force-push — pushing is hard to
  undo and affects others, so it's blocked outright rather than gated by
  `ask`; run it yourself outside Claude Code), `git reset --hard`, `git clean
  -f`/`-fd`, `git branch -D`, `git checkout .`/`git restore .` (all of which
  destroy local/uncommitted work or history). Because git push is fully
  blocked here, `settings.json`'s `ask` list no longer includes it — leaving it
  there would misleadingly imply a push could be approved through the prompt.
  A floor under (not a replacement for) the remaining `ask` rule on `rm`.
- **`setup-nudge.sh`** (`SessionStart`, `startup|resume`) — if the project has
  no `docs/` yet, injects a one-line reminder to run `/setup`. Silent once
  `docs/` exists.
- **`adr-immutability-nudge.sh`** (`PreToolUse`, `Edit`) — if the edited file
  matches `docs/adr/NNNN-*.md`, injects a reminder that ADRs are historical
  records (only the Status line should change; write a new superseding ADR
  instead of rewriting Context/Decision/Consequences). A **nudge, not a hard
  block**: simple pattern matching can't reliably distinguish a legitimate
  Status-line update from a rewrite, so enforcement would risk blocking the
  legitimate case.
- **`conditional-format.sh`** (`PostToolUse`, `Edit|Write`) — runs the
  project's own formatter (prettier, biome, ruff, gofmt) on the edited file
  **only if** that formatter's config already exists in the repo; otherwise a
  silent no-op. Never introduces a new tool dependency on its own.

## Component: `README.md`

Explains what the harness is (config-based, per-project), the `harness-init.sh`
usage (`--dry-run`, `--force`), the workflow loop, and how `/setup` generates
project docs from the templates.

## Output style (token efficiency)

`/implement` and `/review` embed a **high-signal terse** directive (each in its
own command file — not a shared skill, to stay deterministic and avoid
indirection):

- Minimal narration: report actions and results, not intentions ("done X",
  not "I'm going to do X").
- Normal grammar — **not** literal caveman/telegraphic style.
- **Artifacts stay normal quality:** code, comments, commit messages, and any
  docs the command touches are written clearly and fully. Terseness applies only
  to the assistant's conversational narration.

`CLAUDE.md`, `/brainstorm`, `/plan`, `/setup`, `/update-docs`, and all doc
templates remain in clear, complete prose.

## Living docs (keeping docs current)

Docs are treated as a living system, kept in sync two ways:

1. **Workflow-embedded (continuous):** `/brainstorm` reads docs and flags/asks on
   divergence and drafts ADRs for significant decisions; `/implement` runs a
   doc-impact check at the end and proposes targeted updates.
2. **On-demand (periodic sweep):** `/update-docs` reconciles `docs/` with the
   actual codebase whenever the user runs it.

**Update policy — always ask first.** Every doc change (whether triggered by the
workflow or `/update-docs`) is presented as a proposed diff and written only
after the user confirms. The harness never edits the project record silently.
The one nuance: changes that conflict with `docs/constitution.md` or an existing
ADR are surfaced as conflicts (not just edits) and require explicit resolution —
typically a new ADR superseding the old decision, rather than rewriting history.

## Engineering-docs standards used

- **ADR**: Michael Nygard format (Title · Status · Context · Decision ·
  Consequences); one decision per numbered file.
- **Architecture**: arc42 (condensed) + C4 model levels (Context → Container →
  Component).
- **Runbook**: SRE structure (triggers, diagnostics + commands, links,
  escalation, recovery, verification checklist, owner).
- **General**: write for the audience, one central docs location (`docs/`),
  living docs, clear ownership.

## Testing / Verification

- `harness-init.sh --dry-run` in a scratch dir lists expected files, writes none.
- A real run into an empty scratch dir creates `CLAUDE.md` + `.claude/` (no
  `docs/`); a second run reports all as skipped (non-destructive).
- `--force` overwrites and leaves `.bak` files.
- `settings.json` is valid JSON (`jq .` / `python -m json.tool`).
- Subagent, command, and skill markdown have valid YAML frontmatter.
- Doc templates render as valid markdown and contain only intentional TODO
  placeholders.
- Each hook script tested directly with synthetic stdin JSON: `secret-scan.sh`
  and `block-dangerous-bash.sh` deny on known-bad input and stay silent on
  benign input; `setup-nudge.sh` nudges only when `docs/` is absent;
  `adr-immutability-nudge.sh` nudges only on `docs/adr/NNNN-*.md` paths;
  `conditional-format.sh` exits 0 cleanly whether or not a formatter config or
  binary is present.
- `block-dangerous-bash.sh`'s git rules tested with 17 cases covering both
  sides: blocks plain `git push`, non-force `git push origin main`,
  `git reset --hard` (with and without a target), `git clean -fd`,
  `git branch -D`, `git checkout .`, `git restore .`; allows `git status`,
  `git diff`, checkout/restore of a named branch/file, `git branch -d`
  (lowercase), and `git reset` without `--hard`.
- All hook scripts remain executable after `harness-init.sh` copies them.

## Open Questions

None. (MCP intentionally excluded; per-stack example CLAUDE.md variants
intentionally excluded to stay lean — can be added later.)
