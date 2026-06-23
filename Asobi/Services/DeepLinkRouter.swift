import Foundation
import SwiftUI

/// asobi:// で始まる Deep Link を解釈してアプリ内ルートに変換する。
///
/// 対応スキーム:
/// - `asobi://scene/<id>` … 指定シーンの ContextInput へ直接遷移
///   例: `asobi://scene/drinking`
/// - `asobi://favorites` … お気に入りシートを開く
/// - `asobi://collections` … コレクション一覧を開く
/// - `asobi://game/<id>` … 特定ゲーム詳細をシートで開く（ShareLink 連携用）
///
/// 将来追加候補:
/// - `asobi://tools/<kind>` … 王様くじ等のツールを直接開く
enum DeepLink: Equatable {
    case scene(id: String)
    case game(id: String)
    case favorites
    case collections

    /// URL を Deep Link に変換する。スキーム/ホスト不一致は nil を返す。
    init?(url: URL) {
        guard url.scheme?.lowercased() == "asobi" else { return nil }
        // host が空のときは path の先頭を見る（asobi:///scene/drinking と asobi://scene/drinking の両対応）。
        let host = url.host?.lowercased() ?? ""
        let components = url.pathComponents.filter { $0 != "/" }
        switch host {
        case "scene":
            guard let id = components.first, !id.isEmpty else { return nil }
            self = .scene(id: id)
        case "game":
            guard let id = components.first, !id.isEmpty else { return nil }
            self = .game(id: id)
        case "favorites":
            self = .favorites
        case "collections":
            self = .collections
        default:
            return nil
        }
    }
}

/// ルートビュー側で Deep Link の受信状態を持ち回す軽量ストア。
@Observable
final class DeepLinkRouter {
    /// 直近に受信した Deep Link。ContentView の onChange で消費する。
    var pending: DeepLink?

    func handle(url: URL) {
        guard let link = DeepLink(url: url) else {
            AsobiLogger.lifecycle.warning("ignored deep link: \(url.absoluteString, privacy: .private(mask: .hash))")
            return
        }
        AsobiLogger.lifecycle.info("received deep link: \(url.absoluteString, privacy: .private(mask: .hash))")
        pending = link
    }
}
