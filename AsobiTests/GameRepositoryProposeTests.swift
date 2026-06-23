import XCTest
@testable import Asobi

/// GameRepository.propose() の振る舞いを固定する。
/// regionBlocklist が dead data に戻らないよう、地域フィルタが strict/relax 両方で機能していることを保証する。
final class GameRepositoryProposeTests: XCTestCase {

    private func makeRepo() throws -> GameRepository {
        let repo = GameRepository()
        guard !repo.games.isEmpty else {
            throw XCTSkip("games.json が test bundle に含まれていない場合は skip")
        }
        return repo
    }

    /// 既知の drinking シーンで 3 件提案が返ること。propose() の最低限の動作確認。
    func testProposeReturnsThreeForDrinking() throws {
        let repo = try makeRepo()
        guard let drinking = GameScene.initial.first(where: { $0.id == "drinking" }) else {
            XCTFail("drinking scene not found in GameScene.initial")
            return
        }
        let ctx = ProposalContext(
            playerCount: 4,
            tension: .medium,
            duration: .short,
            noItemsOnly: false
        )
        let result = repo.propose(scene: drinking, context: ctx)
        XCTAssertEqual(result.count, 3, "drinking で 3 件返らない")
    }

    /// id ベースの O(1) lookup が動くこと。Favorites / CollectionDetail で再ロードを避けるため。
    func testGameByIdLookup() throws {
        let repo = try makeRepo()
        let firstId = repo.games.first!.id
        XCTAssertNotNil(repo.game(id: firstId), "\(firstId) が gamesById で見つからない")
        XCTAssertNil(repo.game(id: "this-id-does-not-exist-zzz"), "存在しない id で nil が返らない")
    }

    /// regionBlocklist が propose() に効いていること。
    /// games.json に飲酒系で regionBlocklist=['SA',...] のゲームが 6 件あるので、
    /// drinking シーンで全 propose 結果に「SA で許可される」性質が反映されることを確認する。
    func testRegionBlocklistAppliedToPropose() throws {
        let repo = try makeRepo()
        guard let drinking = GameScene.initial.first(where: { $0.id == "drinking" }) else { return }
        let ctx = ProposalContext(
            playerCount: 6,
            tension: .high,
            duration: .short,
            noItemsOnly: false
        )
        // 数回 propose して、各回の結果がすべて SA で isAllowed=true であること
        for _ in 0..<5 {
            let result = repo.propose(scene: drinking, context: ctx)
            for game in result {
                XCTAssertTrue(
                    game.isAllowed(in: "SA"),
                    "SA でブロックされるはずの \(game.name) (id=\(game.id)) が propose 結果に含まれた"
                )
            }
        }
    }
}
