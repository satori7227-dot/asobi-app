import Foundation
import os

/// アプリ全体の OSLog カテゴリ。print() の代わりに使う。
/// ログ閲覧: Console.app または Xcode の Devices &amp; Simulators &gt; View Device Logs。
enum AsobiLogger {
    private static let subsystem = Bundle.main.bundleIdentifier ?? "com.idogawa.Asobi"
    static let propose = Logger(subsystem: subsystem, category: "propose")
    static let filter = Logger(subsystem: subsystem, category: "filter")
    static let purchase = Logger(subsystem: subsystem, category: "purchase")
    static let data = Logger(subsystem: subsystem, category: "data")
    static let feedback = Logger(subsystem: subsystem, category: "feedback")
    static let lifecycle = Logger(subsystem: subsystem, category: "lifecycle")
}
