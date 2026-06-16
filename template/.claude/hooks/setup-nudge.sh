#!/usr/bin/env bash
# SessionStart hook. Nudges to run /setup if docs/ hasn't been generated yet.
# Silent once docs/ exists -- this never repeats itself unnecessarily.
set -euo pipefail

project_dir="${CLAUDE_PROJECT_DIR:-.}"

if [[ ! -d "$project_dir/docs" ]]; then
  printf '{"hookSpecificOutput":{"hookEventName":"SessionStart","additionalContext":"This project has no docs/ yet. Consider running /setup to generate project-overview, tech-stack, architecture, dev-guide, runbook, and constitution docs."}}\n'
fi

exit 0
