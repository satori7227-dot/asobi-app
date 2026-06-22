import Foundation
import os

/// アプリ全体の OSLog カテゴリ。print() の代わりに使う。
/// ログ閲覧: Console.app または Xcode の Devices &amp; Simulators &gt; View Device Logs。
enum AsobiLogger {
    static let subsystem = Bundle.main.bundleIdentifier ?? "com.idogawa.Asobi"
    static let propose = Logger(subsystem: subsystem, category: "propose")
    static let filter = Logger(subsystem: subsystem, category: "filter")
    static let purchase = Logger(subsystem: subsystem, category: "purchase")
    static let data = Logger(subsystem: subsystem, category: "data")
    static let feedback = Logger(subsystem: subsystem, category: "feedback")
    static let lifecycle = Logger(subsystem: subsystem, category: "lifecycle")

    /// Instruments の「Points of Interest」に出る signpost 用 OSLog。
    /// 起動・ロード等のクリティカルパスを Time Profiler 上で区間計測するために使う。
    static let pointsOfInterest = OSLog(subsystem: subsystem, category: .pointsOfInterest)
}

/// signpost で区間計測するヘルパ。
/// 使い方:
///   let token = AsobiSignpost.begin("load games")
///   defer { AsobiSignpost.end("load games", token) }
enum AsobiSignpost {
    static func begin(_ name: StaticString) -> OSSignpostID {
        let id = OSSignpostID(log: AsobiLogger.pointsOfInterest)
        os_signpost(.begin, log: AsobiLogger.pointsOfInterest, name: name, signpostID: id)
        return id
    }

    static func end(_ name: StaticString, _ id: OSSignpostID) {
        os_signpost(.end, log: AsobiLogger.pointsOfInterest, name: name, signpostID: id)
    }
}
