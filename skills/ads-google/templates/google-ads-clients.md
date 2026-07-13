# Google Ads Client Registry

One row per client account the `/mb:ads-google` operator manages. The skill
resolves the active client from an explicit argument or by matching the cwd
against **Project dir**; it confirms client + CID before pulling data and
never guesses a CID.

MCC (login-customer-id): `___-___-____` — auth env vars live in
`~/.claude/settings.json` (see the ads-google skill, "Auth & the API helper").

| Client / aliases | CID | Vertical | Daily budget | Target CPC | Project dir | LP URLs / notes |
|---|---|---|---|---|---|---|
| (example) acme / アクメ整体 | 123-456-7890 | 整体 (chiropractic) | ¥1,000 | ¥300 | `acme/` | /lp-koshi, /lp-kata — CV = form + call-tap |

Rules:
- New client → add a row here AND a section in `google-ads-ledger.md`, same run.
- Accounts under different credentials/ownership get their own workspace —
  never mix ledgers across trust boundaries.
