---
skill: ask-harness
scenario: correct-routing
---

# Prompt (send ALL THREE, one at a time, fresh session each)

a) "I have a vague idea about improving our search ranking but I'm not
   sure it's worth doing."
b) "Tests are red on CI, something about a flaky login test. It fails
   randomly."
c) "Our docs are way out of date since the big refactor last month."

# Must (for each sub-prompt)

- a) → routed to `brainstorm` (idea → approved design before code)
- b) → routed to `diagnose` (structured loop), NOT implement
- c) → routed to `update-docs`
- Each routing names the skill and gives a one-line why

# Must Not (any present = fail)

- a) → any of implement/plan (skipping design)
- b) → implement (jumping to fix without diagnosis)
- c) → setup (regenerating docs instead of reconciling)

# Notes

No fixture needed — pure routing test against the router skill's map.
Three fresh sessions (or one session, three turns — record which).
