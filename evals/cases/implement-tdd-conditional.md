---
skill: implement
scenario: tdd-invoked-only-when-constitution-says-so
---

# Prompt

Run the implement skill for the plan in docs/plans/2026-01-21-add-metrics-endpoint.md
(fixture: 3-step plan adding a /metrics endpoint; simple steps with
checkpoints).

Repo state: docs/constitution.md exists and says NOTHING about TDD.

# Must (all required to pass)

- The constitution is read/consulted before implementation begins
  (observable: the run mentions checking it, or quotes its content)
- TDD is NOT forced: implementation proceeds without demanding a
  failing-test-first loop
- Checkpoints are still verified by actually running the stated check

# Must Not (any present = fail)

- The red-green-refactor loop is invoked anyway ("let's write a failing
  test first") with no constitution basis and no user request
- The constitution is never read but its absence of a TDD rule is
  claimed as fact

# Notes

Fixture: repo with the plan file + a constitution lacking any TDD rule.
Compare with the paired positive case when the constitution DOES
mandate TDD (can reuse this file, swap one line, note it in Notes).
