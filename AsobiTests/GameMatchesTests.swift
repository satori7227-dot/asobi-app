import XCTest
@testable import Asobi

final class GameMatchesTests: XCTestCase {
    private let drinking = GameScene.initial.first { $0.id == "drinking" }!
    private let travel = GameScene.initial.first { $0.id == "travel" }!

    private func makeGame(
        scenes: [String] = ["drinking"],
        min: Int = 3, max: Int = 8,
        tension: [String] = ["medium"],
        duration: String = "short",
        items: [String] = []
    ) -> Game {
        Game(
            id: "test", name: "テスト", summary: "テストゲーム",
            rules: "ルール", scenes: scenes,
            minPlayers: min, maxPlayers: max,
            tension: tension, duration: duration, items: items
        )
    }

    func testMatchesScene() {
        let g = makeGame(scenes: ["drinking"])
        XCTAssertTrue(g.matches(scene: drinking, context: ProposalContext(playerCount: 4, tension: .medium, duration: .short, noItemsOnly: false)))
        XCTAssertFalse(g.matches(scene: travel, context: ProposalContext(playerCount: 4, tension: .medium, duration: .short, noItemsOnly: false)))
    }

    func testMatchesPlayerCountRange() {
        let g = makeGame(min: 3, max: 6)
        XCTAssertFalse(g.matches(scene: drinking, context: ProposalContext(playerCount: 2, tension: .medium, duration: .short, noItemsOnly: false)))
        XCTAssertTrue(g.matches(scene: drinking, context: ProposalContext(playerCount: 5, tension: .medium, duration: .short, noItemsOnly: false)))
        XCTAssertFalse(g.matches(scene: drinking, context: ProposalContext(playerCount: 7, tension: .medium, duration: .short, noItemsOnly: false)))
    }

    func testMatchesTension() {
        let g = makeGame(tension: ["high"])
        XCTAssertFalse(g.matches(scene: drinking, context: ProposalContext(playerCount: 4, tension: .calm, duration: .short, noItemsOnly: false)))
        XCTAssertTrue(g.matches(scene: drinking, context: ProposalContext(playerCount: 4, tension: .high, duration: .short, noItemsOnly: false)))
    }

    func testMatchesDurationTolerant() {
        let g = makeGame(duration: "medium")
        // 直接一致
        XCTAssertTrue(g.matches(scene: drinking, context: ProposalContext(playerCount: 4, tension: .medium, duration: .medium, noItemsOnly: false)))
        // 隣接（±1）でマッチ
        XCTAssertTrue(g.matches(scene: drinking, context: ProposalContext(playerCount: 4, tension: .medium, duration: .short, noItemsOnly: false)))
        XCTAssertTrue(g.matches(scene: drinking, context: ProposalContext(playerCount: 4, tension: .medium, duration: .long, noItemsOnly: false)))
    }

    func testNoItemsOnlyExcludesPhysical() {
        let g = makeGame(items: ["紙", "ペン"])
        XCTAssertTrue(g.matches(scene: drinking, context: ProposalContext(playerCount: 4, tension: .medium, duration: .short, noItemsOnly: false)))
        XCTAssertFalse(g.matches(scene: drinking, context: ProposalContext(playerCount: 4, tension: .medium, duration: .short, noItemsOnly: true)))
    }

    func testNoItemsOnlyAllowsAppProvidedOnly() {
        let g = makeGame(items: ["サイコロ", "トランプ"])
        XCTAssertTrue(g.matches(scene: drinking, context: ProposalContext(playerCount: 4, tension: .medium, duration: .short, noItemsOnly: true)))
    }

    func testPhysicalItemsExcludesAppProvided() {
        let g = makeGame(items: ["紙", "サイコロ", "ペン"])
        XCTAssertEqual(Set(g.physicalItems), Set(["紙", "ペン"]))
    }

    /// 人数境界: minPlayers ぴったり / maxPlayers ぴったり も範囲内。
    func testMatchesPlayerCountBoundariesInclusive() {
        let g = makeGame(min: 3, max: 5)
        let ctx = { (n: Int) in ProposalContext(playerCount: n, tension: .medium, duration: .short, noItemsOnly: false) }
        XCTAssertTrue(g.matches(scene: drinking, context: ctx(3)))
        XCTAssertTrue(g.matches(scene: drinking, context: ctx(5)))
    }

    /// duration が long で context が short の場合（±2 差）は relax 対象外＝false。
    func testMatchesDurationTooFarApart() {
        let g = makeGame(duration: "long")
        XCTAssertFalse(g.matches(scene: drinking, context: ProposalContext(playerCount: 4, tension: .medium, duration: .short, noItemsOnly: false)))
    }

    /// 複数 tension を持つゲームはどの context tension にもマッチ。
    func testMatchesTensionMultiple() {
        let g = makeGame(tension: ["calm", "medium", "high"])
        XCTAssertTrue(g.matches(scene: drinking, context: ProposalContext(playerCount: 4, tension: .calm, duration: .short, noItemsOnly: false)))
        XCTAssertTrue(g.matches(scene: drinking, context: ProposalContext(playerCount: 4, tension: .medium, duration: .short, noItemsOnly: false)))
        XCTAssertTrue(g.matches(scene: drinking, context: ProposalContext(playerCount: 4, tension: .high, duration: .short, noItemsOnly: false)))
    }

    /// 複数 scene を持つゲームは、含まれるどの scene でもマッチ可能。
    func testMatchesAcrossMultipleScenes() {
        let g = makeGame(scenes: ["drinking", "travel"])
        XCTAssertTrue(g.matches(scene: drinking, context: ProposalContext(playerCount: 4, tension: .medium, duration: .short, noItemsOnly: false)))
        XCTAssertTrue(g.matches(scene: travel, context: ProposalContext(playerCount: 4, tension: .medium, duration: .short, noItemsOnly: false)))
    }

    /// items が空 + 道具なしフィルタ ON でも問題なくマッチ。
    func testMatchesEmptyItemsWithNoItemsOnly() {
        let g = makeGame(items: [])
        XCTAssertTrue(g.matches(scene: drinking, context: ProposalContext(playerCount: 4, tension: .medium, duration: .short, noItemsOnly: true)))
    }

    /// 1人プレイ前提のゲーム（min=1, max=1）は人数 2 でマッチしない。
    func testMatchesSinglePlayerRange() {
        let g = makeGame(min: 1, max: 1)
        XCTAssertTrue(g.matches(scene: drinking, context: ProposalContext(playerCount: 1, tension: .medium, duration: .short, noItemsOnly: false)))
        XCTAssertFalse(g.matches(scene: drinking, context: ProposalContext(playerCount: 2, tension: .medium, duration: .short, noItemsOnly: false)))
    }
}

final class FeedbackStoreTests: XCTestCase {
    private var store: FeedbackStore!

    override func setUp() {
        super.setUp()
        UserDefaults.standard.removeObject(forKey: "asobi.feedback.v1")
        UserDefaults.standard.removeObject(forKey: "asobi.favorites.v1")
        store = FeedbackStore()
    }

    func testToggleFavorite() {
        XCTAssertFalse(store.isFavorite("g1"))
        store.toggleFavorite(gameId: "g1")
        XCTAssertTrue(store.isFavorite("g1"))
        store.toggleFavorite(gameId: "g1")
        XCTAssertFalse(store.isFavorite("g1"))
    }

    func testRecordReaction() {
        store.record(gameId: "g1", reaction: .liked, sceneId: "drinking")
        XCTAssertEqual(store.reaction(for: "g1", in: "drinking"), .liked)
        store.record(gameId: "g1", reaction: .disliked, sceneId: "drinking")
        XCTAssertEqual(store.reaction(for: "g1", in: "drinking"), .disliked)
    }

    func testDislikedGameIds() {
        store.record(gameId: "g1", reaction: .liked, sceneId: "drinking")
        store.record(gameId: "g2", reaction: .disliked, sceneId: "drinking")
        store.record(gameId: "g3", reaction: .disliked, sceneId: "travel")
        XCTAssertEqual(store.dislikedGameIds, Set(["g2", "g3"]))
    }

    /// 上限を超えた古い entries は head trim される。
    /// 同一 (gameId, sceneId) は record で先に削除されるので、別シーン or 別ゲームで詰める。
    func testEntriesAreTrimmedAtLimit() {
        let limit = FeedbackStore.entriesLimit
        for i in 0..<(limit + 5) {
            store.record(gameId: "g\(i)", reaction: .liked, sceneId: "scene\(i)")
        }
        XCTAssertEqual(store.entries.count, limit)
        // 先頭 5 件は trim されているはず＝最古の id が残っていない
        XCTAssertFalse(store.entries.contains { $0.gameId == "g0" })
        XCTAssertTrue(store.entries.contains { $0.gameId == "g\(limit + 4)" })
    }
}

final class PromptRepositoryTests: XCTestCase {
    func testShuffleBagAvoidsImmediateRepeats() {
        let repo = PromptRepository()
        guard repo.collection != nil else {
            XCTFail("collection not loaded")
            return
        }
        var seen: [String] = []
        // ジェスチャー全50件分取り出して全て異なることを確認
        let total = repo.collection?.gesture.count ?? 0
        for _ in 0..<total {
            if let next = repo.randomString(in: .gesture) {
                seen.append(next)
            }
        }
        XCTAssertEqual(seen.count, total)
        XCTAssertEqual(Set(seen).count, total, "shuffle bag 内で重複が発生")
    }
}
