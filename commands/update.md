---
description: Update every installed AI Marketing Hub brain to the latest version.
---

Read the `master-brain` skill. Then update the fleet.

## 1. Update

```bash
SCRIPTS="${CLAUDE_PLUGIN_ROOT:-$HOME/.claude/skills/master-brain}/scripts"
bash "$SCRIPTS/brains.sh" update
```

This fast-forwards every brain that's a git checkout in `~/.claude/skills`. A
brain that has uncommitted local changes (or a non-fast-forward history) will be
reported as a failed pull rather than force-updated — never clobber local work.

## 2. Also refresh claude-mem

If `claude-mem@thedotmack` is installed, update it:

```bash
claude plugin update claude-mem@thedotmack
```

(If the plugin CLI isn't available, note it and skip.)

## 3. Report what changed

Run `bash "$SCRIPTS/brains.sh" status` and show the table. Call out any brain
that failed to update and why (local changes, not a git checkout, missing), with
the one-line fix. If a brain was behind and is now current, say so with the new
version. End with a one-line "fleet is current" or a list of what needs manual
attention.
