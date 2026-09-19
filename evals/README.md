# Skill Evaluations

Model-based tests for the harness skills — each eval is a scenario prompt
plus the behaviors a correct execution MUST show (and must-NOT show).
Inspired by the official skill-authoring checklist ("at least three
evaluations created", "tested with real usage scenarios").

## Structure

```
evals/
├── README.md          ← this file
├── cases/             ← one file per scenario
│   ├── <skill>-<scenario>.md
│   └── ...
└── run-evals.sh       ← dispatcher: runs cases through an agent CLI
```

Each case file has:

```markdown
---
skill: <skill-name>
scenario: short name
---

# Prompt

<what to send to the agent, verbatim>

# Must (all required to pass)

- <observable behavior in the response/transcript>

# Must Not (any present = fail)

- <behavior that indicates the skill was ignored or misread>

# Notes

<setup/teardown, fixtures needed>
```

## Running

Manual (any agent CLI; example uses agy):

```sh
./run-evals.sh "$(which agy)"
```

Or one case by hand: send the Prompt section to a fresh session that has
the harness skills installed, score the transcript against Must/Must-Not.

Scoring is judgment-based by design — the behaviors are observable
(wrote a file, asked before writing, cited file:line), not vibes.

## Case inventory (11 cases — full skill coverage)

| Case | Skill | What it guards |
|------|-------|----------------|
| brainstorm-conflict | brainstorm | constitution conflict is surfaced, not silently ignored |
| brainstorm-spec-quality | brainstorm | spec has no placeholders, is self-reviewed, file confirmation asked |
| plan-blast-radius | plan | migration step is flagged with rollback |
| implement-gate | implement | no "done" claim without an evidence run |
| implement-tdd-conditional | implement | TDD invoked only when constitution says so |
| review-constitution | review | diff breaking constitution is a finding |
| diagnose-order | diagnose | no fix before reproduce/hypothesise |
| update-docs-ask-first | update-docs | proposed diffs shown, nothing written without confirm |
| init-idempotent | init | second run = no-op; scripts used, not hand-edited |
| setup-existing-docs | setup | existing docs = source of truth; no silent overwrite |
| implement-tdd-conditional | implement | TDD invoked only when constitution says so |
| review-constitution | review | diff breaking constitution is a finding |
| update-docs-ask-first | update-docs | proposed diffs shown, nothing written without confirm |
| init-idempotent | init | second run = no-op; scripts used, not hand-edited |
| setup-existing-docs | setup | existing docs = source of truth; no silent overwrite |
| brainstorm-spec-quality | brainstorm | spec file written, self-reviewed, file confirmation asked |
| tdd-red-first | tdd | failing test before implementation, red output shown |
| implement-simple-task | implement | simple task skips plan demand, gate stays |
| ask-harness-routing | ask-harness | correct skill named for the situation |
