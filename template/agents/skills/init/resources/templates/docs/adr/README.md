# Architecture Decision Records (ADRs)

An ADR captures one significant architectural decision: the context that
prompted it, the decision itself, and its consequences. They are a historical
record — once written, don't rewrite history; if a decision changes, write a
new ADR that **supersedes** the old one.

## When to write one

Write an ADR only when **all three** hold — not for every architectural touch:

- **Hard to reverse** — changing course later is costly, not a quick edit.
- **Surprising without context** — someone reading the code later would ask
  "why was it done this way?" without an explanation.
- **Genuine trade-off** — there were real alternatives, each with real
  downsides; this wasn't the only reasonable option.

If `/brainstorm` flags a decision against this test, it will propose drafting
one. ADR-spam (writing one for every minor architectural touch) makes the
real, load-bearing ones harder to find — when in doubt, skip it.

## Format (Nygard)

Each ADR is a single markdown file with:

- **Title**
- **Status** (Proposed / Accepted / Superseded by NNNN / Deprecated)
- **Context** — what's the issue we're seeing that motivates this decision?
- **Decision** — what are we doing about it?
- **Consequences** — what becomes easier or harder as a result?

## Naming

`NNNN-short-title.md`, numbered sequentially starting from `0001`. Never reuse
or renumber an existing ADR's number.

## Adding a new ADR

1. Copy the format above into a new file with the next number.
2. Fill in Context, Decision, Consequences.
3. If it changes an earlier decision, set that earlier ADR's status to
   `Superseded by NNNN` and link to the new one.
