import XCTest
@testable import Asobi

/// GameRepository は bundle resource を読むので Codable 経由でしか検証できない。
/// ここでは「scenes 空ゲームが提案ロジックに乗らない」不変条件を、
/// テスト用の純粋関数（同等ロジック）と整合させる形で固定する。
final class GameRepositoryLoadTests: XCTestCase {

    /// bundle のロード結果に scenes 空のゲームが残っていないことを保証する。
    /// load() で除外される実装なので 0 件であるべき。
    func testLoadedGamesHaveNoEmptyScenes() throws {
        let repo = GameRepository()
        // bundle 不在の Test target でも幸い games.json は同梱されているはず
        guard !repo.games.isEmpty else {
            // Test scheme で resource が紐付かない場合は skip 扱いにする
            throw XCTSkip("games.json が test bundle に含まれていない場合は skip")
        }
        let withEmpty = repo.games.filter { $0.scenes.isEmpty }
        XCTAssertTrue(withEmpty.isEmpty, "scenes 空のゲームが残っている: \(withEmpty.count) 件")
    }

    /// 件数の sanity check。1000 件超を維持しているか。
    func testLoadedGamesCountIsReasonable() throws {
        let repo = GameRepository()
        guard !repo.games.isEmpty else {
            throw XCTSkip("games.json が test bundle に含まれていない場合は skip")
        }
        XCTAssertGreaterThanOrEqual(repo.games.count, 1000, "1000 件を割っている: \(repo.games.count)")
    }

    /// id が一意であることの確認。Identifiable で List 等に渡したとき行が消えないため。
    func testLoadedGameIdsAreUnique() throws {
        let repo = GameRepository()
        guard !repo.games.isEmpty else {
            throw XCTSkip("games.json が test bundle に含まれていない場合は skip")
        }
        let ids = repo.games.map(\.id)
        let unique = Set(ids)
        XCTAssertEqual(ids.count, unique.count, "id 重複が \(ids.count - unique.count) 件ある")
    }

    /// id が全件埋まっていること。空文字 id は SwiftUI List の identity を壊す。
    func testLoadedGameIdsAreNonEmpty() throws {
        let repo = GameRepository()
        guard !repo.games.isEmpty else {
            throw XCTSkip("games.json が test bundle に含まれていない場合は skip")
        }
        let empty = repo.games.filter { $0.id.isEmpty }
        XCTAssertTrue(empty.isEmpty, "id 空のゲームが \(empty.count) 件ある")
    }
}
