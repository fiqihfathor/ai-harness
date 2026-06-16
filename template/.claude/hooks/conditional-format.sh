#!/usr/bin/env bash
# PostToolUse hook (matcher: Write|Edit). Runs the project's own formatter on
# the edited file, if a formatter config is already present in the repo.
# No-op if none is detected -- this never introduces a new tool dependency,
# it only uses what the project already has configured.
set -euo pipefail

project_dir="${CLAUDE_PROJECT_DIR:-.}"
input="$(cat)"

if command -v jq >/dev/null 2>&1; then
  file_path="$(echo "$input" | jq -r '.tool_input.file_path // ""')"
else
  file_path="$(echo "$input" | grep -o '"file_path":"[^"]*"' | head -n1 | cut -d':' -f2- | tr -d '"')"
fi

[[ -z "$file_path" ]] && exit 0
[[ ! -f "$file_path" ]] && exit 0

run_if_present() {
  command -v "$1" >/dev/null 2>&1 || return 0
  "$@" >/dev/null 2>&1 || true
}

if [[ -f "$project_dir/.prettierrc" || -f "$project_dir/.prettierrc.json" || -f "$project_dir/.prettierrc.js" ]]; then
  run_if_present prettier --write "$file_path"
elif [[ -f "$project_dir/biome.json" ]]; then
  run_if_present biome format --write "$file_path"
elif [[ -f "$project_dir/pyproject.toml" ]] && grep -q '\[tool.ruff\]' "$project_dir/pyproject.toml" 2>/dev/null; then
  run_if_present ruff format "$file_path"
elif [[ "$file_path" == *.go ]]; then
  run_if_present gofmt -w "$file_path"
fi

exit 0
