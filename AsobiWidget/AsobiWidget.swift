import WidgetKit
import SwiftUI

// MARK: - 軽量データロード

/// Widget 専用の軽量ゲームデータ。本体の Game とフィールドは揃えるが、
/// Widget は本体 target に依存できないので独自に最小デコードする。
private struct WidgetGame: Decodable {
    let id: String
    let name: String
    let summary: String
    let scenes: [String]
    let minPlayers: Int
    let maxPlayers: Int
    let nameEn: String?
    let summaryEn: String?

    var displayName: String {
        if preferEnglish, let v = nameEn, !v.isEmpty { return v }
        return name
    }
    var displaySummary: String {
        if preferEnglish, let v = summaryEn, !v.isEmpty { return v }
        return summary
    }
    private var preferEnglish: Bool {
        (Locale.preferredLanguages.first ?? "ja").lowercased().hasPrefix("en")
    }
}

private enum WidgetGameLoader {
    /// Widget 自身の bundle に同梱した games.json を読む（App Group 不要）。
    static func load() -> [WidgetGame] {
        guard let url = Bundle.main.url(forResource: "games", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let games = try? JSONDecoder().decode([WidgetGame].self, from: data) else {
            return []
        }
        return games.filter { !$0.scenes.isEmpty }
    }

    /// 指定日に対して決定的にゲームを選ぶ（同じ日なら同じゲーム）。
    static func game(for date: Date, from games: [WidgetGame]) -> WidgetGame? {
        guard !games.isEmpty else { return nil }
        let day = Calendar.current.ordinality(of: .day, in: .era, for: date) ?? 0
        return games[day % games.count]
    }
}

// MARK: - Timeline

struct GameEntry: TimelineEntry {
    let date: Date
    let name: String
    let summary: String
    let players: String
    let deepLink: URL
}

struct AsobiProvider: TimelineProvider {
    private func entry(for date: Date) -> GameEntry {
        let games = WidgetGameLoader.load()
        if let g = WidgetGameLoader.game(for: date, from: games) {
            return GameEntry(
                date: date,
                name: g.displayName,
                summary: g.displaySummary,
                players: "\(g.minPlayers)〜\(g.maxPlayers)",
                deepLink: URL(string: "asobi://game/\(g.id)") ?? URL(string: "asobi://")!
            )
        }
        return GameEntry(date: date, name: "ASOBI", summary: "アプリを開いてゲームを探す", players: "", deepLink: URL(string: "asobi://")!)
    }

    func placeholder(in context: Context) -> GameEntry {
        GameEntry(date: Date(), name: "山手線ゲーム", summary: "テーマに沿って言葉を順に挙げる", players: "2〜10", deepLink: URL(string: "asobi://")!)
    }

    func getSnapshot(in context: Context, completion: @escaping (GameEntry) -> Void) {
        completion(entry(for: Date()))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<GameEntry>) -> Void) {
        // 翌日 0:00 にリフレッシュして日替わりにする。
        let now = Date()
        let startOfTomorrow = Calendar.current.startOfDay(for: now.addingTimeInterval(86_400))
        let timeline = Timeline(entries: [entry(for: now)], policy: .after(startOfTomorrow))
        completion(timeline)
    }
}

// MARK: - View

struct AsobiWidgetEntryView: View {
    @Environment(\.widgetFamily) private var family
    let entry: GameEntry

    var body: some View {
        VStack(alignment: .leading, spacing: family == .systemSmall ? 4 : 8) {
            HStack(spacing: 4) {
                Image(systemName: "sparkles")
                    .font(.caption2)
                Text("今日のゲーム")
                    .font(.caption2.weight(.semibold))
            }
            .foregroundStyle(.tint)

            Text(entry.name)
                .font(family == .systemSmall ? .headline : .title3.weight(.bold))
                .lineLimit(family == .systemSmall ? 2 : 1)

            if family != .systemSmall {
                Text(entry.summary)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }

            Spacer(minLength: 0)

            if !entry.players.isEmpty {
                Text("\(entry.players) 人")
                    .font(.caption2.weight(.medium))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(.tint.opacity(0.15), in: Capsule())
                    .foregroundStyle(.tint)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .widgetURL(entry.deepLink)
        .containerBackground(.fill.tertiary, for: .widget)
    }
}

// MARK: - Widget 定義

struct AsobiWidget: Widget {
    let kind = "AsobiWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: AsobiProvider()) { entry in
            AsobiWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("今日のゲーム")
        .description("毎日おすすめのパーティーゲームを表示します。タップで詳細へ。")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}

@main
struct AsobiWidgetBundle: WidgetBundle {
    var body: some Widget {
        AsobiWidget()
    }
}
