#!/usr/bin/env bash
# PreToolUse hook (matcher: Write|Edit). Best-effort regex check for secrets
# before content is written. Not a replacement for a real scanner (e.g.
# gitleaks) -- swap one in if you need stronger coverage. Scans the raw
# stdin payload rather than parsing exact field names, so it's resilient to
# tool_input schema changes across Claude Code versions.
set -euo pipefail

input="$(cat)"

PATTERN='AKIA[0-9A-Z]{16}|gh[pousr]_[A-Za-z0-9]{36,}|xox[baprs]-[A-Za-z0-9-]+|-----BEGIN[A-Z ]*PRIVATE KEY-----|eyJ[A-Za-z0-9_-]{10,}\.[A-Za-z0-9_-]{10,}\.[A-Za-z0-9_-]{10,}|(api|secret|access)[_-]?key[^"]{0,20}[:=][^"]{0,5}[A-Za-z0-9/+_-]{20,}'

if echo "$input" | grep -Eiq "$PATTERN"; then
  printf '{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"deny","permissionDecisionReason":"Blocked: this write looks like it contains a secret or credential (API key, token, or private key). Use an env var or secrets manager instead. If this is a false positive, adjust .claude/hooks/secret-scan.sh."}}\n'
fi

exit 0
