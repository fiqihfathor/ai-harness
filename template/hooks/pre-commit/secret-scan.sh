#!/usr/bin/env bash
# pre-commit/secret-scan.sh — scan staged diff for high-signal secrets.
#
# What it does:
#   Scans staged changes (`git diff --cached`) for high-signal secret patterns:
#     - AWS Access Key IDs (AKIA...)
#     - GitHub Tokens (ghp_..., gho_..., ghu_...)
#     - Generic api_key= / sk- assignments with 20+ character values
#   Blocks commit with exit code 1 if secrets are found, listing file:line.
#
# How to test manually:
#   1. Stage a file containing a test secret:
#      echo "AKIAIOSFODNN7EXAMPLE" > test_secret.txt && git add test_secret.txt
#   2. Run this script directly:
#      ./template/hooks/pre-commit/secret-scan.sh
#   3. Confirm it outputs an error with file:line and exits with code 1.
#   4. Clean up: git rm -f test_secret.txt
set -euo pipefail

# Secret patterns (grep -E)
PATTERN='AKIA[0-9A-Z]{16}|gh[pou]_[A-Za-z0-9]{36}|(api_key|api-key|apikey|secret_key)[[:space:]]*[=:][[:space:]]*["'\'']?[A-Za-z0-9_-]{20,}|sk-[A-Za-z0-9_-]{20,}'

# Fast check: if no staged changes or grep doesn't hit, exit immediately
if ! git diff --cached -U0 --no-color 2>/dev/null | grep -Eq "$PATTERN"; then
  exit 0
fi

found=0
cur_file=""
cur_line=0

# Detailed inspection to output file:line
while IFS= read -r line; do
  if [[ "$line" =~ ^diff\ --git\ a/.*[[:space:]]b/(.*)$ ]]; then
    cur_file="${BASH_REMATCH[1]}"
  elif [[ "$line" =~ ^@@\ -[0-9]+(,[0-9]+)?\ \+([0-9]+) ]]; then
    cur_line="${BASH_REMATCH[2]}"
  elif [[ "$line" =~ ^\+ && ! "$line" =~ ^\+\+\+ ]]; then
    content="${line#+}"
    if echo "$content" | grep -Eq "$PATTERN"; then
      echo "ERROR [secret-scan]: High-signal secret pattern detected in $cur_file:$cur_line" >&2
      echo "  Content: $content" >&2
      found=1
    fi
    cur_line=$((cur_line + 1))
  fi
done < <(git diff --cached -U0 --no-color)

if [[ "$found" -ne 0 ]]; then
  echo "" >&2
  echo "Commit blocked by pre-commit secret-scan hook." >&2
  echo "Please remove credentials before committing or use environment variables." >&2
  exit 1
fi

exit 0
