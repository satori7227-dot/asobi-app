import XCTest
@testable import Asobi

final class FavoriteOrderTests: XCTestCase {
    override func setUp() {
        super.setUp()
        UserDefaults.standard.removeObject(forKey: "asobi.feedback.v1")
        UserDefaults.standard.removeObject(forKey: "asobi.favorites.v1")
        UserDefaults.standard.removeObject(forKey: "asobi.favorites.order.v1")
    }

    func testToggleAppendsToOrderInSequence() {
        let store = FeedbackStore()
        store.toggleFavorite(gameId: "a")
        store.toggleFavorite(gameId: "b")
        store.toggleFavorite(gameId: "c")
        XCTAssertEqual(store.favoriteOrder, ["a", "b", "c"])
    }

    func testToggleRemoveStripsFromOrder() {
        let store = FeedbackStore()
        store.toggleFavorite(gameId: "a")
        store.toggleFavorite(gameId: "b")
        store.toggleFavorite(gameId: "a")  // a を解除
        XCTAssertEqual(store.favoriteOrder, ["b"])
        XCTAssertFalse(store.favoriteGameIds.contains("a"))
    }

    func testMoveFavoriteReorders() {
        let store = FeedbackStore()
        ["a", "b", "c", "d"].forEach { store.toggleFavorite(gameId: $0) }
        store.moveFavorite(from: IndexSet(integer: 0), to: 3)
        // [a, b, c, d] で 0番目を3に動かすと SwiftUI 規約で [b, c, a, d]
        XCTAssertEqual(store.favoriteOrder, ["b", "c", "a", "d"])
    }

    func testReconcileAddsMissingFromSet() {
        // 古いデータ：Set はあるが order は空（v1 時代の状態を模す）
        UserDefaults.standard.set(
            try! JSONEncoder().encode(["x", "y"]),
            forKey: "asobi.favorites.v1"
        )
        let store = FeedbackStore()
        XCTAssertEqual(store.favoriteGameIds, Set(["x", "y"]))
        // reconcile によって order が補完されている（順序は不問）
        XCTAssertEqual(Set(store.favoriteOrder), Set(["x", "y"]))
    }

    func testReconcileStripsOrphans() {
        // order に残骸が混入していて、Set 側に該当 id が無い場合
        UserDefaults.standard.set(
            try! JSONEncoder().encode(["a"]),
            forKey: "asobi.favorites.v1"
        )
        UserDefaults.standard.set(
            try! JSONEncoder().encode(["a", "ghost", "b"]),
            forKey: "asobi.favorites.order.v1"
        )
        let store = FeedbackStore()
        XCTAssertFalse(store.favoriteOrder.contains("ghost"))
        XCTAssertFalse(store.favoriteOrder.contains("b"))
        XCTAssertEqual(store.favoriteOrder, ["a"])
    }

    func testPersistsOrderAcrossInstances() {
        let s1 = FeedbackStore()
        ["a", "b", "c"].forEach { s1.toggleFavorite(gameId: $0) }
        s1.moveFavorite(from: IndexSet(integer: 2), to: 0)
        // [a, b, c] で 2番を 0 に動かすと [c, a, b]
        XCTAssertEqual(s1.favoriteOrder, ["c", "a", "b"])

        let s2 = FeedbackStore()
        XCTAssertEqual(s2.favoriteOrder, ["c", "a", "b"])
    }
}
