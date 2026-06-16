#!/usr/bin/env bash
# PreToolUse hook (matcher: Bash). Hard-blocks a list of destructive/
# irreversible command patterns, regardless of permission settings. This is a
# floor under settings.json's permission rules, not a replacement for them --
# intentionally best-effort, not exhaustive.
#
# Git rules are intentionally conservative: ALL git push is blocked (not just
# force-push), along with other commands that destroy local/uncommitted work
# or history. The rationale: these are either hard to undo or undo work
# someone else can't see coming. Run them yourself outside Claude Code.
set -euo pipefail

input="$(cat)"
blocked=0
reason=""

check() {
  if echo "$input" | grep -Eq "$1"; then
    blocked=1
    reason="$2"
  fi
}

# --- System-destructive ---
check 'rm[[:space:]]+-[a-zA-Z]*r[a-zA-Z]*f[a-zA-Z]*[[:space:]]+(/|~|\$HOME)([[:space:]"]|$)' \
  "recursive force-delete of / or home"
check 'rm[[:space:]]+-[a-zA-Z]*f[a-zA-Z]*r[a-zA-Z]*[[:space:]]+(/|~|\$HOME)([[:space:]"]|$)' \
  "recursive force-delete of / or home"
check '\b(mkfs|dd)\b[^"]*of=/dev/' \
  "disk-level write to a device"
check 'chmod[[:space:]]+-R[[:space:]]+777[[:space:]]+/([[:space:]"]|$)' \
  "world-writable permissions on /"
if echo "$input" | grep -Fq ':(){ :|:& };:'; then
  blocked=1
  reason="fork bomb"
fi

# --- Git: destroys local/uncommitted work, history, or pushes irreversibly ---
check 'git[[:space:]]+push\b' \
  "git push (all forms are blocked -- push yourself outside Claude Code)"
check 'git[[:space:]]+reset[^"]*--hard\b' \
  "git reset --hard (discards uncommitted work)"
check 'git[[:space:]]+clean[^"]*-[a-zA-Z]*f' \
  "git clean -f (permanently deletes untracked files)"
check 'git[[:space:]]+branch[^"]*[[:space:]]-D\b' \
  "git branch -D (force-deletes a branch, including unmerged commits)"
check 'git[[:space:]]+checkout[[:space:]]+\.([[:space:]"]|$)' \
  "git checkout . (discards uncommitted changes)"
check 'git[[:space:]]+restore[[:space:]]+\.([[:space:]"]|$)' \
  "git restore . (discards uncommitted changes)"

if [[ "$blocked" -eq 1 ]]; then
  printf '{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"deny","permissionDecisionReason":"Blocked: command matches a known-destructive pattern (%s)."}}\n' "$reason"
fi

exit 0
