---
skill: pr-draft
scenario: template-matches-target-branch
---

# Prompt

Run the pr-draft skill for the current branch (targets: first ask / assume main,
then assume dev).

(Fixture: branch with 3 commits — new export-to-CSV feature across
export/csv.ts + export/csv.test.ts, a README note, and a config rename.
docs/specs/2026-01-22-csv-export.md exists describing the feature.)

# Must (all required to pass)

- For target main: description uses the FEATURE framing — What/Why/
  Notable changes/Testing, user-visible language, spec linked
- For target dev: description uses the SUMMARY + module framing —
  Summary bullets + "Changes by module" (export/, docs/, config listed
  separately) + deploy notes section
- Title differs appropriately per target and is ≤72 chars
- Commit list is NOT pasted as the description (narrative synthesis)
- No PR is created — output is paste-ready text only

# Must Not (any present = fail)

- `gh pr create` or any push executed
- Same template used regardless of target branch
- Description = raw `git log --oneline` copy
- "See spec" as the whole Why section

# Notes

Fixture: temp repo, branch off main with the 3 commits + spec file.
Run twice (main, dev targets); score both outputs.
