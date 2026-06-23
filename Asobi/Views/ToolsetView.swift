import SwiftUI

struct ToolsetView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedTool: ToolKind?

    enum ToolKind: String, CaseIterable, Identifiable {
        case dice, coin, card, roulette, timer, prompt, kingGame
        var id: String { rawValue }

        var displayName: String {
            switch self {
            case .dice:     return "サイコロ"
            case .coin:     return "コイン"
            case .card:     return "トランプ"
            case .roulette: return "ルーレット"
            case .timer:    return "タイマー"
            case .prompt:   return "お題"
            case .kingGame: return "王様くじ"
            }
        }

        var localizedDisplayName: LocalizedStringKey { LocalizedStringKey(displayName) }

        var symbol: String {
            switch self {
            case .dice:     return "die.face.5.fill"
            case .coin:     return "circle.circle.fill"
            case .card:     return "suit.club.fill"
            case .roulette: return "person.crop.circle.badge.questionmark.fill"
            case .timer:    return "timer"
            case .prompt:   return "lightbulb.fill"
            case .kingGame: return "crown.fill"
            }
        }

        var accent: Color {
            switch self {
            case .dice:     return .purple
            case .coin:     return .yellow
            case .card:     return .red
            case .roulette: return .green
            case .timer:    return .orange
            case .prompt:   return .blue
            case .kingGame: return Color(red: 0.85, green: 0.65, blue: 0.13)
            }
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                    ForEach(ToolKind.allCases) { tool in
                        ToolCard(tool: tool)
                            .contentShape(RoundedRectangle(cornerRadius: 20))
                            .onTapGesture { selectedTool = tool }
                    }
                }
                .padding()
            }
            .navigationTitle("ツール")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("閉じる") { dismiss() }
                }
            }
            .sheet(item: $selectedTool) { tool in
                switch tool {
                case .dice:     DiceRollerView()
                case .coin:     CoinFlipView()
                case .card:     CardDrawView()
                case .roulette: RoulettePickerView()
                case .timer:    TimerView()
                case .prompt:   PromptGachaView()
                case .kingGame: KingGameDistributorView()
                }
            }
        }
    }
}

private struct ToolCard: View {
    let tool: ToolsetView.ToolKind

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: tool.symbol)
                .font(.system(size: 36, weight: .semibold))
                .frame(width: 64, height: 64)
                .background(tool.accent.opacity(0.18), in: Circle())
                .foregroundStyle(tool.accent)
            Text(tool.localizedDisplayName)
                .font(.headline)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 20))
    }
}

extension ToolsetView.ToolKind {
    /// `Game.items` の文字列から ToolKind に直接マップする辞書。
    private static let itemMapping: [String: ToolsetView.ToolKind] = [
        "サイコロ": .dice, "サイコロ5個": .dice, "サイコロ6個": .dice,
        "コイン": .coin, "10円玉": .coin,
        "トランプ": .card,
        "タイマー": .timer, "ストップウォッチ": .timer,
        "お題カード": .prompt, "お題リスト": .prompt, "質問リスト": .prompt,
        "役職カード": .prompt,
        "王様ゲームのくじ": .kingGame, "王様ゲームのくじ（紙でも可）": .kingGame,
    ]

    /// ゲームのテキスト（name + summary + rules）からツールを推定するキーワード辞書。
    private static let keywordMapping: [(keywords: [String], tool: ToolsetView.ToolKind)] = [
        (["サイコロ", "出目"], .dice),
        (["コイントス", "コインを", "コインの", "10円玉"], .coin),
        (["トランプ", "ジョーカー", "ババ抜き", "神経衰弱", "7並べ", "七並べ",
          "ジン・ラミー", "スピード", "ぶたのしっぽ", "ジジ抜き", "ハイ&ロー",
          "山札", "1枚めくる", "1枚引く", "1枚オープン"], .card),
        (["ルーレット", "ガチャ", "ランダム指名", "指名ゲーム", "ランダムに選",
          "ランダムに1人", "抽選", "ハズレ", "一人だけ"], .roulette),
        (["ワードウルフ", "お題", "質問", "大喜利", "ジェスチャー",
          "連想", "二択", "クイズ", "テーマを決め", "36の質問", "NGワード"], .prompt),
        (["タイマー", "制限時間", "ストップウォッチ",
          "10秒", "30秒", "60秒", "1分", "3分", "5分",
          "秒で", "秒以内", "秒間"], .timer),
        (["王様ゲーム", "王様役", "王様が"], .kingGame),
    ]

    /// 表示順序。プロンプト→ダイス→…の優先で並べる。
    private static let displayOrder: [ToolsetView.ToolKind] = [
        .prompt, .dice, .coin, .card, .roulette, .timer, .kingGame
    ]

    /// 指定ゲームに関連するツールを推定する。
    /// items の直接マッピング ∪ 本文キーワードマッチング を取って、表示順でソートする。
    static func relevant(for game: Game) -> [ToolsetView.ToolKind] {
        var set: Set<ToolsetView.ToolKind> = []
        for item in game.items {
            if let tool = itemMapping[item] { set.insert(tool) }
        }
        let text = game.name + " " + game.summary + " " + game.rules
        for (keywords, tool) in keywordMapping where keywords.contains(where: { text.contains($0) }) {
            set.insert(tool)
        }
        return displayOrder.filter { set.contains($0) }
    }
}
