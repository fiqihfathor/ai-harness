---
description: Help create a new command, skill, subagent, or hook for this project, choosing the right type and applying this harness's conventions. Use when the user wants to add a new slash command, automate a workflow, restrict a subtask's tools, or enforce something on every tool call.
---

# Extend the harness

Generic skill-authoring knowledge (frontmatter format, how Claude Code loads
files) is already well-covered by Claude Code's own docs and by
`superpowers:writing-skills` if installed globally. What this skill adds is
specific to *this* harness: picking the right artifact type, and applying the
conventions already established in `/brainstorm`, `/plan`, `/implement`,
`/review`, and the existing hooks/agents — so a new addition feels native to
this project, not bolted on.

## Step 1 — pick the right type

Ask what's needed, then match it to the type whose job it actually is:

| If the user wants... | Use | Why |
|---|---|---|
| A workflow step they trigger by typing `/name` | **Command** (`.claude/commands/name.md`) | Deterministic — runs exactly when typed, nothing more. |
| A capability that should activate automatically when relevant, optionally also `/name` | **Skill** (`.claude/skills/name/SKILL.md`) | Lazy-loaded — costs nothing in context until invoked; description-matched. Commands and skills are the same underlying mechanism — use "skill" specifically when auto-invocation or supporting files matter. |
| Isolated context for a subtask (keep verbose output out of the main thread), or restricted tools/a different model for one job | **Subagent** (`.claude/agents/name.md`) | Runs in its own fresh context; parent only sees the final result. See `code-reviewer.md` (read-only) and `test-runner.md` (Bash+Read+Grep) for the pattern. |
| Something enforced on *every* matching tool call, regardless of how the request is phrased | **Hook** (`.claude/hooks/name.sh` + an entry in `settings.json`) | The only deterministic, unconditional option — not subject to the model's judgment that turn. See `secret-scan.sh`/`block-dangerous-bash.sh` for `PreToolUse` denial, `setup-nudge.sh` for `SessionStart` context injection. |

If genuinely unsure, default to **command** for workflow steps and **skill**
for anything that should be reusable/auto-triggered — both are cheap to
create and easy to convert into the other later.

## Step 2 — gather what it needs to do

Ask (don't assume): what triggers it, what it should produce, whether it
touches `docs/`, whether it claims success/completion, whether it should run
read-only or needs write/Bash access.

## Step 3 — generate the file, applying harness conventions where relevant

- **Frontmatter:** commands/skills need `description` (and `argument-hint` if
  it takes input); subagents need `name`, `description`, `tools`, optionally
  `model`; hooks are plain scripts wired into `settings.json`'s `hooks` block
  with the right event + matcher.
- **If it writes code or runs commands and claims "done"/"fixed"/"passing":**
  add a verification gate like `/implement`'s — no claiming success without
  having just run the evidence for it.
- **If it does meaningful execution work:** consider the terse-narration +
  safety-exception pattern from `/implement`/`/review` (terse chatter, normal
  language for security/irreversible/complex moments) — optional, not every
  addition needs it.
- **If it touches `docs/`:** be doc-aware — read relevant docs first, always
  propose a diff and ask before writing, surface conflicts with
  `docs/constitution.md` or an ADR explicitly rather than overwriting.
- **If it's a read-only subagent:** restrict `tools` to `Read, Grep, Glob`
  (no `Edit`/`Write`/`Bash`) and say so explicitly in the prompt.
- **If it's a hook:** remember the stdin-JSON contract (no env var for file
  paths/commands — read `tool_input` from stdin), that `PreToolUse` can deny
  via `permissionDecision` but `PostToolUse` cannot block, and that
  `${CLAUDE_PROJECT_DIR}` is available. Test it directly with synthetic stdin
  JSON before wiring it into `settings.json`.

## Step 4 — verify before calling it done

Same discipline as the rest of this harness: check frontmatter is valid,
test a hook script with real stdin, confirm `settings.json` is still valid
JSON if you edited it. Don't just assert the new addition works.
