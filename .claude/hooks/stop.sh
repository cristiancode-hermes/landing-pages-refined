#!/usr/bin/env bash
# Stop hook — clean exit.
# Nags the agent (exactly once, guarded by stop_hook_active) if the session is
# ending with uncommitted changes but no fresh shift note in MEMORY.md.
set -uo pipefail

INPUT="$(cat)"
ROOT="${CLAUDE_PROJECT_DIR:-$(pwd)}"

# If we already blocked once this stop, let the session end — no infinite loops.
if command -v jq >/dev/null 2>&1; then
  ACTIVE="$(printf '%s' "$INPUT" | jq -r '.stop_hook_active // false')"
else
  ACTIVE="$(printf '%s' "$INPUT" | python3 -c 'import json,sys; print(str(json.load(sys.stdin).get("stop_hook_active",False)).lower())' 2>/dev/null || echo false)"
fi
[ "$ACTIVE" = "true" ] && exit 0

command -v git >/dev/null 2>&1 || exit 0
git -C "$ROOT" rev-parse --is-inside-work-tree >/dev/null 2>&1 || exit 0

DIRTY="$(git -C "$ROOT" status --porcelain 2>/dev/null)"
[ -z "$DIRTY" ] && exit 0

# Changes exist — was MEMORY.md part of them?
if ! printf '%s' "$DIRTY" | grep -q 'MEMORY\.md'; then
  echo "Session is ending with uncommitted changes but MEMORY.md was not updated. Append a shift note to MEMORY.md (see format at the top of that file): what you did, what state it is in, and what the next session should pick up." >&2
  exit 2
fi

exit 0
