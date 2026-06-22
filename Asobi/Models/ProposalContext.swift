import Foundation
import SwiftUI

struct ProposalContext: Equatable, Hashable {
    /// 人数選択の下限・上限。UI の Stepper と提案ロジックで共有する単一の真実。
    static let minPlayers = 2
    static let maxPlayers = 10

    var playerCount: Int = 4
    var tension: Tension = .medium
    var duration: Duration = .short
    var noItemsOnly: Bool = false

    /// playerCount を許容範囲内にクランプする。外部入力（Deep Link 等）からの保険。
    mutating func clampPlayerCount() {
        playerCount = min(max(playerCount, Self.minPlayers), Self.maxPlayers)
    }
}

enum Tension: String, CaseIterable, Identifiable, Codable {
    case calm
    case medium
    case high

    var id: String { rawValue }

    /// 表示用日本語ラベル（xcstrings のキーとしても使用、Text(localizedDisplayName) でローカライズされる）。
    var displayName: String {
        switch self {
        case .calm:   return "落ち着き"
        case .medium: return "ふつう"
        case .high:   return "盛り上がり"
        }
    }

    /// SwiftUI Text 用のローカライズキー。`Text(tension.localizedDisplayName)` で xcstrings から翻訳が引かれる。
    var localizedDisplayName: LocalizedStringKey { LocalizedStringKey(displayName) }

    var symbol: String {
        switch self {
        case .calm:   return "moon.zzz"
        case .medium: return "leaf"
        case .high:   return "flame.fill"
        }
    }
}

enum Duration: String, CaseIterable, Identifiable, Codable {
    case short
    case medium
    case long

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .short:  return "5分未満"
        case .medium: return "5〜15分"
        case .long:   return "15分以上"
        }
    }

    /// SwiftUI Text 用のローカライズキー。`Text(duration.localizedDisplayName)` で xcstrings から翻訳が引かれる。
    var localizedDisplayName: LocalizedStringKey { LocalizedStringKey(displayName) }
}
