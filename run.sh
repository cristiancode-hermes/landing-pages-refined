#!/usr/bin/env bash
# run.sh — the loop runner.
# Runs a coding agent on a task in a bounded loop: each iteration gets a fresh
# context, reads MEMORY.md for continuity (the whole point of the shift log),
# works, and exits. The loop stops when the agent reports <TASK_COMPLETE>, or
# after --max-iterations.
#
# Usage:
#   ./run.sh "migrate all components to signal forms"
#   ./run.sh --max-iterations 5 --file task.md
#   ./run.sh --dry-run "some task"
#
# Requires the Claude Code CLI (`claude`). In Cursor or other tools, use this
# file as the reference for the loop protocol and drive it manually.
set -euo pipefail

MAX_ITER=10
TASK=""
DRY_RUN=0

while [ $# -gt 0 ]; do
  case "$1" in
    --max-iterations) MAX_ITER="$2"; shift 2 ;;
    --file) TASK="$(cat "$2")"; shift 2 ;;
    --dry-run) DRY_RUN=1; shift ;;
    -h|--help) grep '^#' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
    *) TASK="$1"; shift ;;
  esac
done

[ -z "$TASK" ] && { echo "error: no task given. Usage: ./run.sh \"task\"" >&2; exit 1; }
command -v claude >/dev/null 2>&1 || {
  echo "error: 'claude' CLI not found. Install: npm install -g @anthropic-ai/claude-code" >&2
  echo "(In Cursor/other agents, follow the loop protocol in this script manually.)" >&2
  exit 1
}

PROMPT_TEMPLATE='You are one iteration of a bounded work loop (iteration %d of %d).

TASK: %s

Protocol:
1. Read MEMORY.md first — previous iterations logged their progress there.
2. Do the next meaningful slice of the task. Commit completed slices.
3. Verify what you did (run tests/build) before logging it as done.
4. Append a shift note to MEMORY.md (format documented in that file).
5. End your reply with exactly one marker:
   <TASK_COMPLETE> if the whole task is verifiably finished,
   <CONTINUE> if another iteration is needed,
   <BLOCKED: reason> if a human must decide something first.'

for i in $(seq 1 "$MAX_ITER"); do
  # shellcheck disable=SC2059
  PROMPT="$(printf "$PROMPT_TEMPLATE" "$i" "$MAX_ITER" "$TASK")"
  echo "── iteration $i/$MAX_ITER ──────────────────────────────"

  if [ "$DRY_RUN" -eq 1 ]; then
    echo "[dry-run] would invoke: claude -p <prompt>"
    continue
  fi

  OUTPUT="$(claude -p "$PROMPT" --permission-mode acceptEdits || true)"
  printf '%s\n' "$OUTPUT" | tail -n 20

  case "$OUTPUT" in
    *"<TASK_COMPLETE>"*) echo "✔ task complete after $i iteration(s)."; exit 0 ;;
    *"<BLOCKED:"*)       echo "✋ blocked — see output above."; exit 2 ;;
  esac
done

echo "⏹ reached max iterations ($MAX_ITER) without completion. Check MEMORY.md for state." >&2
exit 3
