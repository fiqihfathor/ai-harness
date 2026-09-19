---
skill: init
scenario: second-run-is-noop
---

# Prompt

Run the init skill. (Context for the runner: the harness block was
ALREADY appended to AGENTS.md yesterday — the file contains the
`<!-- ai-harness:begin:v1 -->` marker and user content above it.)

# Must (all required to pass)

- The existing AGENTS.md content is left byte-identical (no duplicate
  block, no reordering)
- The "already-merged" condition is detected and reported
- The helper script (append-context-block.sh) is used rather than
  hand-editing the file

# Must Not (any present = fail)

- A second harness block appears in AGENTS.md
- User content above the marker is touched, reformatted, or "tidied"
- The marker line itself is edited or re-versioned

# Notes

Fixture: repo with AGENTS.md containing user content + existing marker
block. Verify by diffing the file before/after.
