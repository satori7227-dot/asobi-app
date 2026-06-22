# fastlane 雛形

App Store Connect への TestFlight 配信・申請を CLI で自動化する。

## 前提（Apple Developer 契約後に行う作業）

1. Apple Developer Program 個人登録（年¥約15,800）
2. App Store Connect → Users and Access → Keys から App Manager 権限の API Key 発行（.p8 をダウンロード、紛失したら再発行不可なので 1Password 等に即保管）
3. 環境変数を `.envrc` 等で設定（コミット禁止）

```sh
export FASTLANE_USER=satori7227@gmail.com
export ASC_KEY_ID=XXXXXXXXXX
export ASC_ISSUER_ID=YYYYYYYY-YYYY-YYYY-YYYY-YYYYYYYYYYYY
export ASC_KEY_FILEPATH=$HOME/secure/AuthKey_XXXXXXXXXX.p8
```

## fastlane インストール

```sh
brew install fastlane
```

## レーン

- `fastlane bump` — `scripts/bump-build-number.sh` を呼んで CURRENT_PROJECT_VERSION 更新
- `fastlane test` — ユニットテスト実行（API Key 不要）
- `fastlane beta` — Release ビルド → TestFlight アップロード（処理待ちなし）
- `fastlane release` — App Store Connect のメタデータ更新（手動 submit）

## 補足

- `metadata/ja.lproj/`, `screenshots/ja-JP/` を後で追加すると deliver に反映される
- 「submit_for_review: false」のままにし、最初は手動で「Submit for Review」を押すのを推奨（初回は審査ガイドライン確認のため）
