import SwiftUI

struct ProposalView: View {
    let scene: GameScene
    let context: ProposalContext
    @Environment(GameRepository.self) private var repo
    @Environment(FeedbackStore.self) private var feedback
    @Environment(\.dismiss) private var dismiss
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var games: [Game] = []
    @State private var visible = false
    @State private var selectedGame: Game?

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                SceneHeader(scene: scene)
                    .padding(.horizontal)

                ContextChipsBar(scene: scene, context: context) {
                    dismiss()
                }

                if games.isEmpty {
                    ContentUnavailableView(
                        "候補が見つかりません",
                        systemImage: "questionmark.diamond",
                        description: Text("条件を変えて、もう一度試してみてください")
                    )
                    .padding(.top, 60)
                } else {
                    VStack(spacing: 14) {
                        ForEach(Array(games.enumerated()), id: \.element.id) { index, game in
                            GameCard(game: game, scene: scene)
                                .contentShape(RoundedRectangle(cornerRadius: 20))
                                .onTapGesture { selectedGame = game }
                                .opacity(visible ? 1 : 0)
                                .offset(y: visible || reduceMotion ? 0 : 24)
                                .animation(
                                    reduceMotion
                                        ? .none
                                        : .spring(duration: 0.55).delay(Double(index) * 0.12),
                                    value: visible
                                )
                        }
                    }
                    .padding(.horizontal)
                }

                Button {
                    refresh()
                } label: {
                    Label("もう一度シャッフル", systemImage: "arrow.triangle.2.circlepath")
                        .font(.subheadline.weight(.semibold))
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                        .background(.regularMaterial, in: Capsule())
                }
                .padding(.top, 8)
                .accessibilityIdentifier("proposal-shuffle-button")
            }
            .padding(.vertical)
        }
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { refresh() }
        .sheet(item: $selectedGame) { game in
            GameDetailView(game: game, scene: scene)
                .presentationDetents([.medium, .large])
        }
    }

    private func refresh() {
        let proposed = repo.propose(
            scene: scene,
            context: context,
            excluding: feedback.dislikedGameIds
        )
        visible = false
        games = proposed
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            visible = true
        }
    }
}

private struct GameCard: View {
    let game: Game
    let scene: GameScene

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .top) {
                Text(game.displayName)
                    .font(.title3.weight(.bold))
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundStyle(.tertiary)
            }
            Text(game.displaySummary)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .lineLimit(2)
            HStack(spacing: 8) {
                Tag(text: durationText(game.duration), color: scene.accent)
                Tag(text: "\(game.minPlayers)〜\(game.maxPlayers)人", color: scene.accent)
                if !game.items.isEmpty {
                    Tag(text: "道具あり", color: scene.accent)
                }
            }
        }
        .padding()
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 20))
    }

    private func durationText(_ d: String) -> String {
        switch d {
        case "short":  return "5分未満"
        case "medium": return "5〜15分"
        case "long":   return "15分以上"
        default:       return d
        }
    }
}

private struct Tag: View {
    let text: String
    let color: Color
    var body: some View {
        Text(text)
            .font(.caption.weight(.semibold))
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(color.opacity(0.15), in: Capsule())
            .foregroundStyle(color)
    }
}
