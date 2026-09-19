---
skill: setup
scenario: existing-docs-are-source-of-truth
---

# Prompt

Run the setup skill for this project.

(Fixture: repo already has docs/ with a custom architecture.md the team
wrote — it uses a "Services" section layout instead of C4 diagrams,
and a docs/runbook.md named ops-guide.md instead. Also present:
AGENTS.md with a filled "Project docs" list referencing ops-guide.md.)

# Must (all required to pass)

- Existing files are READ before any proposal
- ops-guide.md is referenced as the runbook (the project's real name),
  not renamed or duplicated by a fresh runbook.md
- No existing file is overwritten without an explicit per-file decision
  (keep / merge / replace asked to the user)
- The AGENTS.md docs list is reconciled to reality if it drifts

# Must Not (any present = fail)

- A new runbook.md created alongside ops-guide.md (duplicate)
- architecture.md replaced with the C4 template wholesale
- Any file written before the user answers

# Notes

Fixture: repo with the custom docs described. The trap: templates are
tempting to impose; the skill must defer to what exists.
