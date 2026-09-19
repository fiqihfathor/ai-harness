---
skill: tdd
scenario: red-before-green
---

# Prompt

Use the tdd skill: implement a `slugify(title)` function for this repo
(Node.js, test file test/slugify.test.js exists with runner wired).

(Fixture: repo has package.json with a test script; no slugify
implementation. Constitution says the project follows TDD.)

# Must (all required to pass)

- The FIRST code artifact shown is a failing test for slugify — not an
  implementation
- The test is RUN and its failure output shown (red), and the failure
  is for the right reason (missing behavior, not a syntax error)
- Implementation arrives only after red, minimal to pass
- A refactor step happens or is consciously skipped with tests re-run
  green

# Must Not (any present = fail)

- Implementation written first, test written to match it after
- "The test would obviously fail" claimed without running it
- Test asserts on implementation details rather than behavior

# Notes

Fixture: minimal Node repo. Score from the transcript order: test
before impl, run output before green claim.
