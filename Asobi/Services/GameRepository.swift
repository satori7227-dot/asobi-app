import Foundation

/// Bundle(for: Self.self) 用のアンカー。@Observable のため class.self が使えない場合の保険。
private final class GameRepositoryBundleAnchor {}

@Observable
final class GameRepository {
    private(set) var games: [Game] = []
    private(set) var loadError: String?

    /// 同期ロードを採用している理由（2026-06-22 議論結果）:
    /// - 1191件 × Codable decode は実機 A18 で 30-60ms。起動経路のクリティカルパス上だが、
    ///   `Task.detached` で defer すると ScenePicker の最初の描画が games 未到着で空表示になり、
    ///   結局 onAppear で待つ必要がある。
    /// - JSON 自体は ~1MB 未満なので I/O コストも小さい。
    /// - 非同期化のメリットが見えるのは「件数 5000 超」「ネット取得」など状況が変わった時。
    /// 結論: 当面は同期のまま、必要なら GameIndex（軽量 id+name のみ）/ GameDetail（重）に分離する。
    init() {
        load()
    }

    func load() {
        // App bundle にあるのが本筋。テスト bundle (project.yml で別途同梱) からも読めるように、
        // main → Bundle(for: Self.self) の順で探索する。
        let url = Bundle.main.url(forResource: "games", withExtension: "json")
            ?? Bundle(for: GameRepositoryBundleAnchor.self).url(forResource: "games", withExtension: "json")
        guard let url else {
            loadError = String(localized: "games.json が見つかりません（Target Membership を確認）")
            AsobiLogger.data.error("games.json not found in bundle")
            return
        }
        do {
            let data = try Data(contentsOf: url)
            let decoded = try JSONDecoder().decode([Game].self, from: data)
            // scenes が空のゲームは提案ロジックに乗らないので、ロード時点で除外する。
            // 件数が出る場合は DB 側のバグの可能性が高いので OSLog に出して気づけるようにする。
            let valid = decoded.filter { !$0.scenes.isEmpty }
            let dropped = decoded.count - valid.count
            if dropped > 0 {
                AsobiLogger.data.warning("dropped \(dropped, privacy: .public) game(s) with empty scenes from games.json")
            }
            AsobiLogger.data.info("loaded \(valid.count, privacy: .public) games (dropped \(dropped, privacy: .public))")
            games = valid
            loadError = nil
        } catch {
            // 詳細はログへ、UI へは安全にローカライズ可能な短文だけ出す。
            loadError = String(localized: "ゲームデータの読み込みに失敗しました")
            AsobiLogger.data.error("games.json decode failed: \(error.localizedDescription, privacy: .public)")
        }
    }

    /// 指定 scene + context にマッチするゲームを最大 3 件返す。
    ///
    /// アルゴリズムは 2 段階:
    /// 1. **strict マッチ**: Game.matches(scene:context:) を全条件で適用（人数・テンション・所要時間・道具有無）。
    ///    十分な候補がなくても 3 件揃えば即返す。
    /// 2. **relax フォールバック**: strict で 3 件未満だった場合、所要時間とテンションを落とした緩い条件で
    ///    不足分を補う。シーン id・人数範囲・道具縛りは引き続き維持し、相対的に「やや合わないが遊べる」
    ///    候補で枠を埋める。strict 結果との重複を `!pick.contains` で除外する。
    ///
    /// excludedIds は「直近で出した」「dislike された」ゲーム等を除く想定で呼び出し側が渡す。
    func propose(scene: GameScene, context: ProposalContext, excluding excludedIds: Set<String> = []) -> [Game] {
        // === 段階1: strict マッチ ===
        let candidates = games
            .filter { $0.matches(scene: scene, context: context) }
            .filter { !excludedIds.contains($0.id) }
        let shuffled = candidates.shuffled()
        let pick = Array(shuffled.prefix(3))
        if pick.count == 3 { return pick }

        // === 段階2: relax フォールバック ===
        // strict で 3 件揃わなかった時のみ通る。所要時間・tension は無視し、scene/人数/道具縛りだけ残す。
        let relaxed = games
            .filter { $0.scenes.contains(scene.id) }
            .filter { $0.minPlayers <= context.playerCount && $0.maxPlayers >= context.playerCount }
            .filter { !context.noItemsOnly || $0.physicalItems.isEmpty }
            .filter { !excludedIds.contains($0.id) }
            .filter { !pick.contains($0) }
            .shuffled()
            .prefix(3 - pick.count)
        return pick + Array(relaxed)
    }
}
