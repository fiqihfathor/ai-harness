#!/usr/bin/env bash
# harness-init.sh — copy the ai-harness template into a project repo.
#
# Usage:
#   ./harness-init.sh [TARGET_DIR] [--force] [--dry-run]
#
# Copies CLAUDE.md, AGENTS.md, .claude/, and agents/ from this repo's template/ into TARGET_DIR
# (default: current directory). Never overwrites existing files unless
# --force is given (in which case the original is backed up to *.bak first).
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEMPLATE_DIR="$SCRIPT_DIR/template"

usage() {
  cat <<'EOF'
Usage: harness-init.sh [TARGET_DIR] [--force] [--dry-run]

Copies the ai-harness template (CLAUDE.md, AGENTS.md, .claude/, agents/) into TARGET_DIR.

  TARGET_DIR    Directory to initialize (default: current directory)
  --force       Overwrite existing files (backs up the original to *.bak first)
  --dry-run     Print what would happen; change nothing
  -h, --help    Show this help
EOF
}

TARGET_DIR="."
FORCE=0
DRY_RUN=0

for arg in "$@"; do
  case "$arg" in
    -h|--help)
      usage
      exit 0
      ;;
    --force)
      FORCE=1
      ;;
    --dry-run)
      DRY_RUN=1
      ;;
    -*)
      echo "Unknown option: $arg" >&2
      usage >&2
      exit 1
      ;;
    *)
      TARGET_DIR="$arg"
      ;;
  esac
done

if [[ ! -d "$TARGET_DIR" ]]; then
  echo "Error: target directory does not exist: $TARGET_DIR" >&2
  exit 1
fi

if [[ ! -d "$TEMPLATE_DIR" ]]; then
  echo "Error: template directory not found at $TEMPLATE_DIR" >&2
  exit 1
fi

TARGET_DIR="$(cd "$TARGET_DIR" && pwd)"

created=()
skipped=()
overwritten=()

# Walk every file in the template and mirror it into TARGET_DIR.
while IFS= read -r -d '' src_file; do
  rel_path="${src_file#"$TEMPLATE_DIR"/}"
  dest_file="$TARGET_DIR/$rel_path"

  if [[ -e "$dest_file" ]]; then
    if [[ "$FORCE" -eq 1 ]]; then
      if [[ "$DRY_RUN" -eq 1 ]]; then
        echo "[dry-run] would back up and overwrite: $rel_path"
      else
        cp "$dest_file" "$dest_file.bak"
        mkdir -p "$(dirname "$dest_file")"
        cp "$src_file" "$dest_file"
      fi
      overwritten+=("$rel_path")
    else
      skipped+=("$rel_path")
    fi
    continue
  fi

  if [[ "$DRY_RUN" -eq 1 ]]; then
    echo "[dry-run] would create: $rel_path"
  else
    mkdir -p "$(dirname "$dest_file")"
    cp "$src_file" "$dest_file"
  fi
  created+=("$rel_path")
done < <(find "$TEMPLATE_DIR" -type f -print0)

echo ""
echo "Summary for $TARGET_DIR:"
echo "  Created:     ${#created[@]}"
echo "  Overwritten: ${#overwritten[@]}"
echo "  Skipped (already exist): ${#skipped[@]}"

if [[ "${#skipped[@]}" -gt 0 ]]; then
  echo ""
  echo "Skipped existing files (use --force to overwrite):"
  for f in "${skipped[@]}"; do
    echo "  - $f"
  done
fi

if [[ "$DRY_RUN" -eq 1 ]]; then
  echo ""
  echo "(dry run — no files were written)"
fi

if [[ "${#created[@]}" -eq 0 && "${#overwritten[@]}" -eq 0 && "$DRY_RUN" -eq 0 ]]; then
  echo ""
  echo "Nothing to do — all template files already exist. Use --force to overwrite."
fi

# Make sure any copied hook scripts stay executable.
if [[ "$DRY_RUN" -eq 0 ]]; then
  if [[ -d "$TARGET_DIR/.claude/hooks" ]]; then
    chmod +x "$TARGET_DIR"/.claude/hooks/*.sh 2>/dev/null || true
  fi
  if [[ -d "$TARGET_DIR/hooks" ]]; then
    chmod +x "$TARGET_DIR"/hooks/*.sh 2>/dev/null || true
    chmod +x "$TARGET_DIR"/hooks/*/*.sh 2>/dev/null || true
  fi
fi

if [[ "$DRY_RUN" -eq 0 ]]; then
  echo ""
  echo "Harness layers initialized:"
  echo "  - Portable git hooks: run 'hooks/install.sh' to add git-level enforcement for ANY agent"
  echo "  - Claude Code users additionally get .claude/hooks automatically (hooks, subagents, slash commands)"
  echo "  - Any-agent users point their agent at agents/skills/ (per-project) or copy to their global skills dir"
fi
