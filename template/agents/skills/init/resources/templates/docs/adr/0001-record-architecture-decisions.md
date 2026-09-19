# 0001. Record architecture decisions

## Status

Accepted

## Context

We need a way to record significant architectural decisions so that the
reasoning behind them survives team changes and isn't lost to chat history or
memory. Without a record, the same trade-offs get re-debated and decisions get
silently reversed without anyone noticing the original context.

## Decision

We will use Architecture Decision Records (ADRs), one markdown file per
decision, stored in `docs/adr/`, numbered sequentially, following the Nygard
format (Title, Status, Context, Decision, Consequences). See `docs/adr/README.md`
for the full process.

## Consequences

- Significant decisions and their rationale are discoverable in one place.
- Decisions can be revisited and explicitly superseded rather than silently
  contradicted by later changes.
- Adds a small amount of process overhead: every architecturally significant
  change should be accompanied by a new or updated ADR.
