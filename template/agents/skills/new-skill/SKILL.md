---
name: new-skill
description: Help create a new command, skill, subagent, or hook for this project, choosing the right type and applying this harness's conventions. Use when the user wants to add a new skill, automate a workflow, restrict a subtask's tools, or enforce something on every tool call.
---

# Extend the harness

*Claude Code users: this is /new-skill.*

Generic skill-authoring knowledge (frontmatter format, how agents load
files) is already well-covered by standard agent documentation. What this skill adds is
specific to *this* harness: picking the right artifact type, and applying the
conventions already established in the `brainstorm`, `plan`, `implement`,
`review` skills, and the existing hooks/agents — so a new addition feels native to
this project, not bolted on.

## Step 1 — pick the right type

Ask what's needed, then match it to the type whose job it actually is:

| If the user wants... | Use | Why |
|---|---|---|
| A workflow step or reusable capability | **Skill** (`agents/skills/name/SKILL.md` or `.claude/commands/name.md`) | Lazy-loaded — costs nothing in context until invoked; description-matched. |
| Isolated context for a subtask (keep verbose output out of the main thread), or restricted tools/a different model for one job | **Subagent** (`.claude/agents/name.md` or your harness's subagent mechanism if available) | Runs in its own fresh context; parent only sees the final result. See `code-reviewer.md` (read-only) and `test-runner.md` (Bash+Read+Grep) for the pattern. |
| Something enforced on *every* matching tool call, regardless of how the request is phrased | **Hook** (`.claude/hooks/name.sh` + an entry in `settings.json`) | The only deterministic, unconditional option — not subject to the model's judgment that turn. |

If genuinely unsure, default to a **skill** in `agents/skills/` for maximum portability across different AI dev tools.

## Step 2 — gather what it needs to do

Ask (don't assume): what triggers it, what it should produce, whether it
touches `docs/`, whether it claims success/completion, whether it should run
read-only or needs write/Bash access.

## Step 3 — generate the file, applying harness conventions where relevant

- **Frontmatter:** skills need `name` (kebab-case) and `description`; subagents need `name`, `description`, `tools`, optionally `model`; hooks are plain scripts wired into config.
- **Skill folder anatomy** (when the skill needs more than instructions):
  `my-skill/SKILL.md` (required) plus optional `scripts/` (executable helpers —
  treat as black boxes, document a `--help`/usage header, keep deterministic
  and side-effect-light), `examples/` (reference implementations), and
  `resources/` (templates, schemas, data files the skill copies from —
  e.g. the `init` skill keeps its bootstrap templates there). Keep SKILL.md
  the entry point; reference the other folders by relative path.
- **If it writes code or runs commands and claims "done"/"fixed"/"passing":**
  add a verification gate like the `implement` skill's — no claiming success without
  having just run the evidence for it.
- **If it does meaningful execution work:** consider the terse-narration +
  safety-exception pattern from the `implement`/`review` skills (terse chatter, normal
  language for security/irreversible/complex moments) — optional, not every
  addition needs it.
- **If it touches `docs/`:** be doc-aware — read relevant docs first, always
  propose a diff and ask before writing, surface conflicts with
  `docs/constitution.md` or an ADR explicitly rather than overwriting.
- **If it's a read-only subagent:** restrict tools to read-only search/view operations
  and say so explicitly in the prompt.
- **If it's a hook:** remember the stdin-JSON contract (no env var for file
  paths/commands — read `tool_input` from stdin), that `PreToolUse` can deny
  via `permissionDecision` but `PostToolUse` cannot block. Test it directly with synthetic stdin
  JSON before wiring it into config.

## Step 4 — verify before calling it done

Same discipline as the rest of this harness: check frontmatter is valid,
confirm skill definitions are valid. Don't just assert the new addition works.
