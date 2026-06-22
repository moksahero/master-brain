# Vendored: humanizer

This skill is **vendored** from an upstream project. Do not hand-edit `SKILL.md`
here — edits should land upstream and be re-pulled, so all PCs stay in sync.

- **Upstream:** https://github.com/blader/humanizer (`git@github.com:blader/humanizer.git`)
- **Vendored commit:** `9600f2b7241cb4eed6ad803abee5ea01d67fe8e4` (2026-06-07)
- **Vendored skill version:** `2.8.0`
- **License:** MIT (see `LICENSE`)

## Why it's here

master-brain ships humanizer so every PC that runs `claude plugin update` gets it
as `mb:humanizer`, and `/mb:install` also clones it standalone to
`~/.claude/skills/humanizer` so the short `/humanizer` command works too.

## How master-brain uses it

The humanizer is a **standing rule**, not just an on-demand command: master-brain's
SessionStart hook reminds the agent to pass any prose it produces (marketing copy,
reports, emails, blog drafts, deliverables) through the humanizer patterns before
delivering. See the repo README's "Humanizer" section.

## Re-syncing after an upstream change

```bash
tmp=$(mktemp -d) && git clone --depth 1 git@github.com:blader/humanizer.git "$tmp"
cp "$tmp/SKILL.md" "$tmp/LICENSE" skills/humanizer/
# update the commit hash + version above, bump the mb plugin version, then:
#   git commit && claude plugin update
```
