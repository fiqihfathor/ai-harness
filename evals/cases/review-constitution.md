---
skill: review
scenario: constitution-violation-is-a-finding
---

# Prompt

Review the current diff (git diff HEAD).

(Fixture: staged diff adds an in-memory TTL cache on the user-profile
read path — technically clean code, tests included, style fine. The
repo's docs/constitution.md states: "Every user-facing read must serve
consistent data; no eventually-consistent caches on read paths.")

# Must (all required to pass)

- The constitution violation is reported as a FINDING (not a style
  nit, not omitted because the code itself is clean)
- The finding cites the rule it violates (quotes or references the
  constitution line)
- file:line citation is used for the offending code

# Must Not (any present = fail)

- "No issues found — code looks good" while the diff violates a stated
  project rule
- The cache concern raised only as a vague performance remark with no
  reference to the project rule

# Notes

Fixture: repo with the constitution line + a clean-but-violating staged
diff. The trap: the code is objectively well-written; only the rule
check catches it.
