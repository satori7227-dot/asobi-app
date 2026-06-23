import SwiftUI

struct GameDetailView: View {
    static let favoriteMilestones: Set<Int> = [5, 10, 20]

    let game: Game
    let scene: GameScene
    @Environment(FeedbackStore.self) private var feedback
    @Environment(ReviewPromptManager.self) private var reviewPrompt
    @Environment(PlayCountStore.self) private var playCount
    @Environment(\.dismiss) private var dismiss
    @State private var likeBounce = 0
    @State private var dislikeBounce = 0
    @State private var selectedTool: ToolsetView.ToolKind?

    /// このゲームに関連するツール。判定ロジックは ToolsetView.ToolKind.relevant(for:) に集約。
    private var relevantTools: [ToolsetView.ToolKind] {
        ToolsetView.ToolKind.relevant(for: game)
    }

    /// ShareLink で配布する Deep Link URL。受信側のアプリは asobi://game/<id> を
    /// DeepLinkRouter で解釈してゲーム詳細を直接開く。
    private var shareURL: URL {
        URL(string: "asobi://game/\(game.id)") ?? URL(string: "asobi://")!
    }

    /// 共有テキスト本文。アプリ未インストール時の受け手にも何のゲームか伝わるよう、
    /// 名前と一行要約を含めておく。
    private var shareMessage: String {
        "\(game.displayName) — \(game.displaySummary)"
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    HStack(spacing: 8) {
                        Image(systemName: scene.symbolName).foregroundStyle(scene.accent)
                        Text(scene.localizedName).font(.subheadline).foregroundStyle(.secondary)
                    }

                    Text(game.displayName).font(.largeTitle.weight(.heavy))
                    Text(game.displaySummary).font(.title3).foregroundStyle(.secondary)

                    Divider()

                    sectionBlock("ルール") {
                        Text(game.displayRules)
                            .font(.body)
                            .lineSpacing(4)
                    }

                    sectionBlock("人数") {
                        Text("\(game.minPlayers)〜\(game.maxPlayers)人").font(.body)
                    }

                    if !relevantTools.isEmpty {
                        sectionBlock("使えるツール") {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 12) {
                                    ForEach(relevantTools) { tool in
                                        Button {
                                            selectedTool = tool
                                        } label: {
                                            VStack(spacing: 6) {
                                                Image(systemName: tool.symbol)
                                                    .font(.system(size: 24))
                                                Text(tool.displayName)
                                                    .font(.caption.weight(.semibold))
                                            }
                                            .frame(width: 84, height: 84)
                                            .background(tool.accent.opacity(0.15), in: RoundedRectangle(cornerRadius: 16))
                                            .foregroundStyle(tool.accent)
                                        }
                                        .buttonStyle(.plain)
                                    }
                                }
                            }
                        }
                    }

                    if !game.items.isEmpty {
                        sectionBlock("必要なもの") {
                            VStack(alignment: .leading, spacing: 6) {
                                ForEach(game.items, id: \.self) { item in
                                    HStack(spacing: 8) {
                                        let isApp = Game.appProvidedItems.contains(item)
                                        Image(systemName: isApp ? "iphone" : "circle.fill")
                                            .font(.system(size: isApp ? 12 : 6))
                                            .foregroundStyle(isApp ? Color.accentColor : .secondary)
                                        Text(item)
                                        if isApp {
                                            Text("アプリで対応")
                                                .font(.caption2.weight(.semibold))
                                                .padding(.horizontal, 6)
                                                .padding(.vertical, 2)
                                                .background(Color.accentColor.opacity(0.15), in: Capsule())
                                                .foregroundStyle(Color.accentColor)
                                        }
                                    }
                                }
                            }
                        }
                    }

                    HStack(spacing: 16) {
                        reactionButton(.disliked, label: "ちがう", symbol: "hand.thumbsdown.fill", bounceValue: dislikeBounce)
                        reactionButton(.liked,    label: "やる！", symbol: "hand.thumbsup.fill",   bounceValue: likeBounce)
                    }
                    .padding(.top)
                }
                .padding()
            }
            .navigationTitle("ゲーム詳細")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        Haptics.medium()
                        let wasFavorite = feedback.isFavorite(game.id)
                        withAnimation(.spring(duration: 0.3)) {
                            feedback.toggleFavorite(gameId: game.id)
                        }
                        // 追加した瞬間に累計が milestone を踏んだら、レビュー要請のチャンス。
                        // 外した時は呼ばない。
                        if !wasFavorite {
                            let count = feedback.favoriteGameIds.count
                            if Self.favoriteMilestones.contains(count) {
                                reviewPrompt.requestReviewIfAppropriate()
                            }
                        }
                    } label: {
                        Image(systemName: feedback.isFavorite(game.id) ? "star.fill" : "star")
                            .foregroundStyle(feedback.isFavorite(game.id) ? .yellow : .secondary)
                            .symbolEffect(.bounce, value: feedback.isFavorite(game.id))
                    }
                    .accessibilityLabel(feedback.isFavorite(game.id) ? "お気に入りから外す" : "お気に入りに追加")
                    .accessibilityIdentifier("game-detail-favorite-toggle")
                }
                ToolbarItem(placement: .topBarTrailing) {
                    HStack(spacing: 8) {
                        ShareLink(
                            item: shareURL,
                            subject: Text(game.displayName),
                            message: Text(shareMessage),
                            preview: SharePreview(
                                game.displayName,
                                image: Image(systemName: scene.symbolName)
                            )
                        ) {
                            Image(systemName: "square.and.arrow.up")
                        }
                        .accessibilityLabel("共有")
                        .accessibilityIdentifier("game-detail-share-button")

                        Button("閉じる") {
                            // 体験の良い終わり方の直後にレビュー要請のチャンスを与える。
                            // 条件未達なら ReviewPromptManager 側で何もしない。
                            reviewPrompt.requestReviewIfAppropriate()
                            dismiss()
                        }
                        .accessibilityIdentifier("game-detail-close-button")
                    }
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
        .onAppear {
            playCount.recordPlay()
        }
    }

    private func reactionButton(_ reaction: Reaction, label: String, symbol: String, bounceValue: Int) -> some View {
        let current = feedback.reaction(for: game.id, in: scene.id)
        let isOn = current == reaction
        let isLike = reaction == .liked
        let activeColor: Color = isLike ? .green : .red

        return Button {
            if isLike { Haptics.success() } else { Haptics.warning() }
            feedback.record(gameId: game.id, reaction: reaction, sceneId: scene.id)
            if isLike {
                likeBounce += 1
                // 「やる！」=これから遊ぶシグナル。レビュー獲得の累計プレイ数を1件カウント。
                if current != .liked {
                    reviewPrompt.recordCompletedGame(source: .detailLiked)
                }
            } else {
                dislikeBounce += 1
            }
        } label: {
            VStack(spacing: 6) {
                Image(systemName: symbol)
                    .font(.title)
                    .symbolEffect(.bounce, value: bounceValue)
                Text(label).font(.subheadline.weight(.semibold))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                isOn ? activeColor.opacity(0.18) : Color(.secondarySystemBackground),
                in: RoundedRectangle(cornerRadius: 16)
            )
            .foregroundStyle(isOn ? activeColor : .primary)
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    private func sectionBlock<C: View>(_ title: String, @ViewBuilder content: () -> C) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
                .foregroundStyle(.secondary)
            content()
        }
    }
}
