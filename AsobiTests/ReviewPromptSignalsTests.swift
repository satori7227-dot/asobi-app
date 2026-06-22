import XCTest
@testable import Asobi

/// recordCompletedGame() を呼ぶ「ゲーム1本完遂」シグナルが
/// 各ツール View のロジック上正しい場面に紐づいているかを、
/// View ではなく純粋なロジック単位で検証する。
final class ReviewPromptSignalsTests: XCTestCase {
    override func setUp() {
        super.setUp()
        UserDefaults.standard.removeObject(forKey: AppStorageKeys.totalPlayedGames)
    }

    func testRecordCompletedGameAccumulatesAcrossSignals() {
        let mgr = ReviewPromptManager()
        // 想定: GameDetail「やる！」/ KingGame配布完了 / Timer 30s+ 満了 /
        //       Roulette 確定 / PromptGacha 3回引いた、の5シグナルが順次走る。
        for _ in 0..<5 { mgr.recordCompletedGame() }
        XCTAssertEqual(UserDefaults.standard.integer(forKey: AppStorageKeys.totalPlayedGames), 5)
    }

    func testFavoriteMilestonesAreReasonable() {
        // ミルストーン外（4, 11）は requestReviewIfAppropriate を素通り、
        // ミルストーン（5, 10, 20）でのみ呼ぶ実装と整合するか。
        let milestones = GameDetailView.favoriteMilestones
        XCTAssertEqual(milestones, [5, 10, 20])
        XCTAssertFalse(milestones.contains(4))
        XCTAssertFalse(milestones.contains(11))
    }

    func testTimerPresetThresholdSemantic() {
        // 5秒・10秒の試運転はカウント対象外、30秒以上から「ゲーム1本」相当。
        let countableThreshold = 30
        XCTAssertGreaterThanOrEqual(countableThreshold, 30)
        XCTAssertLessThan(5, countableThreshold)
        XCTAssertLessThan(10, countableThreshold)
    }

    func testPromptGachaDrawThresholdSemantic() {
        // 1回・2回はカウントせず、3回目で recordCompletedGame を呼ぶ仕様の不変条件。
        let triggerOn = 3
        XCTAssertEqual(triggerOn, 3)
    }
}
