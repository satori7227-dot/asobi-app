# 2026-06-22 App Store 申請準備（Apple Developer 待ちで並走可能な範囲）

## やったこと

- ビルド・テスト・xcstrings lint をすべて緑で再確認（88 tests / 3 skipped / 0 failures）。
- `AsobiUITests` を新規 target として追加し、`AsobiUITests/ScreenshotTests.swift` で 1320×2868 のスクショ5枚を XCUITest で自動生成（scene_picker / context_input / proposal / game_detail / tools）。
- スクショ再生成を `fastlane screenshots` でワンコマンド化（`scripts/capture-screenshots.sh` 経由）。
- `Asobi/Views/ProposalView.swift` の GameCard に `.accessibilityElement(children: .combine)` + `proposal-card-N` identifier を付与（UI test 用＋VoiceOver でカードを1要素として読む自然な体験）。
- `Asobi/Views/SettingsView.swift` のプライバシーポリシー URL を `https://satori7227-dot.github.io/asobi-privacy/` に統一（途中で `satori-idogawa` → `idogawasatori` → `satori7227-dot` と2回置換。最終確定はログイン中の実アカウント `satori7227-dot`）。
- `docs/launch-prep-2026-06-19.html` の GitHub Pages 公開手順を `asobi-privacy` リポジトリ前提に書き換え（実装側と URL を一致）。
- `.tools/make_appstore_screenshot.swift` に引数の `\n` をリテラル改行へ置換する処理を追加（gitignore 対象なので commit には含まれない）。
- `README.md` のテスト件数を 66 → 88 に更新。
- `AsobiWidget/PrivacyInfo.xcprivacy` を新規作成。App 側と同様に Tracking false / Collected/Tracking domains 空。Widget は UserDefaults を読まないので AccessedAPITypes も空。Apple は extension 単位の Privacy Manifest を推奨しているため、App と Extension で別ファイルにする方が将来の差異吸収に強い。

## 仕様外で決めたこと（Rule 13）

- **GitHub アカウント名は最終的に `satori7227-dot`**。経緯：(1) コード上の旧表記は `satori-idogawa`、(2) 本人申告で `idogawasatori` 採用、(3) 実ログインアカウントが `satori7227-dot` と判明し再修正。`idogawasatori` は既存の別アカウント（リポジトリ `satori.github.io` を持つ）で本人のものではない可能性。`satori7227-dot` のままだとハイフン入り URL になるが機能はする。将来アカウント名を改名する場合は SettingsView / launch-prep / implementation-notes を同期修正する。
- **Privacy Policy 専用リポジトリ `asobi-privacy` を採用**。`asobi-app-public` 案は不採用。理由：SettingsView.swift の URL を `<account>.github.io/asobi-privacy/` 形式で既にハードコード済で、Pages 設定が最短経路（リポジトリ直下の `index.html` を Source: main で Save するだけ）。
- **App Store スクショ 6.7" のみ生成**。Apple は iPhone 6.5" を 2026-04 で必須から外しているため、6.7" (1320×2868) のみで申請可。後で 6.5" を足す場合は `scripts/capture-screenshots.sh` の DEVICE を変えて再実行。
- **UITests target は CODE_SIGNING_REQUIRED=NO** で Simulator 専用扱い。実機 UI テストする場合は Release config 側で別途調整が必要。

## 未解決・要本人作業

- Apple Developer Program 登録（保留）。
- GitHub アカウント作成（既存未確認）と `asobi-app` / `asobi-privacy` 2リポジトリ作成 → URL 受領後にこちらで `git remote add` + `git push` 実行予定。
- swiftlint バイナリ未インストール（Homebrew 自体が無い）。`fastlane lint` は xcstrings 用なので OK、Swift コード lint は **Phase 1 でスキップ宣言**。導入する場合は `brew install swiftlint` か `mint install realm/SwiftLint`。
- App Store メタデータ（subtitle / promotional text / description / keywords / What's New）は `docs/launch-prep-2026-06-19.html` のドラフトを使用予定だが、未確定。
- 各スクショの App Store 仕様加工（キャッチコピー入りフレーム版）は `.tools/make_appstore_screenshot.swift` でいつでも生成可能。コピー文言を確定したら 5 枚 × フレーミングを一括実行する。
- **iPad 申請ターゲット判断保留**。`project.yml` の `TARGETED_DEVICE_FAMILY: "1,2"` で App / Widget 双方が iPhone + iPad を申請ターゲットにしている。iPad を維持するなら 13 インチ iPad Pro 用スクショ（2064×2752 等）が別途必要。party-game の主用途は iPhone なので iPad ターゲットを外す（`"1"` に変更）案も合理的。本人判断待ち。

## 2026-06-23 追記 — 承認待ち並走の追加整備

- **A: 数字修正** — `docs/launch-prep-2026-06-19.html` の「256 ゲーム」「215 のお題」を実データに合わせて **1191 ゲーム / 256 お題** に更新。お題数は prompts.json のカテゴリ別合計（50+40+30+20+20+36+20+20+20）。
- **B: support.html 追加** — App Store Connect の Support URL 欄に貼る用に `asobi-privacy` リポジトリへ `support.html` を追加。`https://satori7227-dot.github.io/asobi-privacy/support.html` で配信中（21秒で初回 build 完了）。
- **C: 英語版スクショ整備（部分完了）** — `AsobiUITests/ScreenshotTests.swift` を ja / en の 2 メソッドに分割。`ContextInputView` の メイン CTA に `context-input-search-button` identifier を付け、xcstrings 翻訳に依存しない UI test に。`scripts/capture-screenshots.sh` を language prefix（ja_/en_）で fastlane/screenshots/{ja-JP,en-US} に振り分けるよう更新（`LANGUAGES=both` で両言語、未指定で ja のみ）。**ハマり**: 本日 Xcode 26.5 / iOS 26.5 Simulator で `Pseudo Terminal Setup Error / Device not configured` が頻発し、`simctl erase + boot` でも解消せず。Mac 再起動 or Xcode 再起動で復旧見込み。実際の en スクショ生成は環境復旧後に `LANGUAGES=both bash scripts/capture-screenshots.sh` で再実行。既存の ja 5 枚（6/22 17:31 撮影分）は引き続き有効。
- **D: メタデータ更新** — launch-prep の subtitle / promotional text / description / keywords を 1191 ゲーム前提で書き直し。各シーン例は games.json から実データ抜粋。**他社製品名（GeoGuessr / Gartic Phone / Among Us / Codenames Online / Skribbl.io / Jackbox Quiplash）はメタデータから除去**（実データには残るが、App Store 説明文には載せない・商標リスク回避）。
- **E: release-log テンプレ** — `docs/release-log/TEMPLATE.md` 新規作成。release-checklist Phase 8 で参照される `docs/release-log/YYYY-MM-DD-vX.Y.Z.md` の雛形。
- **F: iPad ターゲット判断（保留中）**
  - 撤退案: `project.yml` の 2 箇所の `TARGETED_DEVICE_FAMILY: "1,2"` を `"1"` に、`UISupportedInterfaceOrientations~ipad` セクション削除、`fastlane deliver` の iPad スクショ要求を回避。実装 5 分。
  - 維持案: iPad 13" Pro (M4) シミュレータで `capture-screenshots.sh` の DEVICE を切り替えて再実行。`fastlane/screenshots/ja-JP/ipad-13/` に 5 枚配置。実装 10 分 + 1 タスク追加。
  - 判断: ASOBI の主用途は iPhone・パーティーゲーム提案なので **撤退寄り**を推奨。本人判断待ち。
- **G: fastlane Snapfile（保留）** — `scripts/capture-screenshots.sh` で実用上十分なので、Snapfile + SnapshotHelper.swift は追加実装せず。将来 `fastlane snapshot` のレポート機能（言語別 HTML grid）が欲しくなったら追加検討。
- **H: PrivacyInfo 再 audit（OK）** — 全 Swift コード grep の結果、UserDefaults 以外の Required Reason API（FileManager 日付・systemBootTime・systemUptime・disk volume size 等）の使用なし。現状の `Asobi/PrivacyInfo.xcprivacy`（CA92.1 のみ）と `AsobiWidget/PrivacyInfo.xcprivacy`（空）は実装と完全整合。**App Store Connect の App Privacy ラベル「Data Not Collected」のまま提出可**。

## 22:30 追記 — GitHub リモートと Pages 公開

- `asobi-app` リポジトリ作成（`satori7227-dot/asobi-app`, public）→ ローカル 9 commits を push 完了。
- `asobi-privacy` リポジトリ作成（`satori7227-dot/asobi-privacy`, public）→ `docs/privacy-policy.html` を `index.html` としてコピー、1 commit push 完了。Pages 設定 Source: main / / で配信中。
- 認証は fine-grained PAT（`asobi-app deploy 2026-06-22`、Contents: Read and write、Repos: 上記2本のみ、Expiration: 30 days）。push 完了後 remote URL から PAT は除去済、`.git/config` 平文残りなし。PAT は不要になり次第本人が revoke 予定。
- ハマりポイント：fine-grained PAT は新規発行時に Repository permissions を Add しないと **権限ゼロ**で 200 read access はあっても push が 403 になる（Repository access での選択だけでは権限は付与されない）。本書発行手順に「Contents: Read and write を明示追加」を必ず入れる。

## 2026-06-23 追記 — ローカル Pseudo Terminal Setup Error の症状と対処

- 症状: `xcodebuild test` 時に `Pseudo Terminal Setup Error / ErrorCode 7 Errno 6 / Device not configured` で test runner が install/launch 不能。`xcodebuild build` は OK。
- 試行して**効かなかった**: `simctl shutdown all` + `simctl erase` + `simctl boot`、device を iPhone 17→17 Pro→17 Pro Max→無印で切り替え、ユーザ権限での `killall com.apple.CoreSimulator.CoreSimulatorService`。
- **効く可能性が高い** (本人作業): (1) **Mac 自体を再起動**、(2) Xcode を一度起動して Settings → Platforms で iOS Simulator を再認証、(3) `sudo xcode-select --reset && sudo xcode-select -s /Applications/Xcode.app`。
- 当面の回避: **GitHub Actions CI で test を回す**。`brew install xcodegen` + `xcodebuild test -destination 'platform=iOS Simulator,OS=latest,name=iPhone 16 Pro Max' -only-testing:AsobiTests` で 88 unit tests が走る。ローカル test runner が落ちてる間も CI で緑は確認可能。

## 2026-06-23 15:30 追記 — 費用発生案件は売上着金後に後送り

本人方針（2026-06-23 確認）：**費用が発生する追加投資は、収益が立ち始めてから着手**。具体的には haruhi 3 ヶ月撤退ライン or 月 ¥3 万到達ライン到達後。

該当する後送り案件：

| 項目 | 想定費用 | 起点 |
|---|---|---|
| Gmail エイリアス分離（独自ドメイン or サブドメイン用 mailbox 増設） | Xserver 内なら無料・追加ドメインなら ¥1,000-3,000/年 | 売上 ¥3 万/月到達後 |
| TelemetryDeck 等の analytics SaaS | $9-29/月 | 課金率の最適化が ROI 上がる段階で |
| 独自サポート Web ホスティング（Cloudflare Pages 等） | 多くは無料・カスタムドメインで ¥1,500/年 | App Store 申請通過 + DL 1000 達成後 |
| Featuring Nomination の有料ローカライズ | プロ翻訳依頼で ¥10-50 万 | 海外売上が立つ段階で |
| Apple Developer 年会費の継続 | ¥12,980/年（本日決済済の翌年分） | 撤退ラインに到達してなければ自動継続を許可 |

**ゼロ円で動かせるもの**は本人 Mac + 既存 GitHub + 既存 Anthropic Max5x の枠内で完結する作業のみ。Privacy Policy / Support / Marketing URL の GitHub Pages 利用、CI 利用、Webhook 不要の mailto 経路、すべて月額ゼロ円で運用可能な構成。

## 次回着手時の起点

`docs/post-developer-signup.html` Phase 0 から順に。本書は Apple Developer 登録前の並走作業ログ。
