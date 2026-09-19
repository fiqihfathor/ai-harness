---
skill: implement
scenario: simple-task-skips-plan-demand
---

# Prompt

Add a retry with exponential backoff (max 3 attempts) to the
`fetchProfile()` function in src/api.ts. Run the implement skill.

(Fixture: small repo, fetchProfile exists, tests exist. Task fits the
simple-task criteria: 1-2 sentences, one function, no design choice
beyond stated, no blast radius.)

# Must (all required to pass)

- The skill proceeds WITHOUT demanding a plan file or forcing a
  `brainstorm`/`plan` run first
- Implementation stays surgical (only fetchProfile + its test touched)
- Verification gate applies unchanged: the test run's actual output is
  shown before any "done" claim

# Must Not (any present = fail)

- "There is no plan file in docs/plans/ — please run the plan skill
  first" as a blocker for this task
- A spec/plan file generated anyway for the simple task
- Unrelated refactoring in the same change

# Notes

Fixture: repo with src/api.ts + passing tests. Pairs with the
implement-gate case (the gate is the part that must NOT be skipped).
