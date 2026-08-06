# 広告媒体別のLP要件

LPは広告の遷移先。媒体ポリシーに落ちると何も始まらない。公式ドキュメント29件を実地取得。
参照日 2026-08-05。

## 大前提：審査対象はLP本体

Google は「このポリシーは広告およびウェブサイトやアプリのコンテンツに適用されます」
「広告およびリンク先に対しても適切な法律と業界標準を遵守することを求めています」と明記。
LINE広告も審査対象に「ランディングページ、リンク先URL」を含む。

**LPを直すまで広告は回らない。**

## フッターに置くもの

| 項目 | 根拠 | 必須性 |
|---|---|---|
| 特定商取引法に基づく表記 | 特商法11条（通信販売） | 通販なら必須 |
| プライバシーポリシー | 個人情報保護法 | フォームがあるなら必須 |
| 運営者情報（会社概要） | 媒体審査の実務要件 | 事実上必須 |
| 外部送信に関する公表 | 電気通信事業法27条の12 | **条件付き** |

**外部送信の公表は「全媒体共通の入口条件」ではない。** 総務省の本文ページとFAQを確認した結果、
自社商材を売る通常のLPには原則かからない。対象はメディア型・比較サイト型・アフィリエイト収益型。
判定フローは [`legal.md`](legal.md) のE-4節。

## Google 広告

□ **リンク先の要件**：「広告表示を主目的としたリンク先コンテンツ」「複製コンテンツのみ」
「ユーザーをリダイレクト目的とするページ」は不承認。
**アフィリエイト中継ページ、比較サイト風の薄いLPはここで落ちる。**
□ 「価値の低いコンテンツ」ポリシー。独自コンテンツの不足は明示的な不承認理由。
□ **金融サービスの「適格性確認」に日本は入っていない。** 対象国リストは豪州、シンガポール、
台湾、ブラジル、フランス、ドイツ、インド、インドネシア、ポルトガル、スペイン、イタリア、
トルコ、アイルランド、ニュージーランド、韓国、タイ、マレーシア、オーストリア、ベルギー、
デンマーク、フィンランド、ハンガリー、アイスランド、リヒテンシュタイン、ルクセンブルク、
オランダ、ノルウェー、スウェーデン、英国。**日本は未収載。**
日本の金融系LPで効くのは媒体の認証ではなく金商法・貸金業法側の規制。

https://support.google.com/adspolicy/answer/6008942?hl=ja
https://support.google.com/adspolicy/answer/6368661?hl=ja
https://support.google.com/adspolicy/answer/12390454?hl=ja

## Meta（Facebook / Instagram）

### 個人的属性ルールが日本語コピーを直撃する

Meta は「Ads must not contain content that asserts or implies personal attributes」とし、
公式のNG例に「Are you gay?」「Do you have diabetes?」「Meet other seniors」「Are you bankrupt?」
を挙げる。

**日本語広告で多用される次の構文がそのまま該当する：**

- 「あなたも◯◯でお悩みではありませんか？」
- 「◯◯世代のあなたへ」
- 「他の◯◯の方も使っています」

**属性を主語にせず、商品・サービスの便益を主語にする。**

これは日本のLP文化と正面衝突する。広告配信型LPのFV最頻型が「不安・悩み訴求」（45.5%）で
あることを踏まえると、**訴求の型そのものを媒体に合わせて書き分ける必要がある。**

https://transparency.meta.com/policies/ad-standards/objectionable-content/privacy-violations-personal-attributes/

### ビフォーアフターは全面禁止ではない

2026-07-22更新の Health and Wellness ポリシーは、**許可側**に
「General cosmetic products, procedures, surgeries depicting before and after transformation.」を明記。

**禁止されているのは：**
- 「Contains statements of inferiority about physical appearance」（外見の劣等性の断定）
- 「Close up on specific body area by pinching fat」（脂肪をつまむクローズアップ）
- 「Claims that results can be achieved solely by using wearable products」

**ただし媒体ポリシー上は可でも、日本では薬機法・医療広告ガイドライン側で別途規制される。**
化粧品のビフォーアフターは適正広告基準で原則不可、医療は症例1件ごとの併記が必要。
**二重に確認すること。**

https://transparency.meta.com/policies/ad-standards/restricted-goods-services/health-wellness/

## Yahoo! 広告

**未確認。** 本調査では `ads-help.yahoo.co.jp` がDNS解決不可、代替ドメイン
`ads-help.yahoo-net.jp` はSPAで本文を取得できなかった。URLと記事名のみ記録し、
内容は憶測で補完していない。

**到達可能な環境から再取得すべき最優先の積み残し。** 日本市場では無視できない媒体で、
健康食品・美容・医療の審査基準や必要書類の提出要件が独自にある。

## LINE 広告

□ 審査対象に**ランディングページ、リンク先URL**を含む。
□ **「在庫わずか」等の急かし表現を明示的に否認している。** 日本のLPで多用される限定・緊急性演出は
LINE広告では通らない可能性が高い。

https://www.lycbiz.com/jp/service/line-ads/review/

## TikTok 広告

□ **日本は「言語・通貨が信頼ベースではなく厳格執行」の指定市場。** 公式ポリシーは
「For Japan, acceptance/relevance of language, currency and other elements of ad content and
landing page are enforced.」とし、日本向けは**日本語必須**。
□ 日本を含む一部市場で「Ad content with QR codes leading to third-party websites」が禁止。
**LP内の第三者サイト誘導QRは要注意。**
□ 「Landing pages with insufficient original content or having a high ratio of ads relative to
original content」は不承認理由。
□ 現地通貨価格と営業許可証まで要求される場合がある。

https://ads.tiktok.com/help/article/tiktok-ads-policy-ad-format-and-functionality

## 計測タグと同意

### Consent Mode v2 は日本では必須ではない

Google の該当ヘルプは「欧州経済領域（EEA）のエンドユーザーからデータを取得しているお客様を
対象としています」と対象を限定しており、日本への言及はない。

**日本で必須なのは電気通信事業法の外部送信規律**（ただし上記のとおり自社商材LPには原則
かからない）。**欧州向けのCookieバナーを流用しても日本の要件は満たせないし、
日本で必要とも限らない。** 両者は別制度。

https://support.google.com/google-ads/answer/13695607?hl=ja

### 実勢

保存134ファイル中、GTMは112件検出に対し**CMPはわずか4件**。タグは入れてもCMPは入っていないのが
日本のBtoBサイトの実勢。

## 媒体別にLPを作り分けるのが実勢

実測した広告配信型LPのURLには配信面識別子が入っている：
`_facebook`、`_fb`、`meta`、`asc`（Advantage+ Shopping Campaign）。

例：`ej_1st_kiji_facebook`、`aojiruplus_article001_fb`、`hizatect-meta-notadnw`、
`orbd-f2-03q-fk005`。

**同じ商材でも媒体ごとに別LPを用意している。** ポリシーが違い、訴求の型が違い、
オーディエンスの温度が違うため。1本のLPを全媒体に流すのは、実勢から外れている。

## 審査落ちしたときの確認順

1. LPのフッター4点（該当するものが揃っているか）
2. LP本文の断定表現・効果効能（薬機法・景表法側）
3. Meta なら個人的属性構文
4. 独自コンテンツの量（中継ページ・薄い比較ページになっていないか）
5. 業種別の追加要件（金融・医療・美容）
6. LP内のリンク先・QRコードの遷移先
