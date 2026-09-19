#!/usr/bin/env bash
# append-context-block.sh — append the harness context block to an existing
# context file (AGENTS.md, CLAUDE.md, or similar), idempotently.
#
# Usage: append-context-block.sh <TARGET_FILE> <BLOCK_SOURCE_FILE> [MARKER_VERSION]
#   TARGET_FILE     existing context file to append into (not modified if
#                   already marked)
#   BLOCK_SOURCE    file whose content becomes the marked block
#   MARKER_VERSION  marker version string, default: v1
#
# Exit codes: 0 = appended or already-present; 1 = usage error;
#             2 = target missing/unreadable.
#
# Test: bash append-context-block.sh /tmp/test.md block.md && cat /tmp/test.md
set -euo pipefail

TARGET="${1:-}"
SOURCE="${2:-}"
VER="${3:-v1}"

if [[ -z "$TARGET" || -z "$SOURCE" ]]; then
  echo "Usage: $0 <TARGET_FILE> <BLOCK_SOURCE_FILE> [MARKER_VERSION]" >&2
  exit 1
fi
if [[ ! -f "$TARGET" ]]; then
  echo "append-context-block: target file not found: $TARGET" >&2
  exit 2
fi
if [[ ! -f "$SOURCE" ]]; then
  echo "append-context-block: block source not found: $SOURCE" >&2
  exit 2
fi

BEGIN="<!-- ai-harness:begin:${VER} -->"
END="<!-- ai-harness:end:${VER} -->"

if grep -qF "$BEGIN" "$TARGET" 2>/dev/null; then
  echo "already-merged: ${TARGET} contains ${BEGIN}; nothing to do"
  exit 0
fi

{
  printf '\n%s\n' "$BEGIN"
  cat "$SOURCE"
  printf '%s\n' "$END"
} >> "$TARGET"

echo "appended: harness block (${BEGIN}) added to ${TARGET}"
