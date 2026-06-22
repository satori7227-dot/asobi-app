import SwiftUI

struct FavoritesView: View {
    @Environment(GameRepository.self) private var repo
    @Environment(FeedbackStore.self) private var feedback
    @Environment(\.dismiss) private var dismiss
    @State private var selectedGame: Game?
    @State private var addToCollectionGame: Game?

    /// FeedbackStore.favoriteOrder の順に並べた Game 配列。
    /// 復元できない id（DB から消えたゲーム）はスキップ。
    private var favoriteGames: [Game] {
        let byId = Dictionary(uniqueKeysWithValues: repo.games.map { ($0.id, $0) })
        return feedback.favoriteOrder.compactMap { byId[$0] }
    }

    var body: some View {
        NavigationStack {
            Group {
                if favoriteGames.isEmpty {
                    ContentUnavailableView(
                        "お気に入りはまだありません",
                        systemImage: "star",
                        description: Text("ゲーム詳細画面の星ボタンで追加できます")
                    )
                } else {
                    List {
                        ForEach(favoriteGames) { game in
                            Button {
                                selectedGame = game
                            } label: {
                                FavoriteCard(game: game)
                            }
                            .buttonStyle(.plain)
                            .listRowSeparator(.hidden)
                            .listRowBackground(Color.clear)
                            .listRowInsets(EdgeInsets(top: 7, leading: 16, bottom: 7, trailing: 16))
                            .swipeActions(edge: .trailing) {
                                Button(role: .destructive) {
                                    feedback.toggleFavorite(gameId: game.id)
                                } label: {
                                    Label("外す", systemImage: "star.slash")
                                }
                            }
                            .swipeActions(edge: .leading) {
                                Button {
                                    addToCollectionGame = game
                                } label: {
                                    Label("コレクションに追加", systemImage: "rectangle.stack.badge.plus")
                                }
                                .tint(.blue)
                            }
                            .contextMenu {
                                Button {
                                    addToCollectionGame = game
                                } label: {
                                    Label("コレクションに追加", systemImage: "rectangle.stack.badge.plus")
                                }
                                Button(role: .destructive) {
                                    feedback.toggleFavorite(gameId: game.id)
                                } label: {
                                    Label("お気に入りから外す", systemImage: "star.slash")
                                }
                            }
                        }
                        .onMove { source, dest in
                            feedback.moveFavorite(from: source, to: dest)
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("お気に入り")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    // 編集モードに切り替えると ForEach.onMove のドラッグハンドルが出る。
                    if !favoriteGames.isEmpty {
                        EditButton()
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("閉じる") { dismiss() }
                }
            }
            .sheet(item: $selectedGame) { game in
                let scene = GameScene.initial.first { game.scenes.contains($0.id) }
                    ?? GameScene.initial[0]
                GameDetailView(game: game, scene: scene)
                    .presentationDetents([.medium, .large])
            }
            .sheet(item: $addToCollectionGame) { game in
                AddToCollectionSheet(gameId: game.id)
            }
        }
    }
}

private struct FavoriteCard: View {
    let game: Game

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .top) {
                Text(game.displayName).font(.title3.weight(.bold))
                Spacer()
                Image(systemName: "star.fill")
                    .foregroundStyle(.yellow)
            }
            Text(game.displaySummary)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .lineLimit(2)
            HStack(spacing: 6) {
                Text("\(game.minPlayers)〜\(game.maxPlayers)人")
                    .font(.caption.weight(.semibold))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(.thinMaterial, in: Capsule())
            }
        }
        .padding()
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 20))
    }
}
