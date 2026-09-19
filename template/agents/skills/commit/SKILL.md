---
name: commit
description: Recommend atomic, ordered commits from the current working tree without executing them. Runs git status/diff, groups related changes into logical commits, and outputs ready-to-paste add + commit commands per commit following conventional commits. Use when the user asks for commit message suggestions, has uncommitted changes and wants them split sensibly, or says "commit this" but the changes span multiple concerns.
---

# Commit recommender

*On harnesses that expose skills as slash commands, this skill maps to one — invoke it by whatever name your harness uses.*

Analyze the current working tree and OUTPUT recommended commands —
never stage or commit anything yourself.

## Process

1. **Survey.** Run `git status --porcelain` and `git diff` (staged and
   unstaged; use `--stat` first for orientation, then read the actual
   diffs of non-obvious files). Read enough of each diff to know what it
   actually does — a file name is not a change.
2. **Group into logical commits.** Each commit = one concern (atomic):
   a feature, a fix, a refactor, docs, test-only, chore. Changes that
   exist to serve each other belong together; changes that would revert
   independently belong apart. Typical splits:
   - source change + its tests + its doc line → ONE commit
   - formatting/lint noise vs real logic → SEPARATE commits
   - feature work vs unrelated drive-by fix → SEPARATE commits, flag
     the drive-by to the user (surgical-changes principle: flag, don't
     bundle silently)
3. **Order them** by dependency: the repo should ideally be coherent at
   each commit (a test that exists before the code it tests is a broken
   commit). Infrastructure/refactor first, behavior last, when they
   depend on each other.
4. **Write the messages** per Conventional Commits 1.0.0:
   - `<type>[scope]: <description>` — types: feat, fix, refactor, test,
     docs, chore, perf, style, build, ci
   - description: imperative mood ("add", not "added"/"adds"),
     lowercase, no trailing period, ≤ 72 chars total line
   - scope = module/area touched, when it genuinely helps
   - body (optional, blank line after) — the WHY, not a restatement of
     the diff; include a `BREAKING CHANGE:` footer with `!` on the type
     when APIs change
   - pick the type from the diff's intent, not its surface: renaming a
     variable in 12 files is refactor, not feat
5. **Output format** — one block per commit, in order:

   ```
   # 1 — <one-line rationale for this grouping>
   git add path/one.ts path/one.test.ts
   git commit -m "feat(auth): refresh session token on activity" -m "Prevents expiry mid-session for long forms."

   # 2 — <rationale>
   git add docs/api.md
   git commit -m "docs: document token refresh endpoint"
   ```

   Every changed file from `git status` must appear in exactly one
   `git add` (untracked files included). If a file's changes belong to
   two commits, recommend `git add -p` and say which hunks.

## Rules

- **Recommend only — never execute.** No `git add`, `git commit`,
  `git push` runs from this skill. The user copies what they accept.
- If the working tree mixes secret-looking content (tokens, .env),
  stop and flag it before anything else — do not draft a commit that
  includes it.
- If everything is genuinely one concern, say so — one commit is a
  valid answer; don't split for the sake of splitting.
- State uncertainty honestly: if a diff's intent is unclear, ask one
  question rather than guessing a wrong type.

## Output

A numbered list of ready-to-paste command blocks covering every change,
ordered by dependency, each with conventional-commit messages and a
one-line grouping rationale.
