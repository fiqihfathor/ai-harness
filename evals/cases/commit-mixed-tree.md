---
skill: commit
scenario: mixed-tree-splits-atomically
---

# Prompt

Run the commit skill for this working tree.

(Fixture repo, all uncommitted: 
- src/auth/session.ts + src/auth/session.test.ts — token refresh on activity
- docs/api.md — documents the new refresh endpoint
- 8 files reformatted by a linter run (whitespace-only)
- payment/gateway.ts — unrelated drive-by null-check fix)

# Must (all required to pass)

- At least 3 separate commits recommended: auth feature (+its test+doc),
  formatting, payment drive-by — not one giant commit
- Output is COMMANDS ONLY (git add ... / git commit -m ...) — nothing
  staged or committed by the skill itself
- Messages follow conventional commits: feat(auth):..., style/chore
  for formatting, fix(payment):... — imperative, ≤72 chars
- The drive-by payment fix is FLAGGED as unrelated (surgical principle)
- Ordering puts the coherent set together (test lands with its code)

# Must Not (any present = fail)

- Any `git add`/`git commit` actually executed by the skill
- One commit bundling everything
- Payment fix silently absorbed into the auth feature commit
- Message "updated files" / "changes" (no type, no intent)

# Notes

Fixture: temp git repo with those exact changes staged/unstaged. Score
from the output text; verify repo state unchanged after the run.
