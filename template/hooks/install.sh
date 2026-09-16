#!/usr/bin/env bash
# install.sh — installer for portable git hooks in target projects.
#
# Usage:
#   ./hooks/install.sh             Install/merge git hooks into .git/hooks/
#   ./hooks/install.sh --uninstall Uninstall git hooks added by ai-harness
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
UNINSTALL=0

for arg in "$@"; do
  case "$arg" in
    --uninstall)
      UNINSTALL=1
      ;;
    -h|--help)
      echo "Usage: $0 [--uninstall]"
      echo "Installs or uninstalls ai-harness git hooks into target project."
      exit 0
      ;;
    *)
      echo "Unknown argument: $arg" >&2
      exit 1
      ;;
  esac
done

if ! git rev-parse --git-dir >/dev/null 2>&1; then
  echo "Error: Not inside a git repository." >&2
  exit 1
fi

GIT_DIR="$(git rev-parse --git-dir)"
REPO_ROOT="$(git rev-parse --show-toplevel)"

# Detect hooks directory (respect core.hooksPath if set)
HOOKS_TARGET="$(git config --get core.hooksPath || true)"
if [[ -z "$HOOKS_TARGET" ]]; then
  HOOKS_TARGET="$GIT_DIR/hooks"
elif [[ "$HOOKS_TARGET" != /* ]]; then
  HOOKS_TARGET="$REPO_ROOT/$HOOKS_TARGET"
fi

START_MARKER="# --- AI-HARNESS-GIT-HOOKS-START ---"
END_MARKER="# --- AI-HARNESS-GIT-HOOKS-END ---"

HOOK_NAMES=("pre-commit" "commit-msg" "post-checkout")

install_hook() {
  local hook_name="$1"
  local target_file="$HOOKS_TARGET/$hook_name"

  local dispatcher
  dispatcher=$(cat <<EOF
$START_MARKER
# Managed by ai-harness hooks/install.sh
HARNESS_HOOKS_DIR="$SCRIPT_DIR"
if [ -d "\$HARNESS_HOOKS_DIR/$hook_name" ]; then
  for hook_script in "\$HARNESS_HOOKS_DIR/$hook_name"/*.sh; do
    if [ -x "\$hook_script" ]; then
      "\$hook_script" "\$@" || exit \$?
    fi
  done
fi
$END_MARKER
EOF
)

  mkdir -p "$HOOKS_TARGET"

  if [[ ! -f "$target_file" ]]; then
    printf "#!/usr/bin/env bash\n%s\n" "$dispatcher" > "$target_file"
    chmod +x "$target_file"
    echo "Installed $hook_name hook into $target_file"
  else
    if grep -qF "$START_MARKER" "$target_file"; then
      local tmp_file
      tmp_file="$(mktemp)"
      awk -v start="$START_MARKER" -v end="$END_MARKER" -v block="$dispatcher" '
        BEGIN { in_block = 0 }
        index($0, start) > 0 { print block; in_block = 1; next }
        index($0, end) > 0 { in_block = 0; next }
        !in_block { print }
      ' "$target_file" > "$tmp_file"
      mv "$tmp_file" "$target_file"
      chmod +x "$target_file"
      echo "Updated $hook_name hook in $target_file"
    else
      printf "\n%s\n" "$dispatcher" >> "$target_file"
      chmod +x "$target_file"
      echo "Appended $hook_name dispatcher to $target_file"
    fi
  fi
}

uninstall_hook() {
  local hook_name="$1"
  local target_file="$HOOKS_TARGET/$hook_name"

  if [[ -f "$target_file" ]] && grep -qF "$START_MARKER" "$target_file"; then
    local tmp_file
    tmp_file="$(mktemp)"
    awk -v start="$START_MARKER" -v end="$END_MARKER" '
      BEGIN { in_block = 0 }
      index($0, start) > 0 { in_block = 1; next }
      index($0, end) > 0 { in_block = 0; next }
      !in_block { print }
    ' "$target_file" > "$tmp_file"

    local remaining
    remaining=$(grep -v '^[[:space:]]*$' "$tmp_file" | grep -v '^#!/usr/bin/env bash$' | grep -v '^#!/bin/sh$' || true)
    if [[ -z "$remaining" ]]; then
      rm -f "$target_file" "$tmp_file"
      echo "Removed $hook_name hook file: $target_file"
    else
      mv "$tmp_file" "$target_file"
      chmod +x "$target_file"
      echo "Removed ai-harness dispatcher from $target_file"
    fi
  fi
}

if [[ "$UNINSTALL" -eq 1 ]]; then
  echo "Uninstalling ai-harness git hooks from $HOOKS_TARGET..."
  for hook in "${HOOK_NAMES[@]}"; do
    uninstall_hook "$hook"
  done
  echo "Uninstall complete."
else
  echo "Installing ai-harness git hooks into $HOOKS_TARGET..."
  for hook in "${HOOK_NAMES[@]}"; do
    install_hook "$hook"
  done
  echo "Git hooks installation complete."
fi
