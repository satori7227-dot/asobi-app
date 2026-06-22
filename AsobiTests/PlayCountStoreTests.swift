import XCTest
@testable import Asobi

final class PlayCountStoreTests: XCTestCase {
    override func setUp() {
        super.setUp()
        UserDefaults.standard.removeObject(forKey: AppStorageKeys.playCountMonth)
        UserDefaults.standard.removeObject(forKey: AppStorageKeys.playCountValue)
        UserDefaults.standard.removeObject(forKey: AppStorageKeys.allInPurchase)
        UserDefaults.standard.removeObject(forKey: AppStorageKeys.subscriptionActive)
    }

    func testInitialCountIsZero() {
        let store = PlayCountStore()
        XCTAssertEqual(store.count, 0)
        XCTAssertEqual(store.remaining, PlayCountStore.monthlyLimit)
        XCTAssertFalse(store.isExhausted)
    }

    func testRecordPlayIncrements() {
        let store = PlayCountStore()
        store.recordPlay()
        store.recordPlay()
        XCTAssertEqual(store.count, 2)
        XCTAssertEqual(store.remaining, PlayCountStore.monthlyLimit - 2)
    }

    func testIsExhaustedAtLimit() {
        let store = PlayCountStore()
        for _ in 0..<PlayCountStore.monthlyLimit { store.recordPlay() }
        XCTAssertTrue(store.isExhausted)
        XCTAssertEqual(store.remaining, 0)
    }

    func testRolloverWhenMonthChanges() {
        let store = PlayCountStore()
        store.recordPlay()
        store.recordPlay()
        // 月キーを意図的に過去にする
        UserDefaults.standard.set("2000-01", forKey: AppStorageKeys.playCountMonth)
        let store2 = PlayCountStore()
        XCTAssertEqual(store2.count, 0, "新しい月キーが検出されたら count はリセット")
    }

    func testShouldPresentPaywallRespectsFeatureFlag() {
        let store = PlayCountStore()
        for _ in 0..<PlayCountStore.monthlyLimit { store.recordPlay() }
        let purchases = PurchaseStore()
        // softPaywallEnabled = false なので常に false
        XCTAssertFalse(store.shouldPresentPaywall(purchases: purchases))
    }
}

final class GameDisplayLanguageTests: XCTestCase {
    func testDisplayPrefersJapaneseByDefault() {
        let game = Game(
            id: "x", name: "ビアポン", summary: "卓を挟んでカップ狙う",
            rules: "10カップずつ",
            scenes: ["drinking"], minPlayers: 4, maxPlayers: 8,
            tension: ["high"], duration: "medium", items: []
        )
        // 端末ロケールに依存するが、JP の場合は和文を返す。CI では preferredLanguages を強制できないので
        // 「英語データが空なら必ず日本語フォールバック」だけを保証する。
        XCTAssertEqual(game.displayName, "ビアポン")
    }
}
