import Foundation
import SwiftUI

enum Reaction: String, Codable {
    case liked
    case disliked
}

struct FeedbackEntry: Codable, Identifiable {
    let id: UUID
    let gameId: String
    let reaction: Reaction
    let sceneId: String
    let timestamp: Date

    init(gameId: String, reaction: Reaction, sceneId: String) {
        self.id = UUID()
        self.gameId = gameId
        self.reaction = reaction
        self.sceneId = sceneId
        self.timestamp = Date()
    }
}

@Observable
final class FeedbackStore {
    private let entriesKey = "asobi.feedback.v1"
    private let favoritesKey = "asobi.favorites.v1"
    private let favoriteOrderKey = "asobi.favorites.order.v1"
    var entries: [FeedbackEntry] = []
    var favoriteGameIds: Set<String> = []
    /// ユーザーが指定した表示順。Set とは独立に持ち、UI 側で並び替え可能にする。
    /// 既存 Set には含まれるが order に無い id は末尾に補完される。
    var favoriteOrder: [String] = []

    init() {
        load()
    }

    func load() {
        if let data = UserDefaults.standard.data(forKey: entriesKey),
           let decoded = try? JSONDecoder().decode([FeedbackEntry].self, from: data) {
            entries = decoded
        }
        if let data = UserDefaults.standard.data(forKey: favoritesKey),
           let decoded = try? JSONDecoder().decode([String].self, from: data) {
            favoriteGameIds = Set(decoded)
        }
        if let data = UserDefaults.standard.data(forKey: favoriteOrderKey),
           let decoded = try? JSONDecoder().decode([String].self, from: data) {
            favoriteOrder = decoded
        }
        reconcileFavoriteOrder()
    }

    func saveEntries() {
        if let data = try? JSONEncoder().encode(entries) {
            UserDefaults.standard.set(data, forKey: entriesKey)
        }
    }

    func saveFavorites() {
        if let data = try? JSONEncoder().encode(Array(favoriteGameIds)) {
            UserDefaults.standard.set(data, forKey: favoritesKey)
        }
        if let data = try? JSONEncoder().encode(favoriteOrder) {
            UserDefaults.standard.set(data, forKey: favoriteOrderKey)
        }
    }

    /// favoriteOrder と favoriteGameIds の整合性を取る。
    /// - Set にあるが order に無い id は末尾に追加
    /// - order にあるが Set に無い id は削除
    private func reconcileFavoriteOrder() {
        favoriteOrder.removeAll { !favoriteGameIds.contains($0) }
        for id in favoriteGameIds where !favoriteOrder.contains(id) {
            favoriteOrder.append(id)
        }
    }

    /// ユーザー操作による並び替え。`onMove` から呼ぶ。
    func moveFavorite(from source: IndexSet, to destination: Int) {
        favoriteOrder.move(fromOffsets: source, toOffset: destination)
        saveFavorites()
    }

    /// 端末ローカルに保持する反応履歴の上限。UserDefaults の容量肥大化を防ぐ。
    /// 古いものから head trim する FIFO 風運用。
    static let entriesLimit = 500

    func record(gameId: String, reaction: Reaction, sceneId: String) {
        entries.removeAll { $0.gameId == gameId && $0.sceneId == sceneId }
        entries.append(FeedbackEntry(gameId: gameId, reaction: reaction, sceneId: sceneId))
        if entries.count > Self.entriesLimit {
            entries.removeFirst(entries.count - Self.entriesLimit)
        }
        saveEntries()
    }

    func reaction(for gameId: String, in sceneId: String) -> Reaction? {
        entries.first { $0.gameId == gameId && $0.sceneId == sceneId }?.reaction
    }

    var dislikedGameIds: Set<String> {
        Set(entries.filter { $0.reaction == .disliked }.map { $0.gameId })
    }

    func toggleFavorite(gameId: String) {
        if favoriteGameIds.contains(gameId) {
            favoriteGameIds.remove(gameId)
            favoriteOrder.removeAll { $0 == gameId }
        } else {
            favoriteGameIds.insert(gameId)
            favoriteOrder.append(gameId)
        }
        saveFavorites()
    }

    func isFavorite(_ gameId: String) -> Bool {
        favoriteGameIds.contains(gameId)
    }
}
