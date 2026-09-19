#!/usr/bin/env bash
# run-evals.sh — run skill evaluation cases through an agent CLI.
#
# Usage: run-evals.sh [AGENT_BIN] [CASE_GLOB]
#   AGENT_BIN    agent CLI that accepts:  -p "<prompt>"  (print mode).
#                Default: agy
#   CASE_GLOB    subset of cases, default: all in cases/
#
# Each case's Prompt section is sent to a FRESH session; the human (or a
# judge agent) scores the transcript against Must/Must-Not. This script
# handles dispatch + transcript capture, not judgment.
#
# Output: transcripts/ per-case text files + a summary line per case.
set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
AGENT="${1:-agy}"
GLOB="${2:-*}"
CASES_DIR="$HERE/cases"
OUT="$HERE/transcripts"

mkdir -p "$OUT"

run_case() {
  local file="$1"
  local name
  name="$(basename "$file" .md)"
  local prompt
  prompt="$(awk '/^# Prompt/{flag=1;next}/^# Must \(/{flag=0}flag' "$file")"

  echo "── case: $name"
  if [[ -z "$prompt" ]]; then
    echo "   ERROR: no Prompt section found in $file"
    return 1
  fi

  # Fresh session each case: skills load at session start.
  if command -v "$AGENT" >/dev/null 2>&1; then
    "$AGENT" -p "$prompt" >"$OUT/$name.transcript.txt" 2>&1 || true
    echo "   transcript: $OUT/$name.transcript.txt ($(wc -l <"$OUT/$name.transcript.txt") lines)"
  else
    echo "   agent '$AGENT' not found — prompt saved to $OUT/$name.prompt.txt for manual run"
    printf '%s\n' "$prompt" >"$OUT/$name.prompt.txt"
  fi
}

fail=0
for f in "$CASES_DIR"/$GLOB.md; do
  [[ -f "$f" ]] || continue
  run_case "$f" || fail=1
done

echo
echo "Done. Score each transcript against its case's Must / Must-Not sections."
exit $fail
