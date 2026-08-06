# カバレッジ・出典・未解決事項

調査実施日：2026-08-05。14レーンを並行実行し、各レーンが独立に一次情報を取得した。

## 「1000件」の内訳を正直に書く

**1,000本のLPを1本ずつ描画して個別検証したわけではない。** 実際にやったことは次の3層。
提案資料や納品物で引用するときは、この区別をそのまま書くこと。

| 層 | 意味 | 規模 |
|---|---|---|
| **A. 実機で開いて1件ずつ計測** | Chromium／WebFetch で開き、構造・要素・寸法を記録 | **約890ページ**（下表） |
| **B. 一覧で件数をタリー** | ギャラリーの掲載件数・カテゴリ別件数を転記 | LP archive 46,006件のスタイルタグ全件、医療系562枠、各ギャラリー総数 |
| **C. 一次資料・事例** | 官公庁PDF・法令原文XML・媒体公式・調査レポート・ABテスト事例 | 官公庁一次資料 34件＋媒体公式 29件＋事例 50件ほか |

**層Bは「開いた」ではなく「数えた」。** 母集団の規模感を示すためのもので、個別の構造は見ていない。

### 層A の内訳（レーン別）

| レーン | 開いたページ | うち個別LPの実物確認 | 手法 |
|---|---|---|---|
| 美容・健康D2C | 157 | 81 | WebFetch |
| クリニック・医療 | 62 | 46 | WebFetch＋官公庁PDF全文抽出 |
| BtoB SaaS・士業 | 187（試行289） | 31製品 | HTTP直接取得＋フォーム定義API |
| 教育・人材 | 127 | 93 | WebFetch |
| 住宅・保険・金融 | 168（正常117） | 79 | WebFetch＋PDF全文抽出 |
| ギャラリー横断タリー | 60 | 49 | WebFetch |
| FV・CVR | 57 | 55（日本39＋海外16） | ヘッドレスChromium 390x844 |
| モバイル・LINE・EFO | 43 | 31（描画成功） | Playwright computed style |
| デザイン・タイポ | 155 | 78（描画成功） | Playwright 実描画 |
| 日本語コピー | 35 | 33 | WebFetch |
| 広告配信型DR | 55 | 55 | Chromium実機＋全ページ目視 |

**重複を含む。** 同一LPが複数レーンで開かれている可能性がある（名寄せはしていない）。

## 手法上の限界（結論の読み方を変えるもの）

1. **HTMLテキスト検索では日本のLPは測れない。** 価格・CTA・打消し表示を画像に焼き込む慣行が
   強く、実測30件中13件（43%）がFV内に生テキストを2ブロック以下しか持たなかった。
   **テキスト検索での「記載なし」は「存在しない」を意味しない。**
   ギャラリー横断タリー（WebFetchベース）の装飾出現率は**下振れしている可能性がある。**
2. **固定追従CTAの出現率は測定法で5%から87%まで割れる。** 定義（下部バーのみか上部ヘッダーを
   含むか）と標本（ギャラリー掲載か広告配信か大手指名か）の差。単一の全国値は出せない。
3. **CVRのデータは一切ない。** 測ったのは出現率だけ。**「装飾が濃い＝効く」と読まないこと。**
4. **広告配信型の標本はMeta広告ライブラリ由来。** Google透明性センター、Yahoo!、LINE、TikTok の
   遷移先は**未確認**。出稿量の多い広告主に寄っている。クエリも9本のみで、BtoB・保険・自動車・
   住宅は入っていない。
5. **日本とアメリカのFV比較は統制されていない。** 日本＝広告専用LP、欧米＝トップページという
   非対称、地域配信の汚染、Cookieバナーの遮蔽。方向性は言えるが倍率は断定できない。

## ツール制約（この調査で起きたこと）

- **Perplexity API は全レーンで使用不能だった**（HTTP 401 `insufficient_quota`）。
  ユーザー指定のツールだったが、代替として WebFetch・HTTP直接取得・e-Gov法令API・
  ヘッドレスブラウザ・pdftotext を使った。**法規制と媒体ポリシーの領域では、要約サービスより
  一次資料の直接取得のほうが証拠として強いため、実質的な品質低下は生じていない。**
- **WebSearch はセッション上限（200回）に到達**し、後半のレーンでは使用できなかった。
- 一部の官公庁ページが Shift-JIS 配信・SPA・403 で取得できず、「未確認」として記録した。

## 未解決・要検証（憶測で埋めていない項目）

納品物でこれらに触れるときは、そのまま「要確認」と書くこと。

### 法規制

1. **オープン懸賞の現行の上限額の有無**。総付・一般懸賞・共同懸賞は確認できたが、オープン懸賞の
   現行の取扱いを直接示す公式ページに到達できていない。
2. **薬機法課徴金制度の施行日**。令和元年12月4日公布の改正で導入までは確認済み。施行日
   （令和3年8月1日とされる）を官公庁資料上で直接確認できていない。
3. **医薬部外品の効能効果の範囲の最新一覧**。化粧品56項目は確認済み。医薬部外品は未到達。
4. **不動産の表示に関する公正競争規約の条番号**（特定事項の明示義務が第13条か）とおとり広告の条文。
   規約全文PDFの逐条確認が未実施。
5. **弁護士等の業務広告に関する規程の第3条・第4条の条番号と文言**。原文照合が未実施。
   参照候補としていた日弁連PDF（`.../rules/kaiki/kaiki_no_44r.pdf`）は 2026-08-06 の再検証で
   **HTTP 404**（リンク切れ）を確認済み。現行URLを探し直す必要がある。
6. **No.1表示における「出典明示」の形式要件**。報告書は注記の明瞭性と実質的対応を求めているが、
   「調査主体名・調査期間・サンプル数を必ず併記せよ」という形式要件を一覧化した規定は
   見当たらなかった。**要専門家確認。**
7. **特商法11条について、LP本体ではなく「特商法に基づく表記」ページへのリンクで足りるかの解釈。**
8. **医療広告ガイドライン限定解除要件①について、リスティング広告の「遷移先ページ」自体が
   ①を満たさなくなるのか、広告クリエイティブのみが対象なのか。** ガイドライン原文は
   遷移先ページの扱いを明示していない。**要専門家確認。**
9. **機能性表示食品の届出表示を広告（LP）上でどこまで一言一句そのまま表示する義務があるか。**
   食品表示基準の義務表示は容器包装に係るもの。**要専門家確認。**
10. **注文住宅の建築請負に不動産業景品規約が適用されるか。** 適用の有無で来場特典の上限が
    取引価額の10分の2か、10分の1／100万円かに分岐する。**要専門家確認。**
11. **総務省パンフレット p.15 の外部送信規律フローチャート**の最終確認。本文ページとFAQでは
    裏が取れたが、PDF自体は取得タイムアウトで未読。
12. **プログラミングスクールの特定継続的役務提供 非該当**の根拠となる経産省ニュースリリースPDFの原典。

### コピー・表記

13. **PASONA／新PASONA／PASBECONA の一次情報。** 神田昌典公式サイトの書籍ページ実測では
    「新・PASBECONAの法則」と表記されており、二次記事の「新・PASONA」と食い違う。
    AIDMA／AIDA／QUEST／BEAF も出典未確認。
14. **総額表示義務の特例終了日（2021年4月1日）の一次確認。** 財務省URLが404、国税庁の該当ページが
    Shift-JIS配信の空スタブで到達できなかった。二次情報は一致している。
15. **「漢字率3割が読みやすい」説の学術的裏付け。**
16. **一部のキャッチコピー型（「40代からの」型、常識否定型、大学教授監修型）の実物LP引用。**
    LP archive 46,006件に到達したが一覧HTMLから本文を抽出できず、ヘッドレスブラウザでの
    再取得が必要。

### 媒体

17. **Yahoo! 広告のポリシー全般。** `ads-help.yahoo.co.jp` がDNS解決不可、代替ドメインがSPAで
    本文取得不可。**最優先の積み残し。**
18. **Google 透明性センター経由の遷移先LP。** 未着手。
19. **アフィリエイトASPの案件LP。** ログインが必要で到達できていない。

### 計測・デザイン

20. **line-height の和文推奨倍率の一次規格根拠。** W3C JLReq には推奨倍率の明示がないことを
    確認済み。実務値の根拠は実測と二次情報のみ。
21. **CVが少ない環境での代替手法の効果検証。** 提案しているが、国内の定量的裏付けはない。
22. **「オファーの変更が最も効く」の定量的裏付け。** 国内調査は見つからなかった。

## 主要な一次資料（抜粋）

法令原文は e-Gov 法令検索の公開API から XML を取得して条文照合済み。

| 領域 | 出典 |
|---|---|
| 景品表示法 | https://laws.e-gov.go.jp/law/337AC0000000134 |
| 薬機法 | https://laws.e-gov.go.jp/law/335AC0000000145 |
| 健康増進法 | https://laws.e-gov.go.jp/law/414AC0000000103 |
| 医療法 | https://laws.e-gov.go.jp/law/323AC0000000205 |
| 打消し表示まとめ | https://www.caa.go.jp/policies/policy/representation/fair_labeling/pdf/fair_labeling_180607_0004.pdf |
| No.1表示 実態調査報告書（令和6年9月26日） | https://www.caa.go.jp/policies/policy/representation/fair_labeling/survey/assets/representation_cms216_240926_02.pdf |
| ステマ告示 運用基準 | https://www.caa.go.jp/policies/policy/representation/fair_labeling/guideline/assets/representation_cms216_230328_03.pdf |
| 不当な価格表示についての考え方 | https://www.caa.go.jp/policies/policy/representation/fair_labeling/guideline/pdf/100121premiums_35.pdf |
| 改正景表法の概要（令和6年10月1日施行） | https://www.caa.go.jp/policies/policy/representation/fair_labeling/movie_explanation/assets/representation_cms216_240917_02.pdf |
| 医薬品等適正広告基準 | https://www.mhlw.go.jp/file/06-Seisakujouhou-11120000-Iyakushokuhinkyoku/0000179264.pdf |
| 同 解説及び留意事項 | https://www.mhlw.go.jp/file/06-Seisakujouhou-11120000-Iyakushokuhinkyoku/0000179263.pdf |
| 化粧品の効能の範囲（56項目） | https://www.mhlw.go.jp/file/06-Seisakujouhou-11120000-Iyakushokuhinkyoku/kesyouhin_hanni_20111.pdf |
| 医療広告ガイドライン | https://www.mhlw.go.jp/content/10800000/000927804.pdf |
| 医療広告 事例解説書（第5版、令和7年3月） | https://www.mhlw.go.jp/content/001439423.pdf |
| 通信販売の申込み段階における表示ガイドライン | https://www.no-trouble.caa.go.jp/pdf/20220601la02_07.pdf |
| 特定継続的役務提供 | https://www.no-trouble.caa.go.jp/what/continuousservices/ |
| 外部送信規律（総務省） | https://www.soumu.go.jp/main_sosiki/joho_tsusin/d_syohi/gaibusoushin_kiritsu.html |
| 同 FAQ | https://www.soumu.go.jp/main_sosiki/joho_tsusin/d_syohi/gaibusoushin_kiritsu_00002.html |
| 令和7年版 情報通信白書 | https://www.soumu.go.jp/johotsusintokei/whitepaper/ja/r07/html/nd21b120.html |
| WCAG 2.1 コントラスト（日本語の文字サイズ） | https://waic.jp/docs/WCAG21/Understanding/contrast-minimum.html |
| W3C 日本語組版処理の要件 | https://www.w3.org/TR/jlreq/ |
| Google 広告ポリシー | https://support.google.com/adspolicy/answer/6008942?hl=ja |
| Meta 個人的属性 | https://transparency.meta.com/policies/ad-standards/objectionable-content/privacy-violations-personal-attributes/ |
| Meta Health and Wellness | https://transparency.meta.com/policies/ad-standards/restricted-goods-services/health-wellness/ |
| TikTok 広告ポリシー | https://ads.tiktok.com/help/article/tiktok-ads-policy-ad-format-and-functionality |
| LINE広告 審査 | https://www.lycbiz.com/jp/service/line-ads/review/ |
| 国民生活センター 定期縛りなし注意喚起（2025-01-31） | https://www.kokusen.go.jp/news/data/n-20250131_1.html |

各レーンの完全な出典台帳（数百件）は生の調査出力に残っている。必要なら再調査で復元できる。

## この調査を更新するとき

優先度順：

1. **Yahoo! 広告のポリシーを到達可能な環境から取得する**（唯一の主要媒体の空白）
2. **Google／LINE／TikTok の遷移先LPを広告透明性ツールから収集**して、母集団比較を媒体別に拡張
3. **上記の法規制 未解決12件を専門家確認にかける**
4. **CVRデータの取得**。自社案件の実データを蓄積するのが唯一の現実的な道。公開ベンチマークは
   日本市場には存在しない
5. ギャラリー掲載型のタリーを**ヘッドレスブラウザで取り直す**（HTMLベースの下振れを補正）
