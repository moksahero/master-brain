---
description: Update every installed AI Marketing Hub brain to the latest version.
---

Read the `master-brain` skill. Then update the fleet.

## 1. Discover + update

```bash
SCRIPTS="${CLAUDE_PLUGIN_ROOT:-$HOME/.claude/skills/master-brain}/scripts"
bash "$SCRIPTS/brains.sh" update
```

When the `gh` CLI is installed and authenticated, this **walks the entire
`AI-Marketing-Hub` org** and resolves the fleet dynamically: the canonical brains
first, then any other brain that's been added to the org (e.g. `social-hub`). So
a newly published brain joins the fleet automatically — no edit to `brains.sh`.
Discovery includes both Claude plugins and Obsidian-brain vaults, and excludes
Codex-runtime variants (`codex-*`) and non-skill infra (`.github`,
`classroom-assets`, `marketing-os`, `member-workflows`). Without `gh`, it falls
back to the built-in canonical list and says so.

It then fast-forwards every brain that's a git checkout in `~/.claude/skills` and
clones any newly discovered brain that isn't present yet. A brain with
uncommitted local changes (or a non-fast-forward history) is reported as a failed
pull rather than force-updated — never clobber local work.

To preview what discovery would add before updating, run:

```bash
bash "$SCRIPTS/brains.sh" discover   # prints org brains not in the canonical list
```

(If `gh` is missing or not logged in, that's fine — note it and continue; the
update still runs against the canonical list. Suggest `gh auth login` so future
updates auto-pick-up new org brains.)

This updates the **system-wide** brain fleet under `~/.claude/skills` (the
`brains.sh` banner prints the exact target dir — it is `$HOME/.claude/skills`
unless `CLAUDE_SKILLS_DIR` is set, never the current project). Brains load from
there for *every* project, so this step is global, not per-project. Call out the
resolved path in the report so the scope is unambiguous.

## 2. Sync this project's CLAUDE.md managed section (current directory only)

The brain *code* is global, but the **Persistence conventions** live in each
project's `CLAUDE.md`. Projects scaffolded before that rule existed never got it.
Retrofit/refresh it for the current project — and only the current project:

```bash
SCRIPTS="${CLAUDE_PLUGIN_ROOT:-$HOME/.claude/skills/master-brain}/scripts"
bash "$SCRIPTS/claude-md.sh" sync .
```

This reconciles only the block between the `<!-- mb:managed:start -->` /
`<!-- mb:managed:end -->` markers to the canonical text — adding it if absent,
refreshing it if stale, leaving it untouched if current. Everything outside the
markers (project name, focus, market, active brains, API-key status, report
language) is project-owned and never modified. If there's no `CLAUDE.md` here,
it skips with a note (this isn't an `/mb:init` project). Report add / refresh /
no-change / skip.

## 3. Also refresh the plugin brains (claude-ads + claude-mem)

These ship as plugins, not `skills/` clones, so `brains.sh` doesn't touch them.
Update whichever is installed:

```bash
claude plugin update claude-ads@ai-marketing-hub-claude-ads
claude plugin update claude-mem@thedotmack
```

(If the plugin CLI isn't available, or a plugin isn't installed, note it and skip.)

## 4. Report what changed

Run `bash "$SCRIPTS/brains.sh" status` and show the table. State the resolved
**install path** (`~/.claude/skills`) up front so it's clear the brain update was
system-wide, then call out:

- Any **newly discovered brain** that was just cloned into the fleet (name it and
  say where it came from — "new in the org").
- Any brain that **failed to update** and why (local changes, not a git checkout,
  missing), with the one-line fix.
- Any brain that was **behind and is now current**, with the new version.
- The **CLAUDE.md managed-section** result for this project (added / refreshed /
  no-change / skipped) from step 2 — so it's clear that part was per-project.

Make the two scopes explicit so they're never confused: brain code = **system-wide**
(`~/.claude/skills`); the Persistence block = **this project only** (`./CLAUDE.md`).

End with a one-line "fleet is current" or a list of what needs manual attention.
