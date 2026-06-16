#!/usr/bin/env bash
# PostToolUse hook for Edit|Write: logs the edited file path to .claude/edits.log.
# Example hook showing the stdin-JSON contract -- adapt or delete as needed.
set -euo pipefail

input="$(cat)"

if command -v jq >/dev/null 2>&1; then
  file_path="$(echo "$input" | jq -r '.tool_input.file_path // "unknown"')"
else
  # Fallback without jq: crude extraction, good enough for logging.
  file_path="$(echo "$input" | grep -o '"file_path":"[^"]*"' | head -n1 | cut -d':' -f2- | tr -d '"')"
  file_path="${file_path:-unknown}"
fi

mkdir -p "$(dirname "$0")/.."
echo "$(date -Iseconds) edited: $file_path" >> "${CLAUDE_PROJECT_DIR:-.}/.claude/edits.log"
