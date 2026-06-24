# review-reports インデックス（2026-06-24 起点）

ASOBI の戦略・品質・リサーチ系レポートの索引。読む順序と更新タイミングを記録する。

## 全レポート一覧

| 日付 | レポート | 焦点 | サイズ | 読む順序 |
|---|---|---|---|---|
| 2026-06-23 | `2026-06-23-15-lens-audit.{json,html}` | コード品質 15 lens 監査（Critical 7 / High 27 / Medium 28 / Low 11） | 475 KB / 62 KB | ① |
| 2026-06-23 | `2026-06-23-breakout-gap-analysis.{json,html}` | 爆発的ヒット 15 lens gap 分析（80/20 lever 特定） | — | ② |
| 2026-06-24 | `2026-06-24-external-research-fill.json` | 第 1 弾外部リサーチ 13 lens（実数値検証） | 120 KB | ③ |
| 2026-06-24 | `2026-06-24-research-pass-2.{json,html}` | 第 2 弾 9 lens（WWDC26 / Today 採択 / 失敗事例 / 商標 13 件） | 72 KB | ④ |

## 読む順序の意味

- **① 15-lens-audit**: コード品質ベース。Critical 7 はすべて実装済の修正の根拠
- **② breakout-gap-analysis**: 戦略 lever。北極星ペルソナ「沈黙が降りた瞬間にスマホを開く非・社交派の主催者」を特定
- **③ external-research-fill**: ②で「業界一般値」だった部分を一次ソースで実数値化
- **④ research-pass-2**: ③のまま残った不確実性（WWDC26 / Today 採択 / 商標確定 / 個人開発月収 / AI コスト等）を埋める

## 戦略の収束結論

3 回の Workflow と 1 回の本人インタビューを統合して得た結論：

> **「ASOBI を Houseparty にするな、Heads Up! にしろ」**
>
> - 静的 1176 ゲーム + 完全オフライン + 17+ 維持
> - 2026-09-15 iOS 27 GA 当日 Editorial 露出狙い
> - 2026-12 忘年会キャンペーン（Z 世代 68.8% 反証プレスフック）
> - v1.1 で App Intents + Live Activity + Foundation Models 採用
> - 後付けペイウォール永続禁止を信頼貯金宣言

詳細は memory `project_asobi_research_findings` を参照。

## 関連 docs（このリサーチを実装したもの）

| ファイル | 内容 |
|---|---|
| `docs/business/retirement-line.md` | 6 ヶ月撤退ライン（5 指標 + 判定スコアシート） |
| `docs/security/api-key-policy.md` | haruhi-api-key 流用禁止 + Foundation Models 優先 |
| `docs/roadmap/v1.1-spec.md` | App Intents 3 件 + Live Activity + Foundation Models |
| `docs/marketing/q4-roadmap.md` | 季節 deck カレンダー + メディアタレコミ + 12 月忘年会 |
| `docs/marketing/featuring-nomination-v1-draft.md` | App Store Connect submit 用 7 軸 pitch |
| `docs/launch-prep-2026-06-19.html` | 「後付けペイウォール禁止」誓約 + Family Sharing 訴求を冒頭追加 |

## 次回更新タイミング

- v1.0 リリース後 30 日（実 retention / 評価 / DL データで仮説を更新）
- v1.0 リリース後 90 日（撤退ライン判定）
- iOS 28 / WWDC27 発表時（新 API の party game 適用調査）
- 重大なリジェクトを受けた時（Apple Review Guidelines の解釈をログ化）

## 古くなる前提（要再検証）

| 前提 | 古くなりやすさ | 再検証タイミング |
|---|---|---|
| Z 世代忘年会参加意欲 68.8% | 中（年次調査） | Job総研 2027 年版が出たら |
| iOS retention D30 = 7% | 低（業界構造値） | GameAnalytics の次年版で |
| Heads Up! 月 $200k | 中（売上は変動） | Sensor Tower 無料公開分が更新されたら |
| Apple Editorial 採択基準 | 不明（非公開） | 採択された個人開発 partygame が出るたび |
| 商標候補 10 件のうち何件確定リスクか | 高（J-PlatPat 直接照会必要） | 弁理士相談 1 回で確定 |

## 使い方

新しい戦略提案や数字検証で「業界一般値」「推測」を使いそうになったらまず本書 + memory `project_asobi_research_findings` を参照する。本書に無いものだけ新規調査する。
