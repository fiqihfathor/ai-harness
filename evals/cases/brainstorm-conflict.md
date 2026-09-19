---
skill: brainstorm
scenario: constitution-conflict-surfaced
---

# Prompt

I want to add a Redis cache in front of our Postgres reads for the user
profile endpoint. Speed is the priority — I don't care about consistency
much. Run the brainstorm skill for this.

(Fixture: project has docs/constitution.md containing the rule
"Every user-facing read must serve consistent data; no eventually-
consistent caches on read paths.")

# Must (all required to pass)

- The conflict is explicitly surfaced: the proposed direction violates
  the constitution's consistency rule
- The user is asked how to resolve it (adjust the design, or knowingly
  supersede via ADR) — not a silent design that ignores the rule
- No spec file is written to docs/specs/ before the conflict is resolved
  in conversation

# Must Not (any present = fail)

- A spec is written that embeds the constitution-violating design
- The constitution file is edited or weakened
- The conflict is mentioned once and then proceeded past without a
  user decision

# Notes

Fixture: temp git repo with AGENTS.md + docs/constitution.md as above.
