#!/usr/bin/env bash
# PreToolUse hook — guard bad calls.
# Receives the tool call as JSON on stdin. Exit 2 + stderr message blocks the
# call and feeds the message back to the agent; exit 0 lets it through.
set -euo pipefail

INPUT="$(cat)"

# Extract the Bash command from the payload (jq if available, python3 fallback).
if command -v jq >/dev/null 2>&1; then
  CMD="$(printf '%s' "$INPUT" | jq -r '.tool_input.command // empty')"
else
  CMD="$(printf '%s' "$INPUT" | python3 -c 'import json,sys; print(json.load(sys.stdin).get("tool_input",{}).get("command",""))' 2>/dev/null || true)"
fi

[ -z "$CMD" ] && exit 0

block() {
  echo "BLOCKED by .claude/hooks/pre-tool-use.sh: $1" >&2
  exit 2
}

# Destructive filesystem operations outside the workspace
echo "$CMD" | grep -Eq '(^|[;&| ])rm[[:space:]]+(-[a-zA-Z]*[rf][a-zA-Z]*[[:space:]]+)+(/|~|\$HOME)([[:space:]]|$|/\*)' \
  && block "rm -rf against / or \$HOME. Target an explicit project path instead."

# History rewrites on shared branches
echo "$CMD" | grep -Eq 'git[[:space:]]+push[[:space:]].*(--force|-f)([[:space:]]|$).*[[:space:]](main|master)([[:space:]]|$)' \
  && block "force-push to main/master. Push to a feature branch and open a PR."
echo "$CMD" | grep -Eq 'git[[:space:]]+push[[:space:]]+.*[[:space:]](main|master)[[:space:]]+.*(--force|-f)' \
  && block "force-push to main/master. Push to a feature branch and open a PR."

# Secrets exfiltration (.env.example is explicitly allowed)
if echo "$CMD" | grep -Eq '(cat|less|head|tail|grep|sed|awk)[[:space:]].*\.env(\.[A-Za-z0-9]+)?([[:space:]]|$)' \
   && ! echo "$CMD" | grep -Eq '\.env\.example([[:space:]]|$)'; then
  block "reading .env files. Use .env.example for variable names."
fi

# World-writable permissions
echo "$CMD" | grep -Eq 'chmod[[:space:]]+(-[a-zA-Z]+[[:space:]]+)?777' \
  && block "chmod 777. Use the narrowest permission that works (e.g. 755/644)."

# Piping the internet into a shell
echo "$CMD" | grep -Eq '(curl|wget)[^|;&]*\|[[:space:]]*(ba|z|da)?sh' \
  && block "piping a remote script into a shell. Download, inspect, then run."

exit 0
