---
name: jp-lp
description: >
  日本市場向けランディングページ（LP）の設計・レビュー・改善。実測データに基づく
  日本固有の型、日本語コピーの規範、和文タイポグラフィの実務値、そして景品表示法・
  薬機法・特定商取引法・医療広告ガイドライン・ステマ規制・各広告媒体の審査要件を
  1つの運用手順にまとめたもの。Use when designing, writing, reviewing, or auditing a
  Japanese-market landing page. Triggers on: 日本のLP、LP制作、ランディングページ、
  縦長LP、単品通販LP、記事LP、ファーストビュー、FV、CVR改善、LPO、薬機法チェック、
  景表法チェック、No.1表記、定期購入LP、医療広告、資料請求LP、"Japanese landing page",
  "LP for Japan", "JP market landing page".
version: 1.0.0
license: MIT
metadata:
  author: master-brain
  category: marketing
  market: JP
  researched: 2026-08-05
---

# jp-lp：日本市場LPの設計と監査

英語圏のLP論をそのまま日本市場に適用すると外す。このスキルは、2026年8月に実施した
実測調査（実物LP 300件超をヘッドレスブラウザで開いて計測、官公庁一次資料を条文まで
照合）から、**日本市場で再現性のある型と、踏むと事業が止まる法的地雷**だけを残したもの。

汎用の `landing-page-optimization` スキル（英語・欧米SaaS前提）と**併用する**。
構造原則はあちらが強く、日本市場固有の分岐はこちらが持つ。矛盾したらこちらを優先する。

## 0. すべての判断に先立つ分岐：装飾濃度をどこに置くか

日本のLPの装飾濃度は**連続的に分布する**。位置を決めるのは業種ではなく、次の3つ。
**設計に入る前にこの3つを確定させる。「日本のLPの型」という単一の答えを探さない。**

1. **誰が作るのか。** ブランド本体の公式LPか、獲得目的のDR案件か。
   実測で大手化粧品ブランドの公式LP（アスタリフト、アテニア、ディセンシア、ライスパワー、
   オルビス本体）は赤字も吹き出しも比較表も**ゼロ**。同じ化粧品でもDR側（CAC、KATAN、
   インナーシグナル、アースケア）は濃い。**業種ではなく制作主体で割れる。**
2. **どの制作基盤を使うのか。** 記事LP特化SaaS（Squad beyond 等）を使うと、
   そのベンダーの処方（太字＋マーカー、吹き出し多用）がそのまま出る。**装飾はツールに従属する。**
3. **どの面に配信するのか。** Metaフィードに割り込むのか、検索で答えを返すのか。
   → [`references/ad-delivery-fit.md`](references/ad-delivery-fit.md)

> **2026-08-06 改訂。** 初版はここを「統計的に別物の2母集団に分かれる」と書いていたが、
> 反証調査で**支えられない**と判明した。サンプリング枠が重なっており（LPアーカイブは
> 公式に広告LPを集めている）、測定手法も非対称で、業種構成の交絡もある。
> 数値は [`references/two-populations.md`](references/two-populations.md) に残してあるが、
> **境界のある2集団としては扱わないこと。**

判断に迷ったら「このLPは広告費を払って人を連れてくるのか」を聞く。YESなら装飾は濃い側に寄る。

## 1. 既定値（実測の中央値。ここから始めて、理由があるときだけ外す）

| 項目 | 既定値 | 母数 |
|---|---|---|
| ページの縦の長さ | 非常に長い（モバイル10,000px超） | 74.5%から80.9% |
| ページ内CTA回数 | 中央値7回（5回以上が76.1%） | n=46 |
| 本文 line-height | **1.70**（下限1.6・上限1.8） | n=40、文字数加重 |
| 見出し line-height | **1.5**（本文より必ず詰める） | n=443見出し |
| モバイル主CTA | 幅328px（画面の84%）・高さ62px・ラベル15px | n=31 |
| CTA角丸 | 0px が最頻 | 13/31 |
| 追従CTAバー高さ | 中央値83px・幅100% | n=11 |
| BtoB資料DLフォーム | 7から8項目 | 実測 |
| BtoBデモ・トライアル | 11から12項目 | 実測 |

**固定追従CTAは「必須」ではない。** 測定法と標本で5%から87%までばらける。記事LPでは
17件中0件。医療系では7件中6件。母集団と業種で決めること。詳細は
[`references/mobile-form-line.md`](references/mobile-form-line.md)。

## 2. 法規制ゲート（コピーを書く前に通す）

日本のLPは**規制がクリエイティブの上流にある**。後から直すと全部書き直しになる。

先に確定させる4点：

1. **商材の法域**：化粧品か医薬部外品か健康食品か機能性表示食品か医療か金融か不動産か
   人材か。ここで書ける言葉の上限が決まる。
2. **定期購入か単発か**：定期なら特商法12条の6（最終確認画面）が独立の義務として乗る。
   「LPに書いたから最終確認画面では省略」は通らない。
3. **第三者の声を使うか**：使うならステマ告示の明瞭表示が要る。**自社LPも例外ではない。**
   医療なら体験談は限定解除しても使えない。
4. **数値・No.1を出すか**：出すなら15日以内に根拠資料を提出できる体制が要る（不実証広告規制）。

**2024年10月1日以降、優良誤認・有利誤認には直罰（100万円以下の罰金、両罰規定あり）がある。**
「行政指導で済む」という前提でリスクを見積もらないこと。

全チェックリスト（A景表法／B特商法／C薬機・食品／D医療／E個人情報・トラッキング／F業種別）：
[`references/legal.md`](references/legal.md)

## 3. 参照ファイル

| ファイル | 中身 |
|---|---|
| [`references/two-populations.md`](references/two-populations.md) | 装飾濃度が何で決まるか、全タリーと交絡、記事LPの構造、業種別の濃度 |
| [`references/ad-delivery-fit.md`](references/ad-delivery-fit.md) | **Google / Meta の配信構造に合わせるLP設計。** P-MAXの最終ページURL拡張、学習期とLP、Advantage+ とFVの名乗り方、個人的属性ポリシーの直し方、インスタントフォーム vs LPフォーム、計測のLP実装要件、2媒体併用 |
| [`references/structure.md`](references/structure.md) | ブロック順序の型（単品通販／BtoB SaaS／医療／教育／高額商材） |
| [`references/first-view.md`](references/first-view.md) | FVの5類型、情報密度、画像焼き込み問題 |
| [`references/copy-ja.md`](references/copy-ja.md) | 日本語コピーの型、CTA文言、マイクロコピー、表記規範 |
| [`references/design-tokens.md`](references/design-tokens.md) | 和文タイポ、CTA寸法、配色、アクセシビリティ、使わない技術 |
| [`references/mobile-form-line.md`](references/mobile-form-line.md) | 追従CTA、EFO、LINE導線と計測、決済、表示速度 |
| [`references/legal.md`](references/legal.md) | 公開前チェックリスト（条文・公式URL付き） |
| [`references/ad-platforms.md`](references/ad-platforms.md) | Google／Meta／Yahoo!／LINE／TikTok の遷移先要件 |
| [`references/measurement.md`](references/measurement.md) | CVRベンチマークの限界、ABテストが成立する条件、計測設計 |
| [`references/evidence.md`](references/evidence.md) | カバレッジ、出典台帳、**未解決・要検証の一覧** |

## 4. 作るとき（新規LP）

1. **装飾濃度の位置を決める**（§0）。誰が作るか、どの基盤か、どの面か。
2. **配信の算数を先に確認する。** `月間予算 ÷ 許容CPA < 30` なら、LPを分ける前に中間CVを足す
   （Google公式のスマート自動入札は月30件以上を推奨）。
   → [`references/ad-delivery-fit.md`](references/ad-delivery-fit.md)
3. **法域を確定し、書ける言葉の上限を先に出す**（§2 → `references/legal.md`）。
4. **オファーを決める**。高額・長期検討型では即決CTAを置かない。実測した注文住宅16サイトで
   即決CTAは**ゼロ件**。中間CV（資料請求／来場予約／オンライン相談）を主CTAにする。
   **オファーの重さは温度より単価が上位制約。**
5. **ブロック順序を選ぶ**（`references/structure.md`）。既存の型から始める。
6. **FVを設計する**（`references/first-view.md`）。**Google側は「答えから始める」、
   Meta側は「場面・問題提起から始める」。1枚で兼用するとFVの同じ場所を奪い合う。**
7. **コピーを書く**（`references/copy-ja.md`）。見出しは常体・体言止め、本文は敬体。
   **Meta配信なら「あなたも◯◯でお悩みでは？」型を書き換える**（消すのは "other" 相当語と
   二人称疑問形。属性の帰属先をサービス側へ移せば訴求は残せる）。
8. **実装する**（`references/design-tokens.md` の実務値、`references/mobile-form-line.md` のフォーム）。
   **計測のLP実装要件は `references/ad-delivery-fit.md`**（サンクスページのDOM、
   `gclid`/`gbraid`/`wbraid` のhidden、`event_id` の採番）。
9. **公開前チェックリストを通す**（[`templates/prelaunch-checklist.md`](templates/prelaunch-checklist.md)）。

ブリーフの雛形：[`templates/lp-brief.md`](templates/lp-brief.md)

## 5. 監査するとき（既存LP）

必ず**モバイル実機（幅390px、JS実行後）**で見る。HTMLのテキスト検索だけで判定しない。
日本のLPは価格・CTA・打消し表示を**画像に焼き込む**慣行が強く、実測30件中13件（43%）が
FV内に生テキストを2ブロック以下しか持たなかった（欧米16件では0件）。テキスト検索での
「記載なし」は「存在しない」を意味しない。

```bash
# 実機で開いて計測する（Playwright MCP か下記のような直接計測）
# document.body.scrollHeight / position:fixed の可視要素 / 入力欄数 / <table>数
# 加えて全ページのスクリーンショットを撮り、装飾は目視で判定する
```

見る順：(1) 法規制ゲート（§2）→ (2) 母集団の一貫性（§0）→ (3) FV → (4) オファーと中間CV →
(5) フォーム項目数 → (6) 追従CTAと反復CTA → (7) タイポと打消し表示の文字サイズ →
(8) 媒体ポリシー適合（`references/ad-platforms.md`）。

**打消し表示・注釈を他の文字より小さく置くのは、それ自体が景表法上の論点。** 実測では
14px未満のテキストを持つLPが37/42（88%）あり、ここが最大の実務ギャップだった。

## 6. 改善するとき

**まず、そのLPでABテストが成立するかを確認する。** CVR1%で20%の改善を検出するには
片群約4.3万セッションが必要。月間CV30件以下では統計的に成立しない。成立しないなら
テストではなく、逐次的な大胆変更＋マイクロCV＋定性調査に切り替える。

成立する場合でも、**期間は最低2週間**（曜日効果）、**ピーキング禁止**（毎日p値を覗いて
有意になった時点で止める運用は偽陽性率を5%から最大26%に押し上げる）。

そして**LP内のどの微修正より先に、広告とLPのメッセージマッチを潰す。**

詳細と国内事例50件の一覧：[`references/measurement.md`](references/measurement.md)

## 7. この調査の限界（成果物に書くときは必ず添える）

- **CVRのデータは持っていない。** 測ったのは出現率だけ。出現率の高さは「その業界で慣行として
  定着している」ことしか意味しない。「装飾が濃い＝効く」と読まないこと。
- **日本市場の業種別CVRベンチマークは、出典付きのものが1件しか存在しない**（Ptengine、
  母数は各業界30程度）。しかもその1件にも内部矛盾がある。数値を引くときは制約を併記する。
- 広告配信型の標本はMeta広告ライブラリ由来で、**Google／Yahoo!／LINE／TikTok の遷移先は
  未確認**。出稿量の多い広告主に寄っている。
- 法規制は**法的助言ではない**。個別案件の適法性は表示全体・商品特性・取引実態で変わる。
  未確定事項は `references/evidence.md` に「要専門家確認」として列挙してある。

出力を納品物にする前に、master-brain の配信規則どおり `/slop-review` → `/slop-rewrite` →
`/slop-verify`（実体・出典の検証）→ `/humanizer` を通すこと。

## 8. PDFレポートを出す

日本語A4レポートの組版一式を同梱している。明朝本文＋ゴシック見出し、和文向けの行間。

```bash
SKILL_DIR="$(dirname "$0")"   # または skills/jp-lp
bash "$SKILL_DIR/scripts/render-ja.sh" check                    # ツールチェーン確認
bash "$SKILL_DIR/scripts/render-ja.sh" all report.html out.pdf  # 描画＋全ページPNG化
```

HTML側で `assets/report-ja.css` を読み込む。`.cover` `.note` `.warn` `.key` `.src` `.toc`
クラスが使える。**PNG化した全ページを必ず目視すること。** 豆腐（□）、はみ出し、空白ページ、
表の切れを1ページずつ見る。見ずに完了と言わない。
