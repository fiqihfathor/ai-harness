---
skill: brainstorm
scenario: spec-quality-and-file-confirmation
---

# Prompt

Run the brainstorm skill: "We need a way to let users export their
invoice history as CSV." (Answer the skill's questions naturally; at
the end, approve the design.)

# Must (all required to pass)

- The spec is written to docs/specs/YYYY-MM-DD-<slug>.md (real file)
- A self-review pass happens (placeholders / contradictions / scope /
  ambiguity addressed — observable: the skill mentions or performs a
  re-read-and-fix)
- The user is pointed at the FILE PATH and asked to review the actual
  file before proceeding to planning — not just conversational approval

# Must Not (any present = fail)

- The spec exists only in conversation (no file)
- File contains "TBD"/unfinished sections after approval
- The run moves to `plan` without the file-review confirmation

# Notes

Fixture: repo with AGENTS.md + empty docs/. Verify by reading the
written spec file after the turn.
