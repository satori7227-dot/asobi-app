# YYYY-MM-DD vX.Y.Z リリースログ

ファイル名: `YYYY-MM-DD-vX.Y.Z.md`（例: `2026-07-15-v1.0.0.md`）。
`release-checklist.html` Phase 8 に従い、リリースの度に本テンプレを複製して埋める。

---

## メタ情報

- **バージョン**: vX.Y.Z
- **ビルド番号**: NNNN
- **TestFlight アップロード日時**: YYYY-MM-DD HH:MM JST
- **App Store 申請日時**: YYYY-MM-DD HH:MM JST
- **審査完了日時**: YYYY-MM-DD HH:MM JST
- **Phased Release 開始日時**: YYYY-MM-DD HH:MM JST
- **100% 配信到達日時**: YYYY-MM-DD HH:MM JST

## やったこと

- コード変更（コミットハッシュ + 1行サマリ）
  - `commit_hash` 〜
- メタデータ変更（subtitle / promotional text / description / keywords / what's new）
- スクショ更新の有無（差し替えた画面・追加した画面）
- IAP / サブスク / Tip Jar の変更
- Privacy Manifest の変更

## 判断に迷った点（採用 / 棄却の理由）

- 例: iPad ターゲットを残すか外すか → 残した。理由: ...
- 例: Phased Release vs Manual Release → Phased Release を選んだ。理由: ...

## 仕様外で決めた点（Implementation Notes）

- Rule 13 準拠。命名・構造・デフォルト値・例外処理方針・時間/技術制約による妥協・「後で見直すべき」メモ。

## 数値（リリース 24h / 1週間 / 1ヶ月）

| 時点 | DL | レビュー | 平均評価 | クラッシュ率 | IAP 収益 | サブスク MAU |
|---|---|---|---|---|---|---|
| 24h | | | | | | |
| 1w | | | | | | |
| 1m | | | | | | |

## レビュー対応ログ

- リジェクトされた場合: 理由・対応・再申請日時
- Resolution Center とのやり取り要約
- テンプレ参照: `docs/resolution-center-templates.html`

## 次回への申し送り

- 次バージョン v(X.Y+1).0 で対応すべき要望（アイデア箱・SNS フィードバック・自己発見）
- 次バージョンで撤回 / 統合すべき仕様
- Promotional Text 月次差し替え予定（季節文脈）

## 関連ファイル

- `docs/release-checklist.html`（チェックリスト本体）
- `docs/manual-tests.html`（手動テスト記録）
- `docs/implementation-notes/`（仕様外決定のログ）
