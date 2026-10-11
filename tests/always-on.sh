#!/usr/bin/env sh
# Check hooks/always-on.sh: flag absent -> no output; flag present -> banner + body, no frontmatter.
set -eu
hook="$(dirname -- "$0")/../hooks/always-on.sh"
tmp=$(mktemp -d); trap 'rm -rf "$tmp"' EXIT

out=$(CLAUDE_CONFIG_DIR="$tmp" sh "$hook")
[ -z "$out" ] || { echo "FAIL: output without flag"; exit 1; }

touch "$tmp/.visual-mode-always"
out=$(CLAUDE_CONFIG_DIR="$tmp" sh "$hook")
first=$(printf '%s\n' "$out" | head -n 1)
case "$first" in "VISUAL MODE ACTIVE (always-on)"*) ;; *) echo "FAIL: banner"; exit 1;; esac
case "$first" in *"stop visual mode"*"$tmp/.visual-mode-always"*) ;; *) echo "FAIL: banner details"; exit 1;; esac
printf '%s\n' "$out" | grep -q '^# Visual mode$' || { echo "FAIL: body missing"; exit 1; }
! printf '%s\n' "$out" | grep -qE '^(---|name:|description:)' || { echo "FAIL: frontmatter leaked"; exit 1; }
echo PASS
