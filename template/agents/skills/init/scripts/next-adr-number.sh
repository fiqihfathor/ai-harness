#!/usr/bin/env bash
# next-adr-number.sh — print the next available ADR number for a docs/adr dir.
#
# Usage: next-adr-number.sh [ADR_DIR]
#   ADR_DIR  directory containing NNN-*.md / NNNN-*.md ADR files, default: docs/adr
#
# Padding follows the repo's existing convention: the width of the
# highest-numbered ADR file wins (3-digit repos keep getting 3 digits,
# 4-digit repos keep getting 4). Default for an empty/new dir: 0001.
#
# Prints the next number to stdout. Exits 0 on success (including empty dir).
#
# Test: next-adr-number.sh /tmp/adrtest
set -euo pipefail

DIR="${1:-docs/adr}"

if [[ ! -d "$DIR" ]]; then
  echo "0001"
  exit 0
fi

max=0
maxwidth=0
while IFS= read -r -d '' f; do
  base="$(basename "$f" .md)"
  n="${base%%-*}"
  if [[ "$n" =~ ^[0-9]+$ ]] && (( 10#$n > 10#$max )); then
    max="$n"
    maxwidth="${#n}"
  fi
done < <(find "$DIR" -maxdepth 1 -name '[0-9]*-*.md' -print0 2>/dev/null)

if (( max == 0 )); then
  echo "0001"
else
  printf '%0*d\n' "$maxwidth" "$(( 10#$max + 1 ))"
fi
