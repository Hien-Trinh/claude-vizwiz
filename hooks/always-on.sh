#!/usr/bin/env sh
# SessionStart hook: injects the Visual mode rules when the user has opted in by
# creating $CLAUDE_CONFIG_DIR/.visual-mode-always (default ~/.claude).
# Never blocks session start: any failure exits 0.

claude_dir="${CLAUDE_CONFIG_DIR:-$HOME/.claude}"
flag_path="$claude_dir/.visual-mode-always"

[ -f "$flag_path" ] || exit 0

skill_path="$(dirname -- "$0")/../skills/visual-mode/SKILL.md"
[ -f "$skill_path" ] || exit 0

# Strip a leading YAML frontmatter block, only if its closing --- exists.
body=$(awk '
  NR == FNR {
    if (NR == 1 && $0 ~ /^---[[:space:]]*$/) { in_fm = 1; next }
    if (in_fm && $0 ~ /^---[[:space:]]*$/)   { in_fm = 0; closed = 1 }
    next
  }
  FNR == 1 { strip = closed }
  strip && FNR == 1 && $0 ~ /^---[[:space:]]*$/ { skipping = 1; next }
  skipping && $0 ~ /^---[[:space:]]*$/          { skipping = 0; next }
  !skipping { print }
' "$skill_path" "$skill_path") || exit 0

printf 'VISUAL MODE ACTIVE (always-on). The rules below apply to every response. "stop visual mode" turns it off for this session; delete %s to turn always-on off for good.\n\n%s\n' \
  "$flag_path" "$body"
exit 0
