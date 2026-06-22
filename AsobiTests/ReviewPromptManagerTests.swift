import XCTest
@testable import Asobi

final class ReviewPromptManagerTests: XCTestCase {
    override func setUp() {
        super.setUp()
        let keys = [
            AppStorageKeys.firstLaunchDate,
            AppStorageKeys.launchCount,
            AppStorageKeys.totalPlayedGames,
            AppStorageKeys.lastReviewPromptDate,
            AppStorageKeys.reviewPromptVersion,
        ]
        for key in keys { UserDefaults.standard.removeObject(forKey: key) }
    }

    func testShouldNotRequestBeforeFirstLaunchRecorded() {
        let mgr = ReviewPromptManager()
        XCTAssertFalse(mgr.shouldRequest, "first launch すらしていない状態で出してはいけない")
    }

    func testRecordLaunchIncrementsCounter() {
        let mgr = ReviewPromptManager()
        mgr.recordLaunch()
        mgr.recordLaunch()
        mgr.recordLaunch()
        XCTAssertEqual(UserDefaults.standard.integer(forKey: AppStorageKeys.launchCount), 3)
    }

    func testRecordCompletedGameAccumulates() {
        let mgr = ReviewPromptManager()
        for _ in 0..<5 { mgr.recordCompletedGame() }
        XCTAssertEqual(UserDefaults.standard.integer(forKey: AppStorageKeys.totalPlayedGames), 5)
    }

    func testShouldRequestWhenAllConditionsMet() {
        // 7日以上前を firstLaunch にする
        let eightDaysAgo = Date(timeIntervalSinceNow: -86_400 * 8)
        UserDefaults.standard.set(eightDaysAgo, forKey: AppStorageKeys.firstLaunchDate)
        UserDefaults.standard.set(3, forKey: AppStorageKeys.launchCount)
        UserDefaults.standard.set(5, forKey: AppStorageKeys.totalPlayedGames)
        let mgr = ReviewPromptManager()
        XCTAssertTrue(mgr.shouldRequest)
    }

    func testShouldNotRequestWithInsufficientPlayedGames() {
        let eightDaysAgo = Date(timeIntervalSinceNow: -86_400 * 8)
        UserDefaults.standard.set(eightDaysAgo, forKey: AppStorageKeys.firstLaunchDate)
        UserDefaults.standard.set(3, forKey: AppStorageKeys.launchCount)
        UserDefaults.standard.set(4, forKey: AppStorageKeys.totalPlayedGames)
        let mgr = ReviewPromptManager()
        XCTAssertFalse(mgr.shouldRequest)
    }

    func testShouldNotRequestWithInsufficientLaunchCount() {
        let eightDaysAgo = Date(timeIntervalSinceNow: -86_400 * 8)
        UserDefaults.standard.set(eightDaysAgo, forKey: AppStorageKeys.firstLaunchDate)
        UserDefaults.standard.set(2, forKey: AppStorageKeys.launchCount)
        UserDefaults.standard.set(5, forKey: AppStorageKeys.totalPlayedGames)
        let mgr = ReviewPromptManager()
        XCTAssertFalse(mgr.shouldRequest)
    }

    func testShouldNotRequestWithinSevenDays() {
        let twoDaysAgo = Date(timeIntervalSinceNow: -86_400 * 2)
        UserDefaults.standard.set(twoDaysAgo, forKey: AppStorageKeys.firstLaunchDate)
        UserDefaults.standard.set(10, forKey: AppStorageKeys.launchCount)
        UserDefaults.standard.set(20, forKey: AppStorageKeys.totalPlayedGames)
        let mgr = ReviewPromptManager()
        XCTAssertFalse(mgr.shouldRequest)
    }

    func testShouldNotRequestIfRecentlyPrompted() {
        let eightDaysAgo = Date(timeIntervalSinceNow: -86_400 * 8)
        UserDefaults.standard.set(eightDaysAgo, forKey: AppStorageKeys.firstLaunchDate)
        UserDefaults.standard.set(3, forKey: AppStorageKeys.launchCount)
        UserDefaults.standard.set(5, forKey: AppStorageKeys.totalPlayedGames)
        UserDefaults.standard.set(Date(timeIntervalSinceNow: -86_400 * 30), forKey: AppStorageKeys.lastReviewPromptDate)
        let mgr = ReviewPromptManager()
        XCTAssertFalse(mgr.shouldRequest, "前回プロンプトから120日未満は出さない")
    }
}
