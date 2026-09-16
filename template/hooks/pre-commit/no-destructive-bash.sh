#!/usr/bin/env bash
# pre-commit/no-destructive-bash.sh — scan staged additions in .sh files for dangerous commands.
#
# What it does:
#   Scans staged changes in shell scripts (*.sh) for dangerous pattern additions:
#     - rm -rf /
#     - Fork bomb :(){ :|:& };:
#     - Pipe to shell (curl | sh, wget | bash)
#     - Disk overwrite (dd of=/dev/sda, > /dev/sd)
#     - Global permissions (chmod -R 777 /)
#   Blocks commit with exit code 1 if dangerous additions are found.
#
# How to test manually:
#   1. Stage a .sh file containing a dangerous command:
#      echo "rm -rf /" > test_danger.sh && git add test_danger.sh
#   2. Run this script directly:
#      ./template/hooks/pre-commit/no-destructive-bash.sh
#   3. Confirm it outputs an explanation and exits with code 1.
#   4. Clean up: git rm -f test_danger.sh
set -euo pipefail

# Fast check: if no staged .sh files exist, exit immediately
sh_files=$(git diff --cached --name-only --diff-filter=ACM -- '*.sh' 2>/dev/null || true)
if [[ -z "$sh_files" ]]; then
  exit 0
fi

found=0
cur_file=""
cur_line=0

check_pattern() {
  local line="$1"
  local file="$2"
  local lineno="$3"

  # Pattern 1: rm -rf /
  if echo "$line" | grep -Eq 'rm[[:space:]]+-[a-zA-Z]*r[a-zA-Z]*f[a-zA-Z]*[[:space:]]+(/|[[:space:]]*$)'; then
    echo "ERROR [no-destructive-bash]: Dangerous command (recursive force-delete of /) in $file:$lineno" >&2
    echo "  Line: $line" >&2
    found=1
  # Pattern 2: Fork bomb :(){ :|:& };:
  elif echo "$line" | grep -Fq ':(){ :|:& };:'; then
    echo "ERROR [no-destructive-bash]: Dangerous command (fork bomb) in $file:$lineno" >&2
    echo "  Line: $line" >&2
    found=1
  # Pattern 3: curl | sh / bash
  elif echo "$line" | grep -Eq 'curl.*\|.*(ba)?sh'; then
    echo "ERROR [no-destructive-bash]: Dangerous command (unvetted remote script execution via curl | sh) in $file:$lineno" >&2
    echo "  Line: $line" >&2
    found=1
  # Pattern 4: wget | sh / bash
  elif echo "$line" | grep -Eq 'wget.*\|.*(ba)?sh'; then
    echo "ERROR [no-destructive-bash]: Dangerous command (unvetted remote script execution via wget | bash) in $file:$lineno" >&2
    echo "  Line: $line" >&2
    found=1
  # Pattern 5: dd of=/dev/sda
  elif echo "$line" | grep -Eq 'dd.*of=/dev/sd'; then
    echo "ERROR [no-destructive-bash]: Dangerous command (raw disk overwrite via dd) in $file:$lineno" >&2
    echo "  Line: $line" >&2
    found=1
  # Pattern 6: chmod -R 777 /
  elif echo "$line" | grep -Eq 'chmod.*-R.*777.*/'; then
    echo "ERROR [no-destructive-bash]: Dangerous command (global world-writable chmod -R 777 /) in $file:$lineno" >&2
    echo "  Line: $line" >&2
    found=1
  # Pattern 7: > /dev/sd
  elif echo "$line" | grep -Eq '>[[:space:]]*/dev/sd'; then
    echo "ERROR [no-destructive-bash]: Dangerous command (direct write to disk device > /dev/sd) in $file:$lineno" >&2
    echo "  Line: $line" >&2
    found=1
  fi
}

# Detailed inspection of added lines in .sh files
while IFS= read -r line; do
  if [[ "$line" =~ ^diff\ --git\ a/.*[[:space:]]b/(.*)$ ]]; then
    cur_file="${BASH_REMATCH[1]}"
  elif [[ "$line" =~ ^@@\ -[0-9]+(,[0-9]+)?\ \+([0-9]+) ]]; then
    cur_line="${BASH_REMATCH[2]}"
  elif [[ "$line" =~ ^\+ && ! "$line" =~ ^\+\+\+ ]]; then
    content="${line#+}"
    check_pattern "$content" "$cur_file" "$cur_line"
    cur_line=$((cur_line + 1))
  fi
done < <(git diff --cached -U0 --no-color -- '*.sh')

if [[ "$found" -ne 0 ]]; then
  echo "" >&2
  echo "Commit blocked by pre-commit no-destructive-bash hook." >&2
  echo "Please remove or safely rewrite the dangerous command additions." >&2
  exit 1
fi

exit 0
