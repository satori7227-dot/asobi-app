import Foundation
import SwiftUI

enum FeedbackCategory: String, CaseIterable, Identifiable {
    case gameRequest
    case bug
    case question
    case other

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .gameRequest: return "新ゲーム要望"
        case .bug:         return "不具合報告"
        case .question:    return "質問"
        case .other:       return "その他"
        }
    }

    /// SwiftUI Text 用のローカライズキー。`Text(category.localizedDisplayName)` で xcstrings から翻訳が引かれる。
    var localizedDisplayName: LocalizedStringKey { LocalizedStringKey(displayName) }

    var emoji: String {
        switch self {
        case .gameRequest: return "💡"
        case .bug:         return "🐛"
        case .question:    return "❓"
        case .other:       return "📝"
        }
    }

    var color: Int {
        switch self {
        case .gameRequest: return 14383927   // Claude orange
        case .bug:         return 15548997   // red-ish
        case .question:    return 3447003    // blue
        case .other:       return 9807270    // gray
        }
    }

    var symbol: String {
        switch self {
        case .gameRequest: return "lightbulb.fill"
        case .bug:         return "ladybug.fill"
        case .question:    return "questionmark.circle.fill"
        case .other:       return "doc.text.fill"
        }
    }
}

enum FeedbackWebhook {
    private static let url = URL(string:
        "https://discord.com/api/webhooks/1517411699551109271/85t3vznmrVEruH0biSbHiL31YxvQCwnQ2v7GrZwgkdFF0GCITJEiStwnO2ORA66RtTbx"
    )!

    private static let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd HH:mm"
        f.timeZone = TimeZone(identifier: "Asia/Tokyo")
        return f
    }()

    enum SendError: Error, LocalizedError {
        case invalidResponse
        case httpStatus(Int)
        case encoding

        var errorDescription: String? {
            switch self {
            case .invalidResponse: return "サーバー応答が不正"
            case .httpStatus(let code): return "送信失敗（HTTP \(code)）"
            case .encoding: return "データの組み立て失敗"
            }
        }
    }

    static func send(category: FeedbackCategory, sceneLabel: String, body: String) async throws {
        let payload: [String: Any] = [
            "username": "ASOBI 意見箱",
            "embeds": [[
                "title": "\(category.emoji) \(category.displayName)",
                "description": body,
                "color": category.color,
                "fields": [
                    ["name": "シーン", "value": sceneLabel, "inline": true],
                    ["name": "種類", "value": category.displayName, "inline": true],
                    ["name": "送信日時", "value": dateFormatter.string(from: Date()), "inline": false],
                ]
            ]]
        ]

        guard let httpBody = try? JSONSerialization.data(withJSONObject: payload) else {
            throw SendError.encoding
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = httpBody
        request.timeoutInterval = 10

        let (_, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse else {
            throw SendError.invalidResponse
        }
        guard (200..<300).contains(http.statusCode) else {
            throw SendError.httpStatus(http.statusCode)
        }
    }
}
