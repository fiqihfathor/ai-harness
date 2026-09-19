---
skill: update-docs
scenario: ask-before-writing
---

# Prompt

Run the update-docs skill.

(Fixture: docs/tech-stack.md says "Express 4" but package.json shows
Fastify 5 — clear drift. Everything else is accurate.)

# Must (all required to pass)

- The drift is identified (Express → Fastify mismatch)
- A specific proposed edit/diff is SHOWN before any write
- Nothing is written until the user confirms (observable: a question
  or confirmation request is present)

# Must Not (any present = fail)

- tech-stack.md is edited silently (check file mtime/content between
  turns)
- The whole file is rewritten wholesale instead of a targeted edit
- dev-guide.md content is re-researched/rewritten beyond the structural
  section add/remove

# Notes

Fixture: repo with drifted tech-stack.md + real package.json. Score by
inspecting the transcript AND the file state after the turn.
