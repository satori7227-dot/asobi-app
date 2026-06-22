import Foundation

@Observable
final class PromptRepository {
    private(set) var collection: PromptCollection?
    private(set) var loadError: String?

    private var stringBags: [PromptCategory: [String]] = [:]
    private var wordWolfBag: [WordWolfPair] = []

    init() {
        load()
    }

    func load() {
        guard let url = Bundle.main.url(forResource: "prompts", withExtension: "json") else {
            loadError = String(localized: "お題データが見つかりません")
            return
        }
        do {
            let data = try Data(contentsOf: url)
            collection = try JSONDecoder().decode(PromptCollection.self, from: data)
        } catch {
            loadError = String(localized: "お題データの読み込みに失敗しました")
        }
    }

    private func source(for category: PromptCategory) -> [String] {
        guard let c = collection else { return [] }
        switch category {
        case .gesture:        return c.gesture
        case .association:    return c.association
        case .twoChoice:      return c.twoChoice
        case .ohgiri:         return c.ohgiri
        case .questions36:    return c.questions36
        case .adultDeep:      return c.adultDeep
        case .coupleTruth:    return c.coupleTruth
        case .drinkingTaboo:  return c.drinkingTaboo
        case .wordWolf:       return []
        }
    }

    func randomString(in category: PromptCategory) -> String? {
        guard category != .wordWolf else { return nil }
        if (stringBags[category] ?? []).isEmpty {
            stringBags[category] = source(for: category).shuffled()
        }
        return stringBags[category]?.popLast()
    }

    func randomWordWolfPair() -> WordWolfPair? {
        guard let c = collection else { return nil }
        if wordWolfBag.isEmpty {
            wordWolfBag = c.wordWolf.shuffled()
        }
        return wordWolfBag.popLast()
    }
}
