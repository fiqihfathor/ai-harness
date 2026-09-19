#!/usr/bin/env bash
# next-adr-number.sh — print the next available ADR number for a docs/adr dir.
#
# Usage: next-adr-number.sh [ADR_DIR]
#   ADR_DIR  directory containing NNNN-*.md ADR files, default: docs/adr
#
# Prints the next number (zero-padded to 4) to stdout. Prints 0001 and exits 0
# when the dir is missing or empty. Exits 1 only on usage/system errors.
#
# Test: next-adr-number.sh /tmp/adrtest
set -euo pipefail

DIR="${1:-docs/adr}"

if [[ ! -d "$DIR" ]]; then
  echo "0001"
  exit 0
fi

max=0
while IFS= read -r -d '' f; do
  base="$(basename "$f" .md)"
  n="${base%%-*}"
  if [[ "$n" =~ ^[0-9]+$ ]]; then
    (( n > max )) && max="$n"
  fi
done < <(find "$DIR" -maxdepth 1 -name '[0-9]*-*.md' -print0 2>/dev/null)

printf '%04d\n' "$(( max + 1 ))"
