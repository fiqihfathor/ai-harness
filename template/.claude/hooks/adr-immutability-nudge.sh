#!/usr/bin/env bash
# PreToolUse hook (matcher: Edit). Soft reminder when editing an existing
# numbered ADR file: ADRs are historical records. This does not block the
# edit -- it can't reliably distinguish a legitimate Status-line update from
# a rewrite of Context/Decision/Consequences with simple pattern matching,
# so it nudges instead of enforcing.
set -euo pipefail

input="$(cat)"

if command -v jq >/dev/null 2>&1; then
  file_path="$(echo "$input" | jq -r '.tool_input.file_path // ""')"
else
  file_path="$(echo "$input" | grep -o '"file_path":"[^"]*"' | head -n1 | cut -d':' -f2- | tr -d '"')"
fi

if echo "$file_path" | grep -Eq 'docs/adr/[0-9]{4}-.*\.md$'; then
  printf '{"hookSpecificOutput":{"hookEventName":"PreToolUse","additionalContext":"Reminder: ADRs are historical records. Only update the Status line (e.g. to Superseded by NNNN) -- write a new ADR instead of rewriting Context, Decision, or Consequences."}}\n'
fi

exit 0
