import XCTest
@testable import Asobi

final class PurchaseStoreTests: XCTestCase {
    override func setUp() {
        super.setUp()
        let keys = [
            AppStorageKeys.purchasedScenes,
            AppStorageKeys.purchasedPrompts,
            AppStorageKeys.allInPurchase,
            AppStorageKeys.subscriptionActive,
        ]
        for key in keys { UserDefaults.standard.removeObject(forKey: key) }
    }

    private var drinking: GameScene { GameScene.initial.first { $0.id == "drinking" }! }
    private var konkatsu: GameScene { GameScene.initial.first { $0.id == "konkatsu" }! }

    func testFreeSceneIsAlwaysUnlocked() {
        let store = PurchaseStore()
        // Constants.premiumEnabled の真偽に関わらず、有料 flag 立てなくても free シーンは true
        XCTAssertTrue(store.isUnlocked(scene: drinking))
    }

    func testPremiumSceneRequiresUnlockWhenFlagEnabled() throws {
        guard Constants.premiumEnabled else {
            throw XCTSkip("premiumEnabled が false の間はゲートが効かない仕様の確認だけ")
        }
        let store = PurchaseStore()
        XCTAssertFalse(store.isUnlocked(scene: konkatsu))
        store.unlockScene(konkatsu.id)
        XCTAssertTrue(store.isUnlocked(scene: konkatsu))
    }

    func testUnlockAllOpensEverySceneWhenFlagEnabled() throws {
        guard Constants.premiumEnabled else {
            throw XCTSkip("premiumEnabled が false の間は gate しない")
        }
        let store = PurchaseStore()
        store.unlockAll()
        XCTAssertTrue(store.isUnlocked(scene: konkatsu))
    }

    func testActivateSubscriptionOpensEverySceneWhenFlagEnabled() throws {
        guard Constants.premiumEnabled else {
            throw XCTSkip("premiumEnabled が false の間は gate しない")
        }
        let store = PurchaseStore()
        store.activateSubscription(true)
        XCTAssertTrue(store.isUnlocked(scene: konkatsu))
    }

    func testResetClearsAllUnlocks() {
        let store = PurchaseStore()
        store.unlockScene("konkatsu")
        store.unlockAll()
        store.activateSubscription(true)
        store.reset()
        XCTAssertTrue(store.purchasedSceneIds.isEmpty)
        XCTAssertFalse(store.hasAllIn)
        XCTAssertFalse(store.hasActiveSubscription)
    }

    func testPersistsAcrossInstances() {
        let store1 = PurchaseStore()
        store1.unlockScene("konkatsu")
        let store2 = PurchaseStore()
        XCTAssertTrue(store2.purchasedSceneIds.contains("konkatsu"))
    }
}

final class ToolKindRelevanceTests: XCTestCase {
    private func makeGame(
        name: String = "テスト",
        summary: String = "テスト",
        rules: String = "テスト",
        items: [String] = []
    ) -> Game {
        Game(
            id: "tk", name: name, summary: summary, rules: rules,
            scenes: ["drinking"], minPlayers: 2, maxPlayers: 8,
            tension: ["medium"], duration: "short", items: items
        )
    }

    func testItemDiceMappingDetectsDice() {
        let g = makeGame(items: ["サイコロ"])
        XCTAssertEqual(ToolsetView.ToolKind.relevant(for: g), [.dice])
    }

    func testKeywordWordWolfDetectsPrompt() {
        let g = makeGame(rules: "ワードウルフのお題を引いて遊ぶ")
        XCTAssertTrue(ToolsetView.ToolKind.relevant(for: g).contains(.prompt))
    }

    func testKeywordKingGameDetectsKingGame() {
        let g = makeGame(rules: "王様ゲームを始める")
        XCTAssertTrue(ToolsetView.ToolKind.relevant(for: g).contains(.kingGame))
    }

    func testReturnsInDisplayOrderPromptFirst() {
        let g = makeGame(rules: "サイコロを振ってお題を引く")
        let tools = ToolsetView.ToolKind.relevant(for: g)
        XCTAssertEqual(tools.first, .prompt)
        XCTAssertTrue(tools.contains(.dice))
    }

    func testReturnsEmptyForUnrelatedGame() {
        let g = makeGame(name: "Hello", summary: "World", rules: "Lorem")
        XCTAssertEqual(ToolsetView.ToolKind.relevant(for: g), [])
    }
}
