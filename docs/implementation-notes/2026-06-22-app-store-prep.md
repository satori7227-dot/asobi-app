# 2026-06-22 App Store 申請準備（Apple Developer 待ちで並走可能な範囲）

## やったこと

- ビルド・テスト・xcstrings lint をすべて緑で再確認（88 tests / 3 skipped / 0 failures）。
- `AsobiUITests` を新規 target として追加し、`AsobiUITests/ScreenshotTests.swift` で 1320×2868 のスクショ5枚を XCUITest で自動生成（scene_picker / context_input / proposal / game_detail / tools）。
- スクショ再生成を `fastlane screenshots` でワンコマンド化（`scripts/capture-screenshots.sh` 経由）。
- `Asobi/Views/ProposalView.swift` の GameCard に `.accessibilityElement(children: .combine)` + `proposal-card-N` identifier を付与（UI test 用＋VoiceOver でカードを1要素として読む自然な体験）。
- `Asobi/Views/SettingsView.swift` のプライバシーポリシー URL を `https://idogawasatori.github.io/asobi-privacy/` に統一。
- `docs/launch-prep-2026-06-19.html` の GitHub Pages 公開手順を `asobi-privacy` リポジトリ前提に書き換え（実装側と URL を一致）。
- `.tools/make_appstore_screenshot.swift` に引数の `\n` をリテラル改行へ置換する処理を追加（gitignore 対象なので commit には含まれない）。
- `README.md` のテスト件数を 66 → 88 に更新。
- `AsobiWidget/PrivacyInfo.xcprivacy` を新規作成。App 側と同様に Tracking false / Collected/Tracking domains 空。Widget は UserDefaults を読まないので AccessedAPITypes も空。Apple は extension 単位の Privacy Manifest を推奨しているため、App と Extension で別ファイルにする方が将来の差異吸収に強い。

## 仕様外で決めたこと（Rule 13）

- **GitHub アカウント名は `idogawasatori`**。SettingsView 側の旧表記 `satori-idogawa` を捨てた。判断根拠は memory の `satori7227@gmail.com` および user_idogawa.md との語順整合。
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

## 次回着手時の起点

`docs/post-developer-signup.html` Phase 0 から順に。本書は Apple Developer 登録前の並走作業ログ。
