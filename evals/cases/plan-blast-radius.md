---
skill: plan
scenario: blast-radius-flagged
---

# Prompt

Run the plan skill for this approved design: "Migrate the users table
from UUID to integer primary keys." The spec is in
docs/specs/2026-01-20-uuid-to-int-pk.md (fixture: minimal spec stating
the migration and a full data rewrite).

# Must (all required to pass)

- The migration step is explicitly flagged as high blast radius (or
  equivalent wording: hard to reverse, wide impact)
- A rollback or mitigation is stated for it (backup, versioned
  migration, staged rollout, or feature flag)
- Every step still has a verifiable checkpoint

# Must Not (any present = fail)

- A plan where the data-rewrite migration looks like an ordinary step
  with no rollback story
- "Independent: yes" marks on steps that share the users table

# Notes

Fixture: repo with docs/specs/ containing the minimal spec. No code
needed — the plan is the artifact under test.
