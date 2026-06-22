import Foundation

/// アプリ全体の UserDefaults / @AppStorage キーをここに集約する。
/// 追加・改名・削除はこの enum を経由し、schemaVersion を一段上げてマイグレーションを書く。
enum AppStorageKeys {
    static let schemaVersion = "asobi.schema.version"
    static let onboardingDone = "asobi.onboarding.v1.done"
    static let feedbackEntries = "asobi.feedback.v1"
    static let favoriteGames = "asobi.favorites.v1"
    static let purchasedScenes = "asobi.purchases.scenes.v1"
    static let purchasedPrompts = "asobi.purchases.prompts.v1"
    static let allInPurchase = "asobi.purchases.allin.v1"
    static let subscriptionActive = "asobi.subscription.active.v1"
    static let playCountMonth = "asobi.playcount.month.v1"
    static let playCountValue = "asobi.playcount.value.v1"
    static let tipJarTotalYen = "asobi.tipjar.total.v1"
    static let firstLaunchDate = "asobi.firstlaunch.date.v1"
    static let launchCount = "asobi.launch.count.v1"
    static let totalPlayedGames = "asobi.totalplayed.v1"
    static let lastReviewPromptDate = "asobi.review.lastprompt.v1"
    static let reviewPromptVersion = "asobi.review.lastversion.v1"
    static let collections = "asobi.collections.v1"
    static let recentCollectionIds = "asobi.collections.recent.v1"
}

/// 永続化スキーマの現行バージョン。@AppStorage の構造を破壊的に変えるたびに +1 し、
/// `PersistenceMigrator.migrateIfNeeded()` で旧→新の変換を書く。
enum PersistenceSchema {
    static let current = 1
}

/// 起動時に1度だけ呼び、必要なら旧スキーマからのマイグレーションを行う。
/// 失敗時は try? で握り潰し、初期状態に戻す（壊れたデータでクラッシュループするより優先）。
enum PersistenceMigrator {
    static func migrateIfNeeded() {
        let defaults = UserDefaults.standard
        let stored = defaults.integer(forKey: AppStorageKeys.schemaVersion)
        guard stored < PersistenceSchema.current else { return }
        // 旧バージョンからのアップグレード時の差分処理をここに追加していく。
        defaults.set(PersistenceSchema.current, forKey: AppStorageKeys.schemaVersion)
    }
}
