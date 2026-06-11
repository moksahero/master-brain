#!/usr/bin/env bash
# Master Brain hook — insert a TODO into D1 from the command line.
# Usage:
#   ./add-todo.sh "Title" <one_time|routine> [brain] [priority] [body] [due_date] [frequency]
# Examples:
#   ./add-todo.sh "Review marketing-brain output" one_time marketing-brain high "Check vault notes"
#   ./add-todo.sh "Weekly search-terms review" routine claude-ads high "" "" 1w
# kind is REQUIRED: every TODO must be explicitly One Time (one_time) or Routine (routine).
# frequency is REQUIRED for routine (Nd|Nw|Nm, e.g. 1w, 2w, 1m); it is ignored for one_time.
# Due date: auto-defaults by priority (high=+3d, normal=+7d, low=+14d) unless an
# explicit YYYY-MM-DD is passed as the 6th arg.
set -euo pipefail

TITLE="${1:?title required}"
KIND="${2:?kind required: must be one_time or routine}"
BRAIN="${3:-}"
PRIORITY="${4:-normal}"
BODY="${5:-}"
DUE="${6:-}"
FREQ="${7:-}"
ID="$(date +%Y%m%d-%H%M%S)"

# Enforce: every TODO is explicitly classified as one_time or routine.
case "$KIND" in
  one_time)
    FREQ="" ;;  # one-time items have no cadence
  routine)
    if ! printf "%s" "$FREQ" | grep -Eq '^[0-9]+[dwm]$'; then
      echo "routine TODOs require a frequency as Nd|Nw|Nm (e.g. 1w, 2w, 1m); got '$FREQ'" >&2
      exit 1
    fi ;;
  *)
    echo "kind must be 'one_time' or 'routine' (got '$KIND')" >&2; exit 1 ;;
esac

# Escape single quotes for SQL.
esc() { printf "%s" "$1" | sed "s/'/''/g"; }

# frequency: NULL for one_time, quoted value for routine.
if [ -n "$FREQ" ]; then FREQ_SQL="'$(esc "$FREQ")'"; else FREQ_SQL="NULL"; fi

# Default due date by priority unless one was passed.
case "$PRIORITY" in
  high) OFFSET='+3 days' ;;
  low)  OFFSET='+14 days' ;;
  *)    OFFSET='+7 days' ;;
esac
if [ -n "$DUE" ]; then
  DUE_SQL="'$(esc "$DUE")'"
else
  DUE_SQL="date('now','$OFFSET')"
fi

SQL="INSERT INTO todos (id, title, brain, status, priority, body, source, kind, frequency, due_date)
VALUES ('$(esc "$ID")', '$(esc "$TITLE")', '$(esc "$BRAIN")', 'open', '$(esc "$PRIORITY")', '$(esc "$BODY")', 'master-brain auto-capture', '$(esc "$KIND")', $FREQ_SQL, $DUE_SQL);"

# Resolve wrangler: prefer global, fall back to the project-local copy via npx.
if command -v wrangler >/dev/null 2>&1; then WR=(wrangler); else WR=(npx --no-install wrangler); fi

"${WR[@]}" d1 execute nitokyo-todos --remote --command "$SQL"
echo "Inserted TODO $ID (due ${DUE:-auto by priority})"
