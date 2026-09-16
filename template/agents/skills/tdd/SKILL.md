---
name: tdd
description: Red-green-refactor test-driven development loop. Use when implementing a feature or bugfix in a project where docs/constitution.md specifies TDD, or when explicitly asked to use TDD.
---

# TDD: red-green-refactor

*Claude Code users: this is /tdd.*

A disciplined loop for writing code with tests driving the design, not
following it as an afterthought.

## The loop

For each unit of behavior (one small piece, not the whole feature at once):

1. **Red.** Write a test for the behavior before writing the implementation.
   Run it. Confirm it fails — and fails for the right reason (the behavior
   genuinely doesn't exist yet, not a typo or setup error).
2. **Green.** Write the minimum code needed to make that test pass. Resist
   adding anything not required by the current test — no speculative
   generalization, no "while I'm here" extras.
3. **Refactor.** With the test green, clean up: remove duplication, improve
   names, simplify structure. Re-run the test after each change — it must
   stay green throughout. Never refactor with a failing test in front of you.
4. **Repeat** for the next small unit of behavior until the feature is done.

## Scoping a unit

Pick the smallest slice of behavior that's worth a single test — usually one
rule, one edge case, or one branch of logic. If a test is hard to write, that
itself is often a signal the unit is too large or the design needs an
interface change; don't force a test around an awkward design, prefer
adjusting the design first.

## Notes

- Skipping straight to "green" because the implementation is obvious is the
  most common way this loop degrades — write the failing test anyway. It's
  the thing that confirms the test would have caught the bug if the
  implementation were wrong.
- If a correct seam doesn't exist yet to test against (e.g. fixing a bug in
  tightly coupled code), it's fine to write the regression test as part of
  step 1 once a seam is established — the discipline is "test before fix,"
  not "test before anything."
- This pairs with your harness's subagent mechanism if available (or running tests directly)
  and with the verification gate in the `implement` skill — every "green" claim must be an
  actual run, not an assumption.
