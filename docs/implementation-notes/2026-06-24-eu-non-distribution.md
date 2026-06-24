# 2026-06-24 EU 27 ヶ国非配信 + Non-trader 申告（C 案確定）

Apple Developer Program 承認直後の Trader Status 申告と Availability 設定の判断記録。

## 背景

承認後 App Store Connect にアクセスした時点で、EU DSA（デジタルサービス法）に基づく **Trader Status 申告**が必須と判明。Apple ガイダンスでは：

> Even if you don't distribute apps in the EU, you'll still need to declare a trader status.

しかし同時に：

> If you don't distribute apps on the App Store in the EU (for example you only distribute apps through alternative distribution, or TestFlight, or on the App Store only outside the EU), **you're not acting as a trader on the App Store. Apple can't determine whether you're a trader.**

つまり **EU 非配信 + Non-trader 申告** は Apple 公式に許容されているパターン。

## ASOBI の状況と Trader 判定

ASOBI v1.0 は表面的には Non-trader に該当：

- 完全無料・IAP 未解禁・広告ゼロ
- 個人開発・個人ブランド
- 個人事業主届出なし

しかし将来計画上は明確に商業化意図がある：

- `docs/roadmap/v1.1-spec.md`: v1.1 で買切ハイブリッド ¥490-980 base + ¥600-980 deck
- `docs/marketing/q4-roadmap.md`: 2027-10 ハロウィン deck ¥240 / 2027-12 クリスマス deck ¥240
- `Constants.premiumEnabled` / `tipJarEnabled` / `softPaywallEnabled`: コードに前提実装済
- Phase β IAP 解禁が戦略の中核

このため Apple ガイダンスの「**hobbyist who developed your app with no intention of commercializing it**」には厳密には該当しない。Non-trader として申告するなら EU 非配信を前提とするのが誠実な解釈。

## 検討した 4 案

| 案 | 内容 | コスト | リスク | 採否 |
|---|---|---|---|---|
| A | Non-trader で v1 ローンチ、IAP 解禁時 Trader 切替 | ¥0 | 切替忘れリスク・Apple が「将来意図」で判定する可能性 | 不採用 |
| B | 最初から Trader 申告（自宅住所 or 私書箱） | 私書箱 月¥1,000-5,000 | 自宅住所公開のプライバシーリスク or 私書箱費用が「売上着金後」原則と矛盾 | 不採用 |
| **C** | **EU 27 ヶ国非配信 + Non-trader 申告** | **¥0** | **EU 市場の Featuring 機会損失** | **採用** |
| D | Non-trader + IAP 解禁時に EU 配信のみ停止 | ¥0 | 切替手間・en 80 件英訳の一部死蔵 | 不採用 |

## C 案を採用した理由

1. **費用ゼロ**：本人方針「費用がかかるものは売上立ってから」と完全整合
2. **プライバシー保護完全**：住所・電話番号の App Store 公開が回避できる
3. **ガイダンス整合**：Apple 公式に「EU 非配信なら trader 判定対象外」と明記
4. **商業化計画と矛盾なし**：v1.1 で IAP 解禁しても EU で配信しなければ trader 申告不要
5. **個人ブランド分離**（[[feedback_no_company_names]]）と整合：TakiTaki の福岡登記情報を出さない設計を維持
6. **将来の拡大余地**：EU 配信解禁を本人がいつでも判断可能（Trader 切替 + 私書箱契約のセットで）

## トレードオフ

- ❌ **EU 27 ヶ国の市場機会損失**（推定 4-5 億人）
- ❌ MacStories 等の海外メディアでドイツ・フランス・スペイン読者リーチ減
- ❌ EU 圏の Featuring Nomination 採択機会損失
- ✅ ただし主要海外市場（米国 / カナダ / 英国 / 豪 / NZ / アジア / ブラジル）は維持
- ✅ Featuring Nomination 第 1 弾の主軸は **米国（MacStories の本拠地）+ 日本**

## 実装ステップ

### Step 1: Trader Status 申告（2026-06-24 実施）

App Store Connect → Business → Trader Status → **Non-trader 選択** → Submit。

### Step 2: 各アプリの Availability 設定

Bundle ID `com.idogawa.Asobi` 登録後、アプリレコード作成時に：

1. App Store Connect → アプリ → Pricing and Availability
2. Availability で「Specific Territories」を選択
3. **EU 27 ヶ国を除外**: AT / BE / BG / HR / CY / CZ / DK / EE / FI / FR / DE / GR / HU / IE / IT / LV / LT / LU / MT / NL / PL / PT / RO / SK / SI / ES / SE
4. 配信継続: JP / US / CA / GB / AU / NZ / その他 100+ 国

## 将来の EU 配信解禁判断

以下の条件のいずれかが満たされたら、EU 配信解禁 + Trader 切替を再検討：

- 米国 / 日本市場で月収 ¥3 万円達成（私書箱費用 ¥12-60K/年を吸収できる経済性）
- EU 圏メディアからの取材オファー（Featuring Nomination 海外採択時）
- 海外旅行 / 国際カンファレンス出席等で物理的に EU 圏での営業活動が発生

再検討時の判断軸：

- 自宅住所公開 vs 私書箱費用の Trade-off
- Trader 切替手続きの所要時間（App Store Connect 検証 1-2 週間）
- 「個人ブランド分離」原則の維持

## 関連 docs

- `docs/business/retirement-line.md` 撤退ライン（売上判定基準）
- `docs/roadmap/v1.1-spec.md` v1.1 IAP 解禁計画
- `docs/marketing/q4-roadmap.md` 季節 deck 有料化計画
- `docs/secrets-inventory.html` 機密管理（私書箱契約時に追加）

## 関連 memory

- [[feedback_zero_cost_start]] 売上着金後でないと費用案件は着手しない
- [[feedback_no_company_names]] 対外発信で他事業社名 NG
- [[project_asobi_research_findings]] 3 回外部リサーチ確定事項
