#!/usr/bin/env bash
# install.sh — one-line bootstrap of the LoopKit harness into any repo.
#
#   curl -fsSL https://raw.githubusercontent.com/criscode2022/claude-workflow/main/install.sh | bash
#
# or, with options (run from inside the target repo):
#   ./install.sh                     # install into the current directory
#   ./install.sh --into ../my-app    # install into another repo
#   ./install.sh --with-official     # also add Anthropic's official skills via skills.sh
#
# Copies: .claude/ (contract, settings, hooks, agents, skills), .mcp.json,
# AGENTS.md, .cursor/rules/, MEMORY.md (fresh), run.sh. Existing files are
# backed up with a .bak suffix, never overwritten silently.
set -euo pipefail

REPO="criscode2022/claude-workflow"
BRANCH="main"
TARGET="$(pwd)"
WITH_OFFICIAL=0

while [ $# -gt 0 ]; do
  case "$1" in
    --into) TARGET="$(cd "$2" && pwd)"; shift 2 ;;
    --with-official) WITH_OFFICIAL=1; shift ;;
    --branch) BRANCH="$2"; shift 2 ;;
    -h|--help) grep '^#' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
    *) echo "unknown option: $1" >&2; exit 1 ;;
  esac
done

echo "Installing LoopKit from $REPO@$BRANCH into $TARGET"

# Get the source: local checkout if we're inside it, otherwise fetch a tarball.
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" 2>/dev/null && pwd || echo "")"
if [ -n "$SCRIPT_DIR" ] && [ -d "$SCRIPT_DIR/.claude/skills" ]; then
  SRC="$SCRIPT_DIR"
else
  TMP="$(mktemp -d)"
  trap 'rm -rf "$TMP"' EXIT
  echo "Fetching $REPO@$BRANCH…"
  curl -fsSL "https://github.com/$REPO/archive/refs/heads/$BRANCH.tar.gz" | tar -xz -C "$TMP" --strip-components=1
  SRC="$TMP"
fi

copy() { # copy <relative-path>; backs up existing target
  local rel="$1" src="$SRC/$1" dst="$TARGET/$1"
  [ -e "$src" ] || return 0
  if [ -e "$dst" ]; then
    echo "  ~ $rel exists — backing up to $rel.bak"
    cp -a "$dst" "$dst.bak"
  fi
  mkdir -p "$(dirname "$dst")"
  cp -a "$src" "$dst"
  echo "  + $rel"
}

copy ".claude"
copy ".mcp.json"
copy "AGENTS.md"
copy "CLAUDE.md"
copy ".cursor"
copy ".opencode"
copy "opencode.json"
copy "run.sh"
chmod +x "$TARGET/run.sh" "$TARGET/.claude/hooks/"*.sh 2>/dev/null || true

# Fresh MEMORY.md (template only — no history from the blueprint repo).
if [ ! -e "$TARGET/MEMORY.md" ]; then
  awk '/^---$/{exit} {print}' "$SRC/MEMORY.md" > "$TARGET/MEMORY.md"
  echo "  + MEMORY.md (fresh)"
fi

# Keep local agent artifacts out of git.
if [ -f "$TARGET/.gitignore" ] && ! grep -q '^\.claude/logs/' "$TARGET/.gitignore"; then
  printf '\n# LoopKit local artifacts\n.claude/logs/\n.claude/settings.local.json\n' >> "$TARGET/.gitignore"
  echo "  + .gitignore entries"
fi

# Optional: official Anthropic skills via skills.sh (works for Claude Code,
# Cursor, Copilot & more). https://www.skills.sh/
if [ "$WITH_OFFICIAL" -eq 1 ]; then
  if command -v npx >/dev/null 2>&1; then
    echo "Adding official Anthropic skills (frontend-design, webapp-testing, skill-creator)…"
    (cd "$TARGET" && npx -y skills add anthropics/skills) || \
      echo "  ! skills.sh install failed — run 'npx skills add anthropics/skills' manually."
  else
    echo "  ! npx not found — skipping official skills. Run: npx skills add anthropics/skills"
  fi
fi

echo
echo "Done. Next steps:"
echo "  1. Open the repo in Claude Code (hooks + skills load automatically)"
echo "     or Cursor (AGENTS.md + .cursor/rules apply automatically)."
echo "  2. Read .claude/CLAUDE.md — the operating contract."
echo "  3. Try the loop runner: ./run.sh --dry-run \"hello loop\""
