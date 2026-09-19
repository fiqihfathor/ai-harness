---
name: diagnose
description: Use when following a structured debugging loop for an existing bug -- reproduce, hypothesise, instrument, fix
---

# Diagnose bug

*On harnesses that expose skills as slash commands, this skill maps to one — invoke it by whatever name your harness uses.*

Debug systematically: the user's request/target, if given in the invocation.

## Process (six phases)

1. **Build the feedback loop first.** Before anything else, get a fast,
   deterministic pass/fail signal for the bug — a failing test, a curl script,
   a repro command. Treat the loop itself as the priority: the faster and more
   deterministic it is, the faster everything after it goes. Don't skip this
   to "just try a fix" — an unreliable signal makes every later step unreliable.
2. **Reproduce.** Run the loop and confirm the failure matches what was
   reported. Capture the exact symptom (error text, stack trace, observed vs.
   expected) before touching anything.
3. **Hypothesise.** Generate 3-5 ranked, falsifiable hypotheses before
   changing any code. Each must be testable: "If X causes this, then changing
   Y will make it disappear/worse." Share them — a quick domain-knowledge
   check from the user can save an entire investigation branch.
4. **Instrument.** Map each probe to a specific prediction from step 3.
   Change one variable at a time. Prefer breakpoints over scattered logs; if
   you do add debug logging, tag it with a unique prefix so it's easy to find
   and remove later.
5. **Fix + regression test.** Where a correct seam exists, write the
   regression test before the fix: watch it fail, apply the fix, watch it
   pass. Re-run the original reproduction from step 2 to confirm the actual
   symptom is gone, not just the test.
6. **Cleanup + postmortem.** Remove every tagged instrumentation/log added in
   step 4. Confirm the regression test passes and the original bug is gone.
   Briefly note what would have caught this earlier (a missing test, a gap in
   `docs/runbook.md`, a constitution rule) — if it points to a doc gap, that's
   a candidate for the `update-docs` skill or a new ADR, not silent forgetting.

## Feedback loop

Every hypothesis killed in step 3-4 feeds the next iteration: state what the
dead hypothesis RULED OUT, not just that it failed ("not the connection pool
— pool idle during repro") — so the investigation narrows instead of
wandering. If three hypotheses die in a row without narrowing, stop and
report: the mental model of the system is wrong somewhere, and a wrong model
generates wrong hypotheses forever. Ask the user what you might be missing
before burning more cycles.

## Notes

- Don't jump to step 5 without going through 1-4. A fix that "feels right"
  without a falsified/confirmed hypothesis is a guess, not a diagnosis.
- If this bug reveals an architecturally significant decision (see
  the `brainstorm` skill's ADR criteria), propose one — don't just patch and move on.
