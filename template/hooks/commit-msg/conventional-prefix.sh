#!/usr/bin/env bash
# commit-msg/conventional-prefix.sh — validate commit message follows conventional commits specification.
#
# What it does:
#   Validates that the first line of the commit message matches the Conventional Commits format:
#     ^(feat|fix|docs|style|refactor|perf|test|build|ci|chore|revert|merge)(\([^)]+\))?!?: .+
#   Allows git merge commits starting with "Merge " to pass automatically.
#   Exits 1 with format explanation if validation fails.
#
# How to test manually:
#   1. Create a test message file:
#      echo "invalid commit message" > /tmp/test_msg.txt
#   2. Run this script:
#      ./template/hooks/commit-msg/conventional-prefix.sh /tmp/test_msg.txt
#   3. Confirm exit code 1.
#   4. Test a valid message:
#      echo "feat: add portable git hooks" > /tmp/test_msg.txt
#      ./template/hooks/commit-msg/conventional-prefix.sh /tmp/test_msg.txt
#   5. Confirm exit code 0.
set -euo pipefail

if [[ $# -lt 1 || ! -f "$1" ]]; then
  echo "Usage: $0 <commit-msg-file>" >&2
  exit 1
fi

msg_file="$1"
first_line=$(grep -v '^[[:space:]]*#' "$msg_file" | head -n1 || true)

if [[ -z "$first_line" ]]; then
  echo "ERROR [commit-msg]: Commit message is empty." >&2
  exit 1
fi

# Allow merge commits
if [[ "$first_line" =~ ^Merge[[:space:]] ]]; then
  exit 0
fi

# Conventional Commits regex
PATTERN='^(feat|fix|docs|style|refactor|perf|test|build|ci|chore|revert|merge)(\([^)]+\))?!?: .+'

if ! echo "$first_line" | grep -Eq "$PATTERN"; then
  echo "ERROR [commit-msg]: Invalid commit message prefix." >&2
  echo "  Received: \"$first_line\"" >&2
  echo "" >&2
  echo "Commit message first line must match Conventional Commits format:" >&2
  echo "  <type>[optional scope][!]: <description>" >&2
  echo "" >&2
  echo "Allowed types: feat, fix, docs, style, refactor, perf, test, build, ci, chore, revert, merge" >&2
  echo "Examples:" >&2
  echo "  feat: add secret scan git hook" >&2
  echo "  fix(parser): handle empty input gracefully" >&2
  echo "  docs: update AGENTS.md layout section" >&2
  exit 1
fi

exit 0
