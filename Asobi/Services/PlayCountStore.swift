import Foundation
import SwiftUI

/// 月間プレイ回数を端末ローカルでカウントするソフトペイウォール用ストア。
///
/// 仕様（収益化 wave のリサーチ準拠）:
/// - 無料枠: 月 20 本までゲームを「開始」できる
/// - 月境界をまたいだら自動でリセット
/// - Constants.softPaywallEnabled = false の間は常に許可
/// - hasUnlimitedAccess() で課金済ユーザーをバイパス
@Observable
final class PlayCountStore {
    /// 月間無料枠
    static let monthlyLimit = 20

    private(set) var monthKey: String
    private(set) var count: Int

    init() {
        let stored = UserDefaults.standard.string(forKey: AppStorageKeys.playCountMonth) ?? ""
        let current = Self.currentMonthKey()
        if stored == current {
            self.monthKey = current
            self.count = UserDefaults.standard.integer(forKey: AppStorageKeys.playCountValue)
        } else {
            self.monthKey = current
            self.count = 0
            UserDefaults.standard.set(current, forKey: AppStorageKeys.playCountMonth)
            UserDefaults.standard.set(0, forKey: AppStorageKeys.playCountValue)
        }
    }

    /// 今月の残り無料プレイ回数。
    var remaining: Int { max(0, Self.monthlyLimit - count) }

    /// 無料枠を使い切ったか。
    var isExhausted: Bool { count >= Self.monthlyLimit }

    /// ゲーム開始時に1度だけ呼ぶ。
    /// 上限到達したら呼び出し側で PaywallView を表示する判断材料に。
    func recordPlay() {
        rolloverIfNeeded()
        count += 1
        UserDefaults.standard.set(count, forKey: AppStorageKeys.playCountValue)
        AsobiLogger.purchase.debug("play recorded: \(self.count, privacy: .public)/\(Self.monthlyLimit, privacy: .public)")
    }

    /// 開発・テスト用にリセット。
    func resetForDebug() {
        count = 0
        UserDefaults.standard.set(0, forKey: AppStorageKeys.playCountValue)
    }

    /// ペイウォールを実際に出すべきかの判定。
    /// 課金済ユーザーや旗が落ちている時は false。
    func shouldPresentPaywall(purchases: PurchaseStore) -> Bool {
        guard Constants.softPaywallEnabled else { return false }
        if purchases.hasAllIn || purchases.hasActiveSubscription { return false }
        rolloverIfNeeded()
        return isExhausted
    }

    private func rolloverIfNeeded() {
        let current = Self.currentMonthKey()
        guard current != monthKey else { return }
        monthKey = current
        count = 0
        UserDefaults.standard.set(current, forKey: AppStorageKeys.playCountMonth)
        UserDefaults.standard.set(0, forKey: AppStorageKeys.playCountValue)
        AsobiLogger.purchase.info("month rolled over to \(current, privacy: .public)")
    }

    private static func currentMonthKey() -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM"
        return formatter.string(from: Date())
    }
}
