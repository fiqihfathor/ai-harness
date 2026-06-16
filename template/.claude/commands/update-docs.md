---
description: Reconcile docs/ with the current state of the codebase
---

Reconcile the project docs with reality.

## Process

1. Survey the current codebase: structure, dependencies, recent commits/diffs.
2. Compare against `docs/project-overview.md`, `docs/tech-stack.md`,
   `docs/architecture.md`, and `docs/runbook.md`.
3. Identify drift: things the docs claim that are no longer true, or things
   that changed but were never recorded.
4. **`docs/dev-guide.md` — structural check only.** If `docs/tech-stack.md`
   gained or lost a technology, propose adding or removing the matching
   `dev-guide.md` section. Do **not** re-research or rewrite the content of
   existing sections — that's a deliberate refresh the user asks for
   explicitly (e.g. "refresh the RAG section of dev-guide.md"), not something
   this command does automatically.
5. Propose targeted edits (a diff per file) to close the gap. Don't rewrite
   files wholesale — change only what's actually out of date.
6. If a discrepancy looks like it reflects an undocumented architectural
   decision (not just a stale fact), flag it and suggest writing an ADR
   instead of just editing the doc.
7. **Always ask before writing.** Show the proposed diff for each file and
   wait for confirmation. If a proposed change conflicts with
   `docs/constitution.md` or an existing ADR, surface that as a conflict
   requiring an explicit decision, not a routine edit.

## Output

A summary of drift found, followed by per-file proposed diffs, applied only
after the user confirms.
