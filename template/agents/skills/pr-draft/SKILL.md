---
name: pr-draft
description: Recommend a pull-request title and description from the current branch's commits and diff, without opening the PR. Adapts structure to the target branch (feature-focused for main/master, summary-and-changes for dev/uat/staging). Use when the user asks for a PR title/description suggestion, says "draft a PR", or wants PR text before opening one.
---

# PR title & description recommender

*On harnesses that expose skills as slash commands, this skill maps to one — invoke it by whatever name your harness uses.*

Analyze the branch and OUTPUT a ready-to-paste title + description —
never create the PR yourself.

## Process

1. **Determine the target branch.** Default: the branch this one will
   merge into (`git branch -r`, base set in repo config, or ask — one
   question max). The target decides the template (below).
2. **Survey the change.** `git log <base>..HEAD --oneline` (the commit
   list), `git diff <base>...HEAD --stat` (scope), then read the diffs
   of the core files. Also read any linked spec/plan in `docs/specs/`,
   `docs/plans/` — the intent often lives there, not in the diff.
3. **Synthesize, don't paste.** The description is a narrative of what
   the PR achieves, NOT a copy of the commit log. A reviewer should
   understand the change well enough to predict the diff before opening
   it. Root cause for fixes (not just the symptom); link the issue/
   spec when one exists. Never write just "see ticket".
4. **Title.** One line, ≤ 72 chars, imperative, specific enough to be
   distinguished from other open PRs. Conventional-commit prefix when
   the repo's history uses it (`git log --oneline -20` tells you).

## Template by target branch

**→ main / master (release-facing: focus on FEATURES and user-visible
CHANGE)**

```markdown
Title: <feat|fix>: <what changed, user-visible framing>

## What
<2-3 sentences: what this PR changes, in user/feature terms>

## Why
<the motivation — issue link, spec link, or root cause for fixes>

## Notable changes
- <feature/behavior change 1>
- <feature/behavior change 2>
- <breaking change / migration note, if any — say BREAKING loudly>

## Testing
- <how it was verified: commands run, evidence>

## Review guide
- Start with <core file> — the heart of the change
- <anything that looks scary but isn't>
```

**→ dev / uat / staging (integration-facing: focus on SUMMARY and
MODULE-LEVEL CHANGES)**

```markdown
Title: <short summary: area + what landed>

## Summary
<what this branch delivers to this environment, 2-4 bullets>

## Changes by module
- **<module/package>** — <what changed there>
- **<module/package>** — <what changed there>

## Configuration / deploy notes
- <env vars, migrations, feature flags, infra steps — or "none">

## Testing
- <evidence: test runs, QA steps done, environment checks>
```

## Rules

- **Recommend only — never execute.** No `gh pr create`, no push. The
  user pastes what they accept.
- Size honestly: if the diff is > ~400 lines across > ~10 files, note
  it at the top and suggest what could be split into a follow-up PR —
  large PRs get worse reviews.
- Refactors mixed with features: call the mixture out in the summary;
  don't bury a refactor inside a feature bullet.
- Screenshots belong in the PR for UI changes — leave a placeholder
  slot rather than omitting the section silently.
- If CI exists, mention which checks the reviewer should wait for.

## Output

A ready-to-paste PR title and markdown description in the template
matching the target branch.
