# ASOBI API Key Policy v1（2026-06-24 起案）

ASOBI v1.1 以降で AI 機能（動的お題生成・お題語彙拡張）を導入する場合の API キー取扱原則。haruhi 事業（auto-company）の Anthropic Max5x キー流用事故を構造的に防止する。

## 第 1 条: haruhi-api-key 流用禁止

memory に記録されている **haruhi 専用 Anthropic 従量キー**（Capafy 公開 Skill / Agent 用）を ASOBI から呼び出すことは**絶対に禁止**する。

**理由**:
- 2026-06-09 に発生した **¥4.55 スパイク事案**（心当たりなし）で発覚した監視難度
- haruhi-api-key は Capafy 利用者の従量課金軸で、ASOBI 利用での消費は haruhi 事業の収益構造を直接破壊する
- Max5x サブスクの OAuth キーをアプリから直接叩く設計は Apple ガイドライン 5.1.2(i) の第三者 AI 開示義務に抵触

## 第 2 条: ASOBI 専用キーの分離調達

AI 機能を v1.1 で導入する場合：

1. **ASOBI 専用の Anthropic 従量キー**を別契約（haruhi-api-key とは別ワークスペース）
2. **Cloudflare Workers / Vercel Edge proxy** 経由でのみ呼び出す（API キーをアプリバンドルに焼き込まない）
3. **月予算 hard cap**: Anthropic Console の Workspace 単位で `$50/月` を上限設定
4. **rate limit per user**: 同一 IP / install ID から 1 日 100 リクエストを上限
5. **緊急時 kill switch**: GitHub Pages の JSON フラグで `{"ai_enabled": false}` を fetch して停止可能

## 第 3 条: 観測義務

毎週チェック：

- Anthropic Console の usage グラフ（オーナー目視・$0 期待値）
- Cloudflare Workers の Request 数 / Error 数 / Throttle 発動回数
- ASOBI 内の AI 機能呼び出し回数（端末ローカル UserDefaults でカウント）

異常スパイク（前週比 ×3 以上）を検知したら **即時 kill switch ON**。

## 第 4 条: 第三者 AI の利用開示

ASOBI v1.1 以降で AI 機能を有効化した場合：

1. App Store メタデータの説明文に「ChatGPT / Claude / Gemini 等の第三者 AI サービスを利用しています」を明記
2. アプリ内設定画面に AI 機能の ON/OFF トグル + プライバシーポリシーへのリンク
3. プライバシーポリシー（asobi-privacy リポ）に第三者 AI への送信内容を追記
4. Privacy Manifest に `NSPrivacyAccessedAPITypes` 追記（必要な場合のみ）
5. Age Rating 17+ → 18+ 変更要否を Apple Developer 公式ドキュメントで確認

## 第 5 条: Foundation Models 優先

iOS 27 (2026/09/15 GA) 以降は **Apple Foundation Models framework**（on-device、API キー不要、コスト ¥0）を優先。第三者 AI は以下の場合のみ：

- Foundation Models で品質が不足する場合
- iOS 26 以下の互換性を維持する場合

優先順位：
1. Foundation Models（on-device・¥0・iOS 26 以降）
2. 静的アセット（games.json / prompts.json の事前生成）
3. 第三者 AI API（最終手段・第 2 条以下を厳守）

## 第 6 条: 17+ 維持の絶対条件

AI 機能を入れることで以下が発生すると Age Rating が 18+ に強制アップグレードされ、AdMob 広告収益・App Store 露出が崩壊する：

- ユーザー入力をそのまま AI 推論に渡し、生成文章をユーザーに見せる
- AI が暴力 / 性的 / 違法 / 過激な内容を出力する可能性がある場合に filter を実装していない
- AI が「現実の会話の相手」となる対話型機能を実装する

許容される AI 用途：
- ✅ お題テキストの語彙バリエーション拡張
- ✅ ゲームルールの読みやすさ整形
- ❌ ユーザー入力 + AI 生成（user content + AI = 18+ リスク）
- ❌ AI が「お題」を完全自由生成

## 関連 docs

- `docs/secrets-inventory.html` 機密管理（30 日休眠耐性）
- `docs/business/retirement-line.md` 撤退ライン（コスト管理連動）
