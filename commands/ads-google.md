---
description: Phase-gated Google Ads operator — live GAQL review, small-budget calibration, and a cross-client playbook/ledger training loop. Args — [client|CID] [launch-check|watch|optimize|audit]; client optional when cwd is inside a registered client dir.
---

Read the `ads-google` skill (under this plugin's `skills/ads-google/`) and run
its process end to end for `$ARGUMENTS`:

1. Resolve the ads WORKSPACE (walk up for `shared/findings/google-ads-playbook.md`;
   offer to bootstrap from the skill's `templates/` + `scripts/gads.py` if absent).
2. Resolve the client from the argument or cwd against the registry — confirm
   client + CID in one line; never guess a CID.
3. Step 0 (load playbook + due ledger entries) → pull live data → pick the mode
   by account phase → calibrated evaluation → report Do now / Queued / Watch.
4. Apply changes only in optimize/audit mode, one atomic change-set, re-verify.
5. Step 6 write-back (ledger entry with hypothesis + check-on date, playbook
   promotions, client wiki log). Never skip the write-back.
