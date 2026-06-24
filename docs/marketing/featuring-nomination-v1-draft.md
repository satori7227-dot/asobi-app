# ASOBI Featuring Nomination v1 draft（2026-06-24 起案）

App Store Connect → Marketing → Featuring Nominations から提出する App Store Editorial 向けの pitch。Apple Developer 承認後すぐ submit する想定で本日骨格完成。Apple のガイドラインは「3 ヶ月前提出」のため iOS 27 GA 2026-09-15 を狙うなら **2026-06-15 までに提出**が望ましい（Apple Developer 承認待ち中の今がぎりぎりの窓）。

## アプリ基本情報

- アプリ名: ASOBI（あそぶ？）
- Bundle ID: com.idogawa.Asobi
- Version: 1.0
- Category: Entertainment
- Age Rating: 17+（Alcohol Frequent/Intense）
- Languages: ja, en
- Developer: Satori Idogawa（個人開発）
- リリース予定: 2026-09-15 前後（iOS 27 GA 同期）

## Submission 種別

- ✅ **Featuring Nomination**（個別作品 pitch・Today / Stories / Apps We Love 候補）
- ☐ Editorial Story（特集記事候補）
- ☐ App of the Day（1 日 1 作・既存掲載作向け）

## 7 軸 pitch（各軸 200-500 字）

### 1. UX / UI

完全オフライン・タップ 3 回で「次のお題」に到達する 5 秒価値設計。13 シーン × 1176 ゲーム × 256 お題を「シーン → 条件 → 提案 3 件」の決定論的ファネルで提示。SwiftUI 17+ ネイティブ、Dynamic Type 300% / VoiceOver 完走対応、Dark Mode 完全対応。スクロールは慣性なしで意思決定速度を優先。Onboarding 3 画面はスキップ可能で、初回起動から 5 秒で「飲み会」「家族の集まり」「カップル」のどれかを選ぶだけ。

### 2. Innovation

iOS 17+ Interactive Widget で「今日のおすすめゲーム」を Home Screen に常時表示。Deep Link `asobi://scene/<id>` で iMessage / LINE から友達同士の招集を 1 タップで実現。v1.1 で App Intents 3 件（StartGameIntent / NextPromptIntent / RandomGameIntent）と Live Activity「現在のお題」を実装予定（SiriKit deprecation 2-3 年窓を踏まえた先行投資）。WWDC26 で発表された Foundation Models multimodal + LanguageModel protocol を用いた on-device お題語彙拡張も v1.1 candidate。

### 3. Uniqueness

横断型 13 シーン × 1176 ゲームの物量は日本市場で唯一無二。競合「どこパ」は 39 ゲームでボードゲーム部門 1 位、ASOBI はその 30 倍の物量で「シーン横断」を実現。海外 80 件の英訳完備で en リリース時もそのまま動く。Apple Family Sharing 対応で「実家の祖父母にも遊んでもらえる」3 世代訴求は他社にない設計。

### 4. Accessibility

Dynamic Type 300% で文字が画面外に流れない設計。VoiceOver でゲーム提案 → ルール読み上げ → 「お気に入りに追加」の動線が完走可能。Reduce Motion 設定時はアニメーションを完全停止。最小タップ領域 44pt 厳守。Color のみで情報を伝えない設計（contrast ratio 4.5:1 以上、`docs/color-audit.html` で全色監査済）。Family Sharing 対応で家族間共有 1 回購入。

### 5. Localization

日本語ネイティブ設計（井戸川聡里個人開発・宮崎在住）。185 keys × ja/en 完全対応（`scripts/xcstrings-lint.py --strict` 通過）。海外向け 80 ゲームの英訳完備、regionBlocklist で文化適合性（イスラム圏 6 ヶ国は飲酒系 6 件を非表示）を実装済み。日本のパーティーゲーム文化（合コン・忘年会・歓送迎会・3 世代家族集合）を一次データに基づいて 13 シーン構造化したのは日本人開発者ならでは。

### 6. Product Page

スクショ 5 枚は「シーン選択 → 状況入力 → 提案 → ゲーム詳細 → ツール」のユーザージャーニーに沿って配置。各スクショに 1 行キャッチコピー（「1191 ゲーム × 13 シーン」「3 つだけ、即決まる」等）。Subtitle・Promotional Text・Description は検索インテント語（合コン・忘年会・同窓会・忘年会・宅飲み・家族）を自然に組み込み済。Promotional Text は季節ごと（11 月忘年会・12 月新年会・3 月歓送迎会）に月次差替え運用。

### 7. Overall Story（pitch 全体・最も重要）

**「個人開発者 1 人が、日本のパーティー文化 1176 件を集めた完全オフラインアプリ」**

宮崎在住の個人開発者・井戸川聡里が、Z 世代「飲み会離れ」言説の反証（Job総研 2024 で 20 代忘年会参加意欲 68.8% は全世代 1 位 2 年連続）を裏付けに、家族・カップル・宅飲み・3 世代家族集まりという「実需はあるのに既存アプリが取りこぼしている層」に向けて 1 年かけて構築。Apple Privacy Nutrition Label「Data Not Collected」を 100% 達成（Tracking false / 第三者 SDK ゼロ / iCloud バックアップのみ）。広告ゼロ・無料・完全オフライン・後付けペイウォール永続禁止の誓約。Apple Family Sharing 対応で家族間 1 回購入。WWDC26 で発表された iOS 27 / App Intents / Live Activities / Foundation Models を v1.1 で先行採用する indie パイオニア。

## Supplemental URLs（最大 5 枠）

| # | URL | 内容 |
|---|---|---|
| 1 | https://satori7227-dot.github.io/asobi-privacy/ | プライバシーポリシー（Data Not Collected 完全クリア宣言） |
| 2 | https://satori7227-dot.github.io/asobi-privacy/support.html | サポート / FAQ（mailto 一本化の意見箱仕様） |
| 3 | （ローンチ後追加）| note 連載「家族・カップル・宅飲みで沈黙を救うアプリ」第 1 本 |
| 4 | （ローンチ後追加）| 個人開発者ブログ（井戸川聡里）の ASOBI 開発記 |
| 5 | （ローンチ後追加）| 4Gamer / ねとらぼ / ITmedia 取り上げ記事 |

## 推奨カテゴリ枠

- ✅ **Apps & Games > Family Game Night**（3 世代対応訴求）
- ✅ **Apps & Games > Indie Spotlight**（個人開発・宮崎在住）
- ✅ **Apps & Games > Privacy First**（Data Not Collected 完全クリア）
- ✅ **Today タブ Stories**（「個人開発者が日本のパーティー文化を 1 人で集めた」narrative）
- ☐ App of the Day（v1.1 リリース後・更新時のキャンペーンで再検討）

## 提出スケジュール

| 時期 | 内容 |
|---|---|
| **本日 2026-06-24** | 本 draft 完成 → Apple Developer 承認待ち |
| Apple Developer 承認直後 | App Store Connect → Featuring Nominations から第 1 弾 submit |
| 2026-07 public beta | iOS 27 beta + TestFlight 外部テスト・Editorial 担当者との接触 |
| 2026-08 | iOS 27 GA 前最終 asset 入稿（Asset Library live 更新枠で動的差替え） |
| 2026-09-15 | iOS 27 GA + v1.0 リリース当日 Editorial 露出狙い |
| 2026-11-10 | v1.1 リリース時 Featuring Nomination 第 2 弾提出（12 月忘年会キャンペーン枠） |

## ROI 期待値

第 2 回外部リサーチで判明した一次データ：

- Featuring Nomination の **indie 平均 DL lift +792-1,747%**
- 採択された場合の典型的 DL 増加: 1,000 / 日 → 10,000-20,000 / 日（数日間）
- App Store Today タブ採択時の月収増加: 月 ¥10,000 → 月 ¥100,000-500,000（Heads Up! 系の事例）
- 採択確率: **個人開発 + 日本ローカル枠 + iOS 27 同期 = 推測 5-15%**（Apple は採択基準を公開していない）

未採択でも提出自体は無料、リジェクト理由のフィードバックが得られる場合があり、第 2 弾以降の改善材料になる。

## 関連 docs

- `docs/launch-prep-2026-06-19.html` App Store メタデータ draft
- `docs/marketing/q4-roadmap.md` 季節 deck ロードマップ + メディア連携計画
- `docs/roadmap/v1.1-spec.md` Featuring 第 2 弾向け Innovation 軸の中身
- `docs/review-reports/2026-06-24-research-pass-2.html` Featuring Nomination 採択根拠データ
- `docs/post-developer-signup.html` Apple Developer 承認後の Featuring Nomination submit 手順（Phase 2）
