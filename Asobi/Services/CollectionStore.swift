import Foundation
import SwiftUI

/// お気に入りゲームをユーザー命名コレクション（「家飲み定番」「同窓会向け」等）に
/// グループ化するためのストア。SwiftData は使わず Codable + @AppStorage で軽量実装。
/// 1ゲームは複数コレクションに所属可能。
struct GameCollection: Identifiable, Codable, Hashable {
    let id: UUID
    var name: String
    var gameIds: [String]
    var createdAt: Date
    /// 表示順
    var sortOrder: Int

    init(id: UUID = UUID(), name: String, gameIds: [String] = [], sortOrder: Int = 0) {
        self.id = id
        self.name = name
        self.gameIds = gameIds
        self.createdAt = Date()
        self.sortOrder = sortOrder
    }
}

@Observable
final class CollectionStore {
    private(set) var collections: [GameCollection] = []
    /// 直近に何かを追加 / 削除したコレクション id を先頭側に保持する短縮履歴（最大 5 件）。
    /// AddToCollectionSheet の「最近使った」セクションで参照する。
    private(set) var recentlyUsedIds: [UUID] = []
    private static let recentLimit = 5

    init() {
        load()
    }

    func load() {
        if let data = UserDefaults.standard.data(forKey: AppStorageKeys.collections) {
            do {
                collections = try JSONDecoder().decode([GameCollection].self, from: data)
            } catch {
                AsobiLogger.data.error("CollectionStore decode failed: \(error.localizedDescription, privacy: .public)")
                collections = []
            }
        }
        if let data = UserDefaults.standard.data(forKey: AppStorageKeys.recentCollectionIds),
           let decoded = try? JSONDecoder().decode([UUID].self, from: data) {
            // 既に削除されたコレクションは除外
            let valid = Set(collections.map(\.id))
            recentlyUsedIds = decoded.filter { valid.contains($0) }
        }
    }

    func save() {
        do {
            let data = try JSONEncoder().encode(collections)
            UserDefaults.standard.set(data, forKey: AppStorageKeys.collections)
        } catch {
            AsobiLogger.data.error("CollectionStore encode failed: \(error.localizedDescription, privacy: .public)")
        }
        if let data = try? JSONEncoder().encode(recentlyUsedIds) {
            UserDefaults.standard.set(data, forKey: AppStorageKeys.recentCollectionIds)
        }
    }

    /// 指定 id を recently-used 履歴の先頭に押し上げる（既存があれば移動）。
    private func touchRecent(_ id: UUID) {
        recentlyUsedIds.removeAll { $0 == id }
        recentlyUsedIds.insert(id, at: 0)
        if recentlyUsedIds.count > Self.recentLimit {
            recentlyUsedIds = Array(recentlyUsedIds.prefix(Self.recentLimit))
        }
    }

    /// 表示用：sortOrder と createdAt でソート済み
    var sorted: [GameCollection] {
        collections.sorted { a, b in
            if a.sortOrder != b.sortOrder { return a.sortOrder < b.sortOrder }
            return a.createdAt < b.createdAt
        }
    }

    /// 新規作成。
    /// 空文字や空白だけの名前は弾いて nil を返す（UI 側の保険）。
    @discardableResult
    func create(name: String) -> GameCollection {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        // 完全に空の場合だけ「無名コレクション」をデフォルト名として割り当てる。
        // ストアとしてはエラーで落とさず、UI が想定外を渡しても破綻しない設計。
        let resolved = trimmed.isEmpty ? "無名コレクション" : trimmed
        let next = (collections.map(\.sortOrder).max() ?? -1) + 1
        let collection = GameCollection(name: resolved, sortOrder: next)
        collections.append(collection)
        save()
        return collection
    }

    func delete(_ id: UUID) {
        collections.removeAll { $0.id == id }
        recentlyUsedIds.removeAll { $0 == id }
        save()
    }

    func rename(_ id: UUID, to newName: String) {
        guard let idx = collections.firstIndex(where: { $0.id == id }) else { return }
        collections[idx].name = newName
        save()
    }

    /// 指定コレクションへの所属を toggle。
    /// 操作したコレクションは recently-used 履歴の先頭に上がる。
    func toggle(gameId: String, in collectionId: UUID) {
        guard let idx = collections.firstIndex(where: { $0.id == collectionId }) else { return }
        if let pos = collections[idx].gameIds.firstIndex(of: gameId) {
            collections[idx].gameIds.remove(at: pos)
        } else {
            collections[idx].gameIds.append(gameId)
        }
        touchRecent(collectionId)
        save()
    }

    func contains(gameId: String, in collectionId: UUID) -> Bool {
        guard let collection = collections.first(where: { $0.id == collectionId }) else { return false }
        return collection.gameIds.contains(gameId)
    }

    /// 指定ゲームを含むコレクション一覧。
    func collectionsContaining(gameId: String) -> [GameCollection] {
        collections.filter { $0.gameIds.contains(gameId) }
    }
}
