---
description: 日本市場向けLPの設計・執筆・監査。実測データに基づく型と、景表法・薬機法・特商法・医療広告・媒体審査のゲートを一度に通す。
argument-hint: "[design|write|audit|legal] <URL または 商材名> [業種]"
---

Read the `jp-lp` skill (under this plugin's `skills/jp-lp/`) and run it for `$ARGUMENTS`.

このスキルは**日本市場専用**。汎用の `landing-page-optimization`（英語・欧米SaaS前提）とは
併用するが、矛盾したら `jp-lp` を優先する。

## モード（`$ARGUMENTS` の第1語。無ければ意図から判断する）

| モード | やること |
|---|---|
| `design` | 新規LPの設計。`templates/lp-brief.md` を埋めてから構成を出す |
| `write` | コピーの執筆。`references/copy-ja.md` の型と表記規範に従う |
| `audit` | 既存LPの監査。**必ずモバイル実機で開く** |
| `legal` | 法規制チェックのみ。`templates/prelaunch-checklist.md` を通す |

## 進め方

1. **母集団を最初に決めさせる**（SKILL.md §0）。ギャラリー掲載型か広告配信型か記事LPか
   1画面完結型か。ここが決まらないと設計言語が混ざる。判断できないときは
   「広告費を払って人を連れてくるのか」を聞く。
2. **法域を確定する**（§2）。化粧品／医薬部外品／健康食品／機能性表示食品／医療／金融／
   不動産／人材のどれか。**ここで書ける言葉の上限が決まるので、コピーを書く前に確定する。**
3. モードに応じて `references/` の該当ファイルを読む。**全部読み込まない**。必要なものだけ。
4. 監査なら実機計測を行う。Playwright MCP が使えるならそれで、幅390px・JS実行後に開く。
   `measurement.md` の「監査で数える指標」を数える。**HTMLのテキスト検索だけで判定しない**
   （日本のLPは価格・CTA・打消し表示を画像に焼き込む。実測30件中13件がFVに生テキスト2ブロック以下）。
5. 出力の前に `templates/prelaunch-checklist.md` を通す。

## 必ず添えること

- **数値には母数を書く。** 「56.3%」ではなく「18/32（56.3%）」。
- **CVRのデータは持っていない。** 出現率は慣行の定着を示すだけで、効果の証拠ではない。
  「装飾が濃い＝効く」と書かない。
- **法規制は法的助言ではない。** 未確定事項は `references/evidence.md` の「未解決」に
  列挙してあるので、該当したら「要専門家確認」と書く。
- **日本市場の業種別CVRベンチマークは出典付きのものが1件しかない**（しかも内部矛盾あり）。
  他社ベンチマークとの比較でLPの良し悪しを判断しない。

## PDFレポートを出す場合

`scripts/render-ja.sh` と `assets/report-ja.css`（明朝本文＋ゴシック見出し、和文向け行間）を使う。

```bash
bash skills/jp-lp/scripts/render-ja.sh check
bash skills/jp-lp/scripts/render-ja.sh all report.html out.pdf
```

**PNG化した全ページを必ず目視する。** 豆腐（□）、はみ出し、空白ページ、表の切れを1ページずつ。
見ずに完了と言わない。

## 納品の前に

master-brain の配信規則どおり、`/slop-review` → `/slop-rewrite` → `/slop-verify` →
`/humanizer` を通す。実体・出典の検証（`/slop-verify`）は、この領域では特に重要
（法令名・条番号・URLが多いため）。
