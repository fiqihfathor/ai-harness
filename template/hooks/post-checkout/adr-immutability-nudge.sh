#!/usr/bin/env bash
# post-checkout/adr-immutability-nudge.sh — nudge developer/agent if checkout touched docs/adr/*.
#
# What it does:
#   Checks if checkout/HEAD movement introduced changes to files in docs/adr/*.
#   If so, prints a friendly non-blocking reminder that Architecture Decision Records (ADRs)
#   are immutable historical records and should be appended to rather than modified.
#   Always exits 0 (never blocks checkout).
#
# How to test manually:
#   1. Run with two commit refs:
#      ./template/hooks/post-checkout/adr-immutability-nudge.sh <old-ref> <new-ref> 1
#   2. Or run without args in a repository where docs/adr/* has changes.
set -euo pipefail

old_ref="${1:-ORIG_HEAD}"
new_ref="${2:-HEAD}"

changed_files=""
if git rev-parse --verify "$old_ref" >/dev/null 2>&1 && git rev-parse --verify "$new_ref" >/dev/null 2>&1; then
  changed_files=$(git diff --name-only "$old_ref" "$new_ref" 2>/dev/null || true)
else
  changed_files=$(git diff --name-only ORIG_HEAD HEAD 2>/dev/null || true)
fi

if echo "$changed_files" | grep -Eq '^docs/adr/'; then
  echo "[ADR Nudge] Note: ADRs in docs/adr/ are immutable historical records. Append new ADRs instead of editing existing ones."
fi

exit 0
