---
name: review
description: Use when reviewing the current git diff for bugs, security issues, and simplifications
---

# Review diff

*Claude Code users: this is /review.*

Review the staged and unstaged changes (`git diff HEAD`). Report:

- Correctness bugs
- Security issues
- Simplification / efficiency opportunities

Cite `file:line`. Don't restate the code back to the user.

## Verification gate

Don't claim "no issues found" without having actually traced through the
diff — a blanket pass is only valid if you looked. If you propose a fix,
don't claim it's correct without verifying it (run it, or explain exactly why
you're confident without running it). Never assert a bug is "fixed" because a
fix was applied — only because it was checked.

## Output style

Use high-signal terse narration: findings only, no preamble, no restating
what you're about to do. Normal grammar, not telegraphic/caveman style. This
applies to your narration only — if you propose a fix, write it out fully and
clearly.

**Safety exception:** drop the terse style for security findings — explain
the vulnerability and its impact in full, normal language. A compressed
fragment is the wrong place to risk being misread about a security issue.
