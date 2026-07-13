# Google Ads Ledger — per-client experiment log (append-only)

Raw training data for the ads-google learning loop. Every action gets an entry
with a falsifiable hypothesis and a check-on date; every due entry gets its
outcome filled with real numbers. Distilled patterns get promoted to
`google-ads-playbook.md` — never edit old entries except to fill `Outcome:`.

**Entry format**
```
### YYYY-MM-DD | client (CID) | campaign/scope
- Phase: launch-check | learning dN | optimize | mature
- Action: what was changed (or QUEUED: proposed change awaiting unlock date)
- Hypothesis: what we expect, in a measurable form
- Check-on: YYYY-MM-DD
- Outcome: (pending) → filled with actual numbers when due
```

---

## (client) / (name) (___-___-____)

### YYYY-MM-DD | client | baseline
- Phase: (establish from change history)
- Action: none — registered into the client registry. Next run: pull campaign
  inventory and establish phase.
- Hypothesis: —
- Check-on: (next scheduled run)
- Outcome: (pending)
