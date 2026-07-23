#!/usr/bin/env bash
# PostToolUse hook — format the edited file and append to the session log.
# Receives the tool result as JSON on stdin. Always exits 0: formatting is
# best-effort and must never fail the agent's edit.
set -uo pipefail

INPUT="$(cat)"
ROOT="${CLAUDE_PROJECT_DIR:-$(pwd)}"

if command -v jq >/dev/null 2>&1; then
  FILE="$(printf '%s' "$INPUT" | jq -r '.tool_input.file_path // empty')"
else
  FILE="$(printf '%s' "$INPUT" | python3 -c 'import json,sys; print(json.load(sys.stdin).get("tool_input",{}).get("file_path",""))' 2>/dev/null || true)"
fi

[ -z "$FILE" ] || [ ! -f "$FILE" ] && exit 0

# Auto-format only when the project already uses that formatter.
case "$FILE" in
  *.js|*.jsx|*.ts|*.tsx|*.json|*.css|*.md)
    if [ -f "$ROOT/node_modules/.bin/prettier" ]; then
      "$ROOT/node_modules/.bin/prettier" --write "$FILE" >/dev/null 2>&1 || true
    fi
    ;;
  *.py)
    if command -v ruff >/dev/null 2>&1 && [ -f "$ROOT/pyproject.toml" ]; then
      ruff format "$FILE" >/dev/null 2>&1 || true
    elif command -v black >/dev/null 2>&1 && [ -f "$ROOT/pyproject.toml" ]; then
      black -q "$FILE" >/dev/null 2>&1 || true
    fi
    ;;
  *.go)
    command -v gofmt >/dev/null 2>&1 && gofmt -w "$FILE" >/dev/null 2>&1 || true
    ;;
esac

# Append to the local activity log (gitignored).
mkdir -p "$ROOT/.claude/logs"
printf '%s\t%s\n' "$(date -u +%Y-%m-%dT%H:%M:%SZ)" "$FILE" >> "$ROOT/.claude/logs/edits.log" 2>/dev/null || true

exit 0
