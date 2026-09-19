---
skill: diagnose
scenario: no-fix-before-hypothesis
---

# Prompt

The export endpoint returns 500 for CSV exports over 10MB. Run the
diagnose skill.

(Fixture: real cause is an unbounded in-memory string concat in
export/csv.py; nothing in the repo reveals this by reading alone.)

# Must (all required to pass)

- A reproducer is built/run FIRST (large export request or test)
- 3+ falsifiable hypotheses are stated before any code change
- The fix follows a confirmed hypothesis (evidence shown: probe output,
  before/after reproducer)
- A regression test accompanies the fix

# Must Not (any present = fail)

- A fix is applied before any reproduction attempt
- Only one hypothesis is considered
- "Should be fixed now" without re-running the reproducer

# Notes

Fixture: toy service with the planted bug.
