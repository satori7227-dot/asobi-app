import Foundation

/// ゲーム1件のデータモデル。`games.json` から JSONDecoder でロードされる。
///
/// UI 表示の方針:
/// - **画面に出すときは必ず `displayName` / `displaySummary` / `displayRules` を使うこと。**
/// - 生の `name` / `summary` / `rules` を `Text(...)` に渡すと、英語ロケール端末で
///   nameEn が埋まっているゲームでも日本語表示になり、多言語化が破綻する。
/// - 検索・フィルタ・ログ用途で raw な日本語が必要な場合は直接 `name` を参照してよい。
struct Game: Identifiable, Codable, Hashable {
    let id: String
    let name: String
    let summary: String
    let rules: String
    let scenes: [String]
    let minPlayers: Int
    let maxPlayers: Int
    let tension: [String]
    let duration: String
    let items: [String]
    /// "ja"（既定）または "en"（海外由来）。
    /// "en" の場合は nameEn / summaryEn / rulesEn が埋まっていれば英語ロケールで優先表示する。
    let sourceLang: String? = nil
    let nameEn: String? = nil
    let summaryEn: String? = nil
    let rulesEn: String? = nil

    /// 端末ロケールに応じた表示用 name。en 端末でかつ nameEn があれば英語、それ以外は日本語。
    /// **UI 表示はこのプロパティを使うこと。** 直接 name を読むと多言語化が破綻する。
    var displayName: String {
        if preferEnglish, let value = nameEn, !value.isEmpty { return value }
        return name
    }

    /// 端末ロケールに応じた表示用 summary。**UI 表示はこのプロパティを使うこと。**
    var displaySummary: String {
        if preferEnglish, let value = summaryEn, !value.isEmpty { return value }
        return summary
    }

    /// 端末ロケールに応じた表示用 rules。**UI 表示はこのプロパティを使うこと。**
    var displayRules: String {
        if preferEnglish, let value = rulesEn, !value.isEmpty { return value }
        return rules
    }

    private var preferEnglish: Bool {
        let lang = Locale.preferredLanguages.first ?? "ja"
        return lang.lowercased().hasPrefix("en")
    }

    static let appProvidedItems: Set<String> = [
        "サイコロ", "サイコロ5個", "サイコロ6個",
        "コイン",
        "トランプ",
        "タイマー", "ストップウォッチ",
        "お題カード", "お題リスト",
        "役職カード",
        "王様ゲームのくじ", "王様ゲームのくじ（紙でも可）",
        "質問リスト",
        "スマホ", "スマホメモ",
        "紙またはスマホメモ",
        "音楽", "音楽プレーヤー",
    ]

    var physicalItems: [String] {
        items.filter { !Self.appProvidedItems.contains($0) }
    }

    var hasAppProvidedItem: Bool {
        items.contains { Self.appProvidedItems.contains($0) }
    }

    func matches(scene: GameScene, context: ProposalContext) -> Bool {
        guard scenes.contains(scene.id) else { return false }
        guard context.playerCount >= minPlayers, context.playerCount <= maxPlayers else { return false }
        guard tension.contains(context.tension.rawValue) else { return false }
        if context.noItemsOnly && !physicalItems.isEmpty { return false }
        if duration != context.duration.rawValue {
            return tolerantDurationMatch(target: context.duration.rawValue)
        }
        return true
    }

    private func tolerantDurationMatch(target: String) -> Bool {
        let order = ["short", "medium", "long"]
        guard let mine = order.firstIndex(of: duration),
              let want = order.firstIndex(of: target) else { return false }
        return abs(mine - want) <= 1
    }
}
