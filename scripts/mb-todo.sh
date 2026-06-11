#!/usr/bin/env bash
# master-brain :: PostToolUse hook body.
# When an AI Marketing Hub brain skill runs, append a TODO into ./todos so the
# follow-up is never dropped. Reads the hook JSON payload on stdin. Always
# exits 0 so it can never break a non-master-brain session.
#
# A brain run is detected by the Skill tool's `skill` input matching a known
# Hub brain (optionally namespaced, e.g. "website-brain:website-brain-build").

set -uo pipefail

payload="$(cat 2>/dev/null || true)"
[ -z "$payload" ] && exit 0

# Extract the skill name from the tool_input (robust JSON via python3, with a
# grep fallback if python3 is unavailable).
skill=""
if command -v python3 >/dev/null 2>&1; then
  skill="$(printf '%s' "$payload" | python3 -c '
import sys, json
try:
    d = json.load(sys.stdin)
    ti = d.get("tool_input", {}) or {}
    print(ti.get("skill") or ti.get("name") or "")
except Exception:
    print("")
' 2>/dev/null)"
fi
if [ -z "$skill" ]; then
  skill="$(printf '%s' "$payload" | grep -oE '"skill"[[:space:]]*:[[:space:]]*"[^"]+"' | head -1 | sed -E 's/.*"skill"[[:space:]]*:[[:space:]]*"([^"]+)".*/\1/')"
fi
[ -z "$skill" ] && exit 0

# Is this one of our brains? Match the namespace root before any ':'.
base="${skill%%:*}"
case "$base" in
  website-brain|marketing-brain|local-seo-brain|claude-obsidian|claude-ads|client-intelligence-report) ;;
  *) exit 0 ;;
esac

ts="$(date '+%Y-%m-%dT%H:%M:%S' 2>/dev/null || echo unknown)"
stamp="$(date '+%Y%m%d-%H%M%S' 2>/dev/null || echo run)"
dir="todos"
mkdir -p "$dir" 2>/dev/null || exit 0

safe_skill="$(printf '%s' "$skill" | tr -c 'a-zA-Z0-9' '-')"
file="$dir/${stamp}-${safe_skill}.md"

# Avoid duplicate spam: if an open todo for this skill was created this minute, skip.
[ -e "$file" ] && exit 0

cat > "$file" <<EOF
---
status: open
priority: normal
skill: $skill
created: $ts
source: master-brain auto-capture
---

# Follow up: \`$skill\` run

A \`$skill\` brain run happened at $ts. master-brain captured this so the work
gets reviewed and closed out.

- [ ] Review what \`$skill\` produced (vault notes, report, audit, data)
- [ ] Capture concrete next actions below
- [ ] Set \`status: done\` when complete

## Next actions
_(fill in)_
EOF

exit 0
