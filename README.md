# あそぶ？（仮称）

シーン別ゲーム提案アプリ（iOS）。あらゆる遊び場面のゲームを 1 アプリでまとめて提案する。

## このリポジトリの中身

```
asobi-app/
├─ README.md                    # このファイル
├─ Asobi/                       # Swift ソース一式（Xcode に取り込む）
│  ├─ AsobiApp.swift            # @main エントリ
│  ├─ Models/                   # データモデル
│  │  ├─ Game.swift
│  │  ├─ Scene.swift
│  │  └─ ProposalContext.swift
│  ├─ Data/
│  │  └─ games.json             # ゲーム DB（編集すればゲーム追加可能）
│  ├─ Services/
│  │  ├─ GameRepository.swift   # games.json 読み込み・フィルタ
│  │  └─ FeedbackStore.swift    # 👍👎 ローカル保存
│  └─ Views/
│     ├─ ScenePickerView.swift
│     ├─ ContextInputView.swift
│     ├─ ProposalView.swift
│     ├─ GameDetailView.swift
│     └─ SuggestionFormView.swift
```

`Asobi.xcodeproj` は含まれていません（Xcode で作成する）。

---

## 事前準備：Xcode のインストール

このリポジトリの状態（2026-06-18 確認時点）では **Xcode 本体が未インストール**です。Command Line Tools しか入っていません。先に Xcode をインストールしてください。

1. Mac App Store を開く → 「Xcode」を検索 → **入手** → インストール（**無料・約15GB・1〜2時間**）
2. インストール完了後、ターミナルで以下を実行：

   ```bash
   sudo xcode-select -s /Applications/Xcode.app/Contents/Developer
   sudo xcodebuild -license accept
   ```

   1 つ目で開発者ディレクトリを Xcode 本体に切り替え、2 つ目でライセンス同意。

3. 確認：

   ```bash
   xcodebuild -version
   ```

   `Xcode 15.x` 等が出れば OK。

## 初回セットアップ（Xcode で 5 分）

### 1. Xcode で新規プロジェクト作成

1. **Xcode** を起動
2. **File → New → Project...**
3. **iOS** タブで **App** を選択 → **Next**
4. 以下を入力：
   - **Product Name**: `Asobi`
   - **Team**: ご自身の Apple ID（未設定なら「Add Account...」で satori7227@gmail.com を追加）
   - **Organization Identifier**: `com.idogawa`（→ Bundle ID は `com.idogawa.Asobi` になる）
   - **Interface**: **SwiftUI**
   - **Language**: **Swift**
   - **Storage**: **None**（SwiftData / Core Data チェックなし）
   - **Include Tests**: 任意（チェックなしでもOK）
5. **Next** → 保存場所に **`/Users/idogawasatori/Desktop/AppDev/asobi-app/`** を選択
   - **Source Control: Create Git Repository** は **チェックなし**（後で対応）
6. **Create** クリック

これで `/Users/idogawasatori/Desktop/AppDev/asobi-app/Asobi.xcodeproj` と `Asobi/AsobiApp.swift` 等が生成されます。

### 2. 既存ソースファイルを取り込む

Xcode が自動生成した `Asobi/AsobiApp.swift` と `Asobi/ContentView.swift` は **このリポジトリの Asobi/AsobiApp.swift で上書きします**。手順：

1. Finder で `/Users/idogawasatori/Desktop/AppDev/asobi-app/Asobi/` を開く
2. このリポジトリで準備した以下のフォルダを Xcode の **Asobi グループ** にドラッグ＆ドロップ：
   - `Models/`
   - `Data/`
   - `Services/`
   - `Views/`
3. ドロップ時のダイアログで：
   - **Copy items if needed**: チェック**なし**（既にディレクトリ上にあるため）
   - **Create groups**: 選択
   - **Add to targets: Asobi**: チェック**あり**
4. Xcode が生成した `ContentView.swift` は **削除**（右クリック → Delete → Move to Trash）
5. Xcode が生成した `AsobiApp.swift` は **このリポジトリの版で上書き**（既にディスク上は新しい版になっている。Xcode 側で「ファイルが変更されました」と聞かれたら Revert を選択）

### 3. ビルド＆実行

1. 上部の実行ターゲットを **iPhone 17 Pro Max Simulator**（か手元のiPhone）に
2. **⌘R** で実行
3. シーン選択画面が出れば成功

### 4. 実機（井戸川さんの iPhone）に転送する場合

1. iPhone を Mac に Lightning/USB-C ケーブルで接続
2. iPhone で「設定 → 一般 → VPN とデバイス管理」を開いておく
3. Xcode 上部の実行先で接続した iPhone を選択
4. **⌘R** で実行
5. iPhone 側で「信頼されていないデベロッパ」と出たら、**設定 → 一般 → VPN とデバイス管理** から信頼設定

**注意**：Apple Developer Program 未契約だと、自分の Apple ID で作ったアプリは **7 日で iPhone 上で無効化**されます。再度 Xcode から実行し直せば 7 日延長されます。

---

## ゲーム DB の編集（PDCA 運用）

ゲームを追加・修正したい場合：

1. `Asobi/Data/games.json` を編集
2. Xcode で **⌘R** で再実行（再ビルドで反映）

`games.json` のスキーマ：

```json
{
  "id": "yamanote",
  "name": "山手線ゲーム",
  "summary": "テーマに沿って言葉を順に挙げる",
  "rules": "1. お題を1つ決める\n2. リズムに合わせて順番に答える\n3. 詰まったら負け",
  "scenes": ["drinking", "travel"],
  "minPlayers": 2,
  "maxPlayers": 10,
  "tension": ["calm", "medium", "high"],
  "duration": "short",
  "items": []
}
```

- `scenes`: 適用シーン（複数指定可）。MVP では `travel` / `drinking` / `penalty`
- `tension`: 適合するテンション。`calm` / `medium` / `high` から複数
- `duration`: `short` (5分未満) / `medium` (5-15分) / `long` (15分以上)
- `items`: 必要な道具（空配列なら不要）

---

## 意見箱の運用

ユーザーが意見箱に書いた内容は標準メールアプリ経由で `satori7227@gmail.com` 宛に届きます（2026-06-23 Discord Webhook 経路は完全廃止・mailto 一本化済、メールアプリ未設定時はクリップボードコピー fallback）。

週 1 で受信箱を確認 → よく出る要望を `games.json` に反映 → 再ビルド配信。

---

## v2 で予定している拡張

- ヘルメスエージェント（Anthropic API）でゲーム動的生成
- Widget / AppIntents（Siri）/ Live Activities
- 海外パーティーゲームの英訳完全カバー（現状 80/80 件）

詳細は `/Users/idogawasatori/.claude/plans/peppy-hopping-flamingo.md` 参照。

---

## 現在の主要機能（2026-06-23 時点）

- **1176 件** のゲーム DB（13 シーン横断、全件 id 一意、海外 80 件は英訳完備）
- 13 シーン: 飲み会 / 旅行 / 罰ゲーム決め / 家族・親戚 / カップル・2人 / キャンプ・BBQ / リモート飲み / 子供連れ / 合コン / 同窓会 / オフ会 / 就活グループワーク / 送別会
- 状況入力（人数/テンション/所要時間/手ぶら）→ 3 件提案、Active Chips で常時表示
- お気に入り / コレクション（複数所属可・改名・削除・スワイプ追加）
- ツールセット 7 種（サイコロ/コイン/トランプ/ルーレット/タイマー/お題ガチャ/王様くじ）
- ja/en 多言語対応（185 文言、format string 含む）
- regionBlocklist による地域別フィルタ（飲酒系6件をイスラム圏で非表示）
- アプリ内レビュー要請（条件 AND 発火）
- 月間プレイ回数ベースのソフトペイウォール（flag で OFF）
- 設定画面（バージョン / Privacy Policy / 意見箱 / Tip Jar）

## Deep Link

| URL | 動作 |
|---|---|
| `asobi://scene/<id>` | 指定シーンの状況入力へ |
| `asobi://game/<id>` | 指定 ID のゲーム詳細を sheet で開く |
| `asobi://favorites` | お気に入りシート |
| `asobi://collections` | コレクション一覧 |

Simulator で動作確認: `xcrun simctl openurl booted "asobi://scene/drinking"`

## ShareLink

GameDetail から `asobi://game/<id>` 形式でリッチプレビュー付き共有可。受信側でアプリ起動 → 該当ゲーム詳細を直接表示。

## fastlane lane 一覧

| lane | 用途 |
|---|---|
| `fastlane bump` | git rev-list で BUILD 自動採番 |
| `fastlane test` | ユニットテスト実行 |
| `fastlane beta` | TestFlight アップロード |
| `fastlane release` | App Store Connect メタデータ更新 |
| `fastlane notes` | git log からリリースノート生成 |

詳細は `fastlane/README.md` 参照。

## ユニットテスト

```sh
fastlane test
# or
xcodebuild -project Asobi.xcodeproj -scheme Asobi -destination 'platform=iOS Simulator,name=iPhone 17' test
```

現状: **88 tests passed (3 skipped, 0 failures)** ／ AsobiUITests 1 test passed

## xcstrings lint

```sh
python3 scripts/xcstrings-lint.py
```

en 欠落 / en 日本語混入 / en 値重複を検出。`--strict` で CI 化可能。

---

## 公開準備ドキュメント（docs/）

- `docs/next-actions-dashboard.html` — **6 角度の「次の一手」ダッシュボード**（配布／収益化／ユーザー獲得／機能拡張／品質運用／海外展開）
- `docs/release-checklist.html` — TestFlight・App Store リリース毎の Phase 0-8 + 緊急時手順
- `docs/resolution-center-templates.html` — App Store リジェクト想定 4 種の英文応答テンプレ
- `docs/launch-prep-2026-06-19.html` — 初回公開準備ガイド
- `docs/subscription-spec-2026-06-19.html` — サブスク仕様
- `docs/monetization-research-2026-06-19.html` — 先行収益化リサーチ
- `docs/privacy-policy.html` — プライバシーポリシー
- `docs/code-review-2026-06-18.html` — コードレビュー結果
- `fastlane/README.md` — TestFlight 自動配信フロー
- `Version.xcconfig` + `scripts/bump-build-number.sh` — git コミット数で BUILD 自動採番

## コンプライアンス系（実装済）

- `Asobi/PrivacyInfo.xcprivacy` — Data Not Collected + UserDefaults CA92.1 宣言
- `Asobi/Info.plist` — `ITSAppUsesNonExemptEncryption = false`
- `Asobi/Services/AppStorageKeys.swift` + `PersistenceMigrator` — 永続化キー集約・schemaVersion 管理
- `Asobi/Services/AsobiLogger.swift` — OSLog 6 カテゴリ（propose/filter/purchase/data/feedback/lifecycle）
- `Asobi/Services/PlayCountStore.swift` — 月20本ソフトペイウォール基盤（`Constants.softPaywallEnabled` で gate）
- `Asobi/Views/TipJarView.swift` — Tip Jar 雛形（`Constants.tipJarEnabled` で gate）
- `.swiftlint.yml` — 最小ルール

---

## トラブルシューティング

| 症状 | 対処 |
|---|---|
| Xcode で「Bundle Identifier already exists」 | Settings → Signing & Capabilities → Bundle Identifier を別名に（例：`com.idogawa.Asobi2`） |
| 「Untrusted Developer」と iPhone で出る | iPhone 設定 → 一般 → VPN とデバイス管理 → 信頼 |
| games.json の変更が反映されない | Xcode の Product → Clean Build Folder（⇧⌘K）してから再実行 |
| 「Failed to load games.json」 | `Asobi/Data/games.json` が **Target Membership: Asobi** にチェック入っているか確認 |
