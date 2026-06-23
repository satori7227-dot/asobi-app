import Foundation
import SwiftUI

@Observable
final class PurchaseStore {
    private let purchasedScenesKey = AppStorageKeys.purchasedScenes
    private let purchasedPromptsKey = AppStorageKeys.purchasedPrompts
    private let allInKey = AppStorageKeys.allInPurchase
    private let subscriptionActiveKey = AppStorageKeys.subscriptionActive

    var purchasedSceneIds: Set<String> = []
    var purchasedPromptCategories: Set<String> = []
    var hasAllIn: Bool = false
    var hasActiveSubscription: Bool = false

    init() {
        load()
    }

    func load() {
        if let arr = UserDefaults.standard.array(forKey: purchasedScenesKey) as? [String] {
            purchasedSceneIds = Set(arr)
        }
        if let arr = UserDefaults.standard.array(forKey: purchasedPromptsKey) as? [String] {
            purchasedPromptCategories = Set(arr)
        }
        hasAllIn = UserDefaults.standard.bool(forKey: allInKey)
        hasActiveSubscription = UserDefaults.standard.bool(forKey: subscriptionActiveKey)
    }

    func save() {
        UserDefaults.standard.set(Array(purchasedSceneIds), forKey: purchasedScenesKey)
        UserDefaults.standard.set(Array(purchasedPromptCategories), forKey: purchasedPromptsKey)
        UserDefaults.standard.set(hasAllIn, forKey: allInKey)
        UserDefaults.standard.set(hasActiveSubscription, forKey: subscriptionActiveKey)
    }

    func isUnlocked(scene: GameScene) -> Bool {
        if !Constants.premiumEnabled { return true }
        if !scene.isPremium { return true }
        if hasAllIn || hasActiveSubscription { return true }
        return purchasedSceneIds.contains(scene.id)
    }

    func isUnlocked(promptCategory: PromptCategory) -> Bool {
        if !Constants.premiumEnabled { return true }
        if !promptCategory.isPremium { return true }
        if hasAllIn || hasActiveSubscription { return true }
        return purchasedPromptCategories.contains(promptCategory.rawValue)
    }

    func unlockScene(_ sceneId: String) {
        purchasedSceneIds.insert(sceneId)
        save()
    }

    func unlockPromptCategory(_ category: PromptCategory) {
        purchasedPromptCategories.insert(category.rawValue)
        save()
    }

    func unlockAll() {
        hasAllIn = true
        save()
    }

    func activateSubscription(_ active: Bool) {
        hasActiveSubscription = active
        save()
    }

    func reset() {
        purchasedSceneIds.removeAll()
        purchasedPromptCategories.removeAll()
        hasAllIn = false
        hasActiveSubscription = false
        save()
    }
}

extension GameScene {
    private static let premiumSceneIds: Set<String> = [
        "konkatsu", "shukatsu", "dosokai", "sobetsukai", "kids", "offkai"
    ]

    var isPremium: Bool {
        Self.premiumSceneIds.contains(id)
    }

    var price: String {
        isPremium ? "¥120" : "無料"
    }
}

extension PromptCategory {
    var isPremium: Bool {
        switch self {
        case .adultDeep, .coupleTruth, .drinkingTaboo:
            return true
        default:
            return false
        }
    }

    var price: String {
        isPremium ? "¥240" : "無料"
    }
}
