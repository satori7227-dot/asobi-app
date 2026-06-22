import SwiftUI

/// コレクション一覧画面。新規作成・改名・削除・中身の閲覧を担う。
struct CollectionsView: View {
    @Environment(CollectionStore.self) private var store
    @Environment(GameRepository.self) private var repo
    @Environment(\.dismiss) private var dismiss
    @State private var newName: String = ""
    @State private var showCreate = false
    @State private var renaming: GameCollection?
    @State private var renameDraft: String = ""

    var body: some View {
        NavigationStack {
            Group {
                if store.collections.isEmpty {
                    ContentUnavailableView(
                        "コレクションがありません",
                        systemImage: "rectangle.stack",
                        description: Text("「家飲み定番」「同窓会向け」など、用途別にお気に入りを束ねられます")
                    )
                } else {
                    List {
                        ForEach(store.sorted) { collection in
                            NavigationLink {
                                CollectionDetailView(collection: collection)
                            } label: {
                                HStack {
                                    Image(systemName: "rectangle.stack.fill")
                                        .foregroundStyle(.tint)
                                    VStack(alignment: .leading) {
                                        Text(collection.name).font(.headline)
                                        Text("\(collection.gameIds.count) 件")
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                    }
                                }
                            }
                            .swipeActions(edge: .trailing) {
                                Button(role: .destructive) {
                                    store.delete(collection.id)
                                } label: {
                                    Label("削除", systemImage: "trash")
                                }
                                Button {
                                    renameDraft = collection.name
                                    renaming = collection
                                } label: {
                                    Label("名前を変更", systemImage: "pencil")
                                }
                                .tint(.orange)
                            }
                        }
                    }
                }
            }
            .navigationTitle("コレクション")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("閉じる") { dismiss() }
                }
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        newName = ""
                        showCreate = true
                    } label: {
                        Label("新規", systemImage: "plus")
                    }
                }
            }
            .alert("新しいコレクション", isPresented: $showCreate) {
                TextField("例：家飲み定番", text: $newName)
                Button("作成") {
                    let trimmed = newName.trimmingCharacters(in: .whitespacesAndNewlines)
                    if !trimmed.isEmpty { store.create(name: trimmed) }
                }
                Button("キャンセル", role: .cancel) {}
            }
            .alert("名前を変更", isPresented: Binding(
                get: { renaming != nil },
                set: { if !$0 { renaming = nil } }
            )) {
                TextField("名前", text: $renameDraft)
                Button("保存") {
                    if let id = renaming?.id {
                        let trimmed = renameDraft.trimmingCharacters(in: .whitespacesAndNewlines)
                        if !trimmed.isEmpty { store.rename(id, to: trimmed) }
                    }
                    renaming = nil
                }
                Button("キャンセル", role: .cancel) { renaming = nil }
            }
        }
    }
}

private struct CollectionDetailView: View {
    let collection: GameCollection
    @Environment(GameRepository.self) private var repo
    @Environment(CollectionStore.self) private var store
    @State private var selectedGame: Game?

    var games: [Game] {
        repo.games.filter { collection.gameIds.contains($0.id) }
    }

    var body: some View {
        Group {
            if games.isEmpty {
                ContentUnavailableView(
                    "このコレクションは空です",
                    systemImage: "tray",
                    description: Text("ゲーム詳細から「コレクションに追加」でここに集まります")
                )
            } else {
                List {
                    ForEach(games) { game in
                        Button {
                            selectedGame = game
                        } label: {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(game.displayName).font(.headline)
                                Text(game.displaySummary)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                    .lineLimit(2)
                            }
                            .padding(.vertical, 4)
                        }
                        .foregroundStyle(Color.primary)
                        .swipeActions(edge: .trailing) {
                            Button(role: .destructive) {
                                store.toggle(gameId: game.id, in: collection.id)
                            } label: {
                                Label("外す", systemImage: "minus.circle")
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle(collection.name)
        .navigationBarTitleDisplayMode(.inline)
        .sheet(item: $selectedGame) { game in
            let scene = GameScene.initial.first { game.scenes.contains($0.id) }
                ?? GameScene.initial[0]
            GameDetailView(game: game, scene: scene)
                .presentationDetents([.medium, .large])
        }
    }
}

/// 単一ゲームを複数コレクションに割り振るためのシート。
/// GameDetailView から呼び出す想定。
struct AddToCollectionSheet: View {
    let gameId: String
    @Environment(CollectionStore.self) private var store
    @Environment(\.dismiss) private var dismiss
    @State private var newName: String = ""

    /// recently-used 履歴に含まれるコレクション。
    private var recentCollections: [GameCollection] {
        let lookup = Dictionary(uniqueKeysWithValues: store.collections.map { ($0.id, $0) })
        return store.recentlyUsedIds.compactMap { lookup[$0] }
    }

    /// 「すべて」セクション。recently-used に出ているものは除外し、残りを sorted 順で。
    private var remainingCollections: [GameCollection] {
        let recentSet = Set(store.recentlyUsedIds)
        return store.sorted.filter { !recentSet.contains($0.id) }
    }

    @ViewBuilder
    private func collectionRow(_ collection: GameCollection) -> some View {
        Button {
            store.toggle(gameId: gameId, in: collection.id)
            Haptics.success()
        } label: {
            HStack {
                Text(collection.name)
                Spacer()
                if store.contains(gameId: gameId, in: collection.id) {
                    Image(systemName: "checkmark")
                        .foregroundStyle(.tint)
                }
            }
        }
        .foregroundStyle(Color.primary)
    }

    var body: some View {
        NavigationStack {
            List {
                if !recentCollections.isEmpty {
                    Section("最近使った") {
                        ForEach(recentCollections) { collection in
                            collectionRow(collection)
                        }
                    }
                }
                if !remainingCollections.isEmpty {
                    Section("すべて") {
                        ForEach(remainingCollections) { collection in
                            collectionRow(collection)
                        }
                    }
                }
                Section("新規作成して追加") {
                    HStack {
                        TextField("例：家飲み定番", text: $newName)
                        Button("追加") {
                            let trimmed = newName.trimmingCharacters(in: .whitespacesAndNewlines)
                            guard !trimmed.isEmpty else { return }
                            let new = store.create(name: trimmed)
                            store.toggle(gameId: gameId, in: new.id)
                            newName = ""
                            Haptics.success()
                        }
                        .disabled(newName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    }
                }
            }
            .navigationTitle("コレクションに追加")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("完了") { dismiss() }
                }
            }
        }
    }
}
