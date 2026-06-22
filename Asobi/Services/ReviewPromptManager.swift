import Foundation
import StoreKit
import SwiftUI
import UIKit

/// アプリ内レビュープロンプト（SKStoreReviewController.requestReview）の
/// 表示条件と頻度制御を一箇所に集約する。
///
/// 発火条件（AND）:
///   - 初回起動から 7 日以上経過
///   - 累計起動回数 3 回以上
///   - 累計プレイ完了ゲーム 5 本以上
///   - 同一バージョンで未表示
///   - 前回プロンプトから 120 日以上経過
///
/// 失敗系（エラー直後、オンボーディング途中）からは絶対に呼ばない。
@Observable
final class ReviewPromptManager {
    static let minDaysSinceFirstLaunch: Double = 7
    static let minLaunchCount: Int = 3
    static let minPlayedGames: Int = 5
    static let minDaysBetweenPrompts: Double = 120

    /// 起動時に1度だけ呼ぶ。
    func recordLaunch() {
        let defaults = UserDefaults.standard
        if defaults.object(forKey: AppStorageKeys.firstLaunchDate) == nil {
            defaults.set(Date(), forKey: AppStorageKeys.firstLaunchDate)
        }
        let count = defaults.integer(forKey: AppStorageKeys.launchCount) + 1
        defaults.set(count, forKey: AppStorageKeys.launchCount)
        AsobiLogger.lifecycle.debug("launch count=\(count, privacy: .public)")
    }

    /// 完了シグナルの発信元。OSLog 用のラベル。
    enum CompletionSource: String {
        case detailLiked = "detail-liked"
        case kingGameDistributed = "king-game-distributed"
        case timerFinished = "timer-finished"
        case rouletteSpun = "roulette-spun"
        case promptGachaThreshold = "prompt-gacha-threshold"
        case other = "other"
    }

    /// ゲーム1本「最後まで遊んだ」と判定できた瞬間に呼ぶ。
    /// 呼出箇所が増えやすいので、source ラベル付きで OSLog に出して動作可視化する。
    func recordCompletedGame(source: CompletionSource = .other) {
        let defaults = UserDefaults.standard
        let total = defaults.integer(forKey: AppStorageKeys.totalPlayedGames) + 1
        defaults.set(total, forKey: AppStorageKeys.totalPlayedGames)
        AsobiLogger.lifecycle.info(
            "completed game total=\(total, privacy: .public) source=\(source.rawValue, privacy: .public)"
        )
    }

    /// 楽しい体験の直後に呼ぶ（例：ゲーム詳細を閉じた直後、お気に入り追加の直後）。
    /// 条件未達なら何もしない。
    func requestReviewIfAppropriate() {
        guard shouldRequest else { return }
        guard let scene = activeWindowScene else { return }
        SKStoreReviewController.requestReview(in: scene)
        let defaults = UserDefaults.standard
        defaults.set(Date(), forKey: AppStorageKeys.lastReviewPromptDate)
        defaults.set(currentAppVersion, forKey: AppStorageKeys.reviewPromptVersion)
        AsobiLogger.lifecycle.info("review prompt requested for version=\(self.currentAppVersion, privacy: .public)")
    }

    /// テスト用に条件を可視化するためのプロパティ。
    var shouldRequest: Bool {
        let defaults = UserDefaults.standard
        guard let firstLaunch = defaults.object(forKey: AppStorageKeys.firstLaunchDate) as? Date else { return false }
        let now = Date()
        let daysSinceFirst = now.timeIntervalSince(firstLaunch) / 86_400
        guard daysSinceFirst >= Self.minDaysSinceFirstLaunch else { return false }
        guard defaults.integer(forKey: AppStorageKeys.launchCount) >= Self.minLaunchCount else { return false }
        guard defaults.integer(forKey: AppStorageKeys.totalPlayedGames) >= Self.minPlayedGames else { return false }
        if defaults.string(forKey: AppStorageKeys.reviewPromptVersion) == currentAppVersion {
            return false
        }
        if let last = defaults.object(forKey: AppStorageKeys.lastReviewPromptDate) as? Date {
            let daysSinceLast = now.timeIntervalSince(last) / 86_400
            if daysSinceLast < Self.minDaysBetweenPrompts { return false }
        }
        return true
    }

    private var currentAppVersion: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "unknown"
    }

    private var activeWindowScene: UIWindowScene? {
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first { $0.activationState == .foregroundActive }
    }
}
