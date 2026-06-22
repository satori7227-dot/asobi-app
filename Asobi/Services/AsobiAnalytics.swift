import Foundation

/// 匿名イベント計測の抽象レイヤ。
///
/// 設計方針:
/// - 本体コードは `AsobiAnalytics.shared.send(.gameProposed(...))` のように
///   この enum/プロトコル経由でのみイベントを送る。
/// - 既定の実装は **no-op + OSLog 出力のみ**（外部 SDK 依存ゼロ）。
///   App Privacy = Data Not Collected を維持できる。
/// - 公開後に計測が必要になったら `TelemetryDeckBackend` 等を実装して
///   `AsobiAnalytics.shared.backend` を差し替えるだけ。本体コードは無変更。
/// - Constants.analyticsEnabled が false の間は backend に渡さない。

/// 送信するイベント。命名は domain-prefixed・snake_case で固定する。
enum AnalyticsEvent {
    case appLaunched
    case gameProposed(scene: String)
    case gameDetailOpened
    case favoriteAdded
    case toolOpened(kind: String)
    case suggestionSent(category: String)
    case paywallShown

    /// 計測キー（バックエンドに渡す名前）。
    var name: String {
        switch self {
        case .appLaunched:        return "app_launched"
        case .gameProposed:       return "game_proposed"
        case .gameDetailOpened:   return "game_detail_opened"
        case .favoriteAdded:      return "favorite_added"
        case .toolOpened:         return "tool_opened"
        case .suggestionSent:     return "suggestion_sent"
        case .paywallShown:       return "paywall_shown"
        }
    }

    /// 付随パラメータ（PII を含めない）。
    var parameters: [String: String] {
        switch self {
        case .gameProposed(let scene):       return ["scene": scene]
        case .toolOpened(let kind):          return ["kind": kind]
        case .suggestionSent(let category):  return ["category": category]
        default:                             return [:]
        }
    }
}

/// 計測バックエンドの差し替え点。
protocol AnalyticsBackend {
    func record(_ event: AnalyticsEvent)
}

/// 既定実装：何も外部送信せず OSLog にだけ残す。
struct NoOpAnalyticsBackend: AnalyticsBackend {
    func record(_ event: AnalyticsEvent) {
        AsobiLogger.lifecycle.debug("analytics(noop) \(event.name, privacy: .public)")
    }
}

@Observable
final class AsobiAnalytics {
    static let shared = AsobiAnalytics()

    /// 公開後に TelemetryDeck 等へ差し替える。既定は no-op。
    var backend: AnalyticsBackend = NoOpAnalyticsBackend()

    private init() {}

    func send(_ event: AnalyticsEvent) {
        guard Constants.analyticsEnabled else { return }
        backend.record(event)
    }
}
