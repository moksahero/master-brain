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

## 2. Also refresh claude-mem

If `claude-mem@thedotmack` is installed, update it:

```bash
claude plugin update claude-mem@thedotmack
```

(If the plugin CLI isn't available, note it and skip.)

## 3. Report what changed

Run `bash "$SCRIPTS/brains.sh" status` and show the table. Call out:

- Any **newly discovered brain** that was just cloned into the fleet (name it and
  say where it came from — "new in the org").
- Any brain that **failed to update** and why (local changes, not a git checkout,
  missing), with the one-line fix.
- Any brain that was **behind and is now current**, with the new version.

End with a one-line "fleet is current" or a list of what needs manual attention.
