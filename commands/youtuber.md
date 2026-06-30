---
description: Operate YouTube Brain — scaffold, ingest, synthesize, report, lint, and guide next actions for a source-cited YouTube creator-growth Obsidian vault.
argument-hint: "new <slug> --owner <name> | ingest --vault <path> --file <src> | synthesize --vault <path> | report --vault <path> | visuals --vault <path> | lint --vault <path> | next --vault <path>"
allowed-tools: Read, Grep, Glob, Bash
---

You are operating **YouTube Brain**, a source-cited Obsidian brain for YouTube
creator growth and strategy.

## 0. Locate the YouTube Brain checkout

This command can run from anywhere, so first resolve the repo root (the checkout
that contains `SKILL.md` + `scripts/scaffold_vault.py`). Run:

```bash
resolve_yt() {
  # 1) explicit override
  if [ -n "${YOUTUBE_BRAIN_DIR:-}" ] && [ -f "$YOUTUBE_BRAIN_DIR/scripts/scaffold_vault.py" ]; then
    echo "$YOUTUBE_BRAIN_DIR"; return 0
  fi
  # 2) current dir / ancestors
  d="$PWD"
  while [ "$d" != "/" ]; do
    [ -f "$d/scripts/scaffold_vault.py" ] && grep -q "name: youtube-brain" "$d/SKILL.md" 2>/dev/null && { echo "$d"; return 0; }
    d="$(dirname "$d")"
  done
  # 3) scan the master-brain project registry
  while IFS= read -r p; do
    [ -f "$p/scripts/scaffold_vault.py" ] && grep -q "name: youtube-brain" "$p/SKILL.md" 2>/dev/null && { echo "$p"; return 0; }
  done < "${MB_PROJECTS_FILE:-$HOME/.claude/master-brain-projects.txt}"
  return 1
}
YT="$(resolve_yt)" && echo "YouTube Brain: $YT" || echo "NOT FOUND"
```

If it prints `NOT FOUND`, tell the user the YouTube Brain repo isn't on this
machine (clone `git@github.com:AgriciDaniel/youtuber.git` or set
`YOUTUBE_BRAIN_DIR`) and stop. Otherwise `cd "$YT"` and run everything below
from there. Read `$YT/SKILL.md` as the authoritative spec.

## Operating rules (always)

1. Before changing notes in a vault, read its `CODEX.md`, `wiki/hot.md`, and
   `wiki/index.md`.
2. Preserve `.raw/` as immutable source material.
3. Never store credentials, OAuth tokens, cookies, or private audience data in
   the vault.
4. No growth/revenue/monetization claim without a dated, official or primary
   source recorded in `references/source-ledger.json`.
5. No sub4sub, bots, engagement bait, or policy-violating tactics.
6. V1 is advisory and read-only — no account mutation or upload automation
   without explicit owner approval and an audit trail.
7. Keep `hot`, `index`, `overview`, and `log` current after any change.

## Runtime

Use `python3` (there may be no `python` alias). Run scripts as
`python3 "$YT/scripts/<name>.py" ...` (or after `cd "$YT"`).

## Subcommand → script mapping

Parse the leading word of `$ARGUMENTS` as the subcommand, then run the matching
script, forwarding the remaining flags:

| Subcommand   | Script                              |
|--------------|-------------------------------------|
| `new`        | `scripts/scaffold_vault.py` (flags: `--client <slug> --owner <name> [--client-name <name>] --out-dir <dir> [--force]`) |
| `ingest`     | `scripts/ingest_source.py --vault <path> --file <src>` |
| `synthesize` | `scripts/synthesize_brain.py --vault <path>` |
| `report`     | `scripts/render_brain_report.py --vault <path>` (add `--html-only` for HTML) |
| `visuals`    | `scripts/generate_vault_visuals.py --vault <path>` |
| `lint`       | `scripts/lint_vault.py --vault <path>` |
| `next`       | `scripts/guide_next_action.py --vault <path>` |
| `audit`      | `scripts/audit_brain.py --json` |

Notes:
- `new` maps `<slug>` to `--client <slug>`. If `--out-dir` is omitted, default
  it to `$YT/vaults` (create it if missing) and tell the user where the vault
  landed.
- If `$ARGUMENTS` is empty, don't guess — run `guide_next_action.py` against the
  most relevant vault if one exists, otherwise summarize the subcommands above
  and ask what they want to do.
- Run `python3 scripts/<name>.py --help` first whenever you're unsure of a
  script's exact flags, then invoke it for real.
- After any script that mutates a vault, report what changed and confirm the
  `hot`/`index`/`log` notes are still coherent.

## Request

Subcommand and flags: **$ARGUMENTS**
