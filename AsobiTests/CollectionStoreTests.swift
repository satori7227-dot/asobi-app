import XCTest
@testable import Asobi

final class CollectionStoreTests: XCTestCase {
    override func setUp() {
        super.setUp()
        UserDefaults.standard.removeObject(forKey: AppStorageKeys.collections)
    }

    func testCreateAddsCollectionWithIncrementingSortOrder() {
        let store = CollectionStore()
        XCTAssertTrue(store.collections.isEmpty)
        let a = store.create(name: "家飲み定番")
        let b = store.create(name: "同窓会向け")
        XCTAssertEqual(store.collections.count, 2)
        XCTAssertEqual(a.sortOrder, 0)
        XCTAssertEqual(b.sortOrder, 1)
    }

    func testToggleAddsThenRemovesGame() {
        let store = CollectionStore()
        let c = store.create(name: "C")
        XCTAssertFalse(store.contains(gameId: "g1", in: c.id))
        store.toggle(gameId: "g1", in: c.id)
        XCTAssertTrue(store.contains(gameId: "g1", in: c.id))
        store.toggle(gameId: "g1", in: c.id)
        XCTAssertFalse(store.contains(gameId: "g1", in: c.id))
    }

    func testGameCanBelongToMultipleCollections() {
        let store = CollectionStore()
        let a = store.create(name: "A")
        let b = store.create(name: "B")
        store.toggle(gameId: "g1", in: a.id)
        store.toggle(gameId: "g1", in: b.id)
        let found = store.collectionsContaining(gameId: "g1")
        XCTAssertEqual(Set(found.map(\.id)), Set([a.id, b.id]))
    }

    func testRenameUpdatesName() {
        let store = CollectionStore()
        let c = store.create(name: "Original")
        store.rename(c.id, to: "Renamed")
        XCTAssertEqual(store.collections.first { $0.id == c.id }?.name, "Renamed")
    }

    func testDeleteRemovesCollection() {
        let store = CollectionStore()
        let c = store.create(name: "X")
        store.delete(c.id)
        XCTAssertTrue(store.collections.isEmpty)
    }

    func testPersistsAcrossInstances() {
        let store1 = CollectionStore()
        let c = store1.create(name: "Persisted")
        store1.toggle(gameId: "gP", in: c.id)
        let store2 = CollectionStore()
        XCTAssertEqual(store2.collections.count, 1)
        XCTAssertTrue(store2.contains(gameId: "gP", in: c.id))
    }

    /// 削除した跡地が sortOrder に穴を作るが、次に create したら最大+1 で番号が進む。
    /// 連番強制ではないが、後方に追加されることを保証する。
    func testCreateAfterDeleteKeepsMonotonicSortOrder() {
        let store = CollectionStore()
        _ = store.create(name: "A") // 0
        let b = store.create(name: "B") // 1
        let c = store.create(name: "C") // 2
        store.delete(b.id)
        let d = store.create(name: "D")
        XCTAssertEqual(d.sortOrder, 3, "削除しても最大+1 で進む（穴埋めしない）")
        XCTAssertGreaterThan(d.sortOrder, c.sortOrder)
    }

    /// sortOrder 順で並び、create 順と一致することの確認。
    /// create() 経由で常に 0→1→2 と単調増加するので、sorted は create 順と一致する。
    func testSortedMatchesCreationOrder() {
        let store = CollectionStore()
        let a = store.create(name: "A")
        let b = store.create(name: "B")
        let c = store.create(name: "C")
        XCTAssertEqual(store.sorted.map(\.id), [a.id, b.id, c.id])
    }

    /// 100 件の create + toggle が破綻なく走り、persist→reload で全件復元できる。
    func testHandlesLargeNumberOfCollectionsAndPersistsThem() {
        let store1 = CollectionStore()
        for i in 0..<100 {
            let c = store1.create(name: "C\(i)")
            store1.toggle(gameId: "g\(i)", in: c.id)
            store1.toggle(gameId: "g-shared", in: c.id)
        }
        XCTAssertEqual(store1.collections.count, 100)
        let store2 = CollectionStore()
        XCTAssertEqual(store2.collections.count, 100)
        // 共有ゲームは 100 個のコレクション全てに所属
        XCTAssertEqual(store2.collectionsContaining(gameId: "g-shared").count, 100)
    }

    /// rename を空文字や空白だけの文字列で行っても、ストア側は変更を受け付ける（弾くのは呼び出し側責務）。
    /// 振る舞いを固定化することで、UI 側のバリデーションを明示的に強制できる。
    func testRenameAcceptsEmptyString() {
        let store = CollectionStore()
        let c = store.create(name: "Original")
        store.rename(c.id, to: "")
        XCTAssertEqual(store.collections.first?.name, "")
    }

    /// 存在しない id の rename / delete / toggle は no-op で例外を投げない。
    func testOperationsOnMissingIdAreNoOp() {
        let store = CollectionStore()
        _ = store.create(name: "Real")
        let bogus = UUID()
        // どれも crash せず、件数も変わらない
        store.rename(bogus, to: "X")
        store.delete(bogus)
        store.toggle(gameId: "g", in: bogus)
        XCTAssertEqual(store.collections.count, 1)
    }

    /// 同じゲームを同じコレクションに二度 toggle すると、最終的に gameIds から消えるべき。
    /// 一度入れて一度抜く＝対称的に振る舞う。
    func testToggleIsSymmetric() {
        let store = CollectionStore()
        let c = store.create(name: "X")
        store.toggle(gameId: "g", in: c.id)
        store.toggle(gameId: "g", in: c.id)
        XCTAssertFalse(store.contains(gameId: "g", in: c.id))
        XCTAssertEqual(store.collections.first?.gameIds.count, 0)
    }

    /// toggle 操作のたびに recentlyUsedIds が先頭に押し上げられる。
    func testToggleUpdatesRecentlyUsed() {
        let store = CollectionStore()
        let a = store.create(name: "A")
        let b = store.create(name: "B")
        let c = store.create(name: "C")
        store.toggle(gameId: "g", in: a.id)
        store.toggle(gameId: "g", in: b.id)
        store.toggle(gameId: "g", in: c.id)
        XCTAssertEqual(store.recentlyUsedIds, [c.id, b.id, a.id], "最後に触ったものが先頭")
    }

    /// recentlyUsedIds は同じ id を重複して持たない（移動 = remove + insert(0)）。
    func testRecentlyUsedDoesNotDuplicate() {
        let store = CollectionStore()
        let a = store.create(name: "A")
        let b = store.create(name: "B")
        store.toggle(gameId: "g1", in: a.id)
        store.toggle(gameId: "g2", in: b.id)
        store.toggle(gameId: "g3", in: a.id)  // a を再度触る
        XCTAssertEqual(store.recentlyUsedIds, [a.id, b.id])
    }

    /// 履歴上限は 5 件。それを超えると古い順に押し出される。
    func testRecentlyUsedHasUpperLimit() {
        let store = CollectionStore()
        let ids = (0..<7).map { _ in store.create(name: "C").id }
        for id in ids {
            store.toggle(gameId: "g", in: id)
        }
        XCTAssertEqual(store.recentlyUsedIds.count, 5)
        // 最新 5 件＝ ids の後ろ 5 件が逆順で並ぶ
        XCTAssertEqual(store.recentlyUsedIds.first, ids.last)
    }

    /// 削除されたコレクションは履歴からも消える。
    func testDeleteRemovesFromRecentlyUsed() {
        let store = CollectionStore()
        let a = store.create(name: "A")
        store.toggle(gameId: "g", in: a.id)
        XCTAssertTrue(store.recentlyUsedIds.contains(a.id))
        store.delete(a.id)
        XCTAssertFalse(store.recentlyUsedIds.contains(a.id))
    }

    /// 空文字名で create するとデフォルト名「無名コレクション」が割り当てられる。
    func testCreateEmptyNameFallsBackToDefault() {
        let store = CollectionStore()
        let c = store.create(name: "")
        XCTAssertEqual(c.name, "無名コレクション")
    }

    /// 空白だけでもデフォルト名にフォールバック。
    func testCreateWhitespaceOnlyNameFallsBackToDefault() {
        let store = CollectionStore()
        let c = store.create(name: "   \n  ")
        XCTAssertEqual(c.name, "無名コレクション")
    }
}
