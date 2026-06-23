import Foundation
import SwiftUI

struct WordWolfPair: Codable, Hashable {
    let majority: String
    let minority: String
}

struct PromptCollection: Codable {
    let gesture: [String]
    let association: [String]
    let twoChoice: [String]
    let ohgiri: [String]
    let wordWolf: [WordWolfPair]
    let questions36: [String]
    let adultDeep: [String]
    let coupleTruth: [String]
    let drinkingTaboo: [String]
}

enum PromptCategory: String, CaseIterable, Identifiable {
    case gesture
    case association
    case twoChoice
    case ohgiri
    case wordWolf
    case questions36
    case adultDeep
    case coupleTruth
    case drinkingTaboo

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .gesture:        return "ジェスチャー"
        case .association:    return "連想・お題"
        case .twoChoice:      return "究極の二択"
        case .ohgiri:         return "大喜利"
        case .wordWolf:       return "ワードウルフ"
        case .questions36:    return "36の質問"
        case .adultDeep:      return "大人の深掘り"
        case .coupleTruth:    return "カップル本音"
        case .drinkingTaboo:  return "大人の本音"
        }
    }

    var localizedDisplayName: LocalizedStringKey { LocalizedStringKey(displayName) }

    var symbol: String {
        switch self {
        case .gesture:        return "figure.run"
        case .association:    return "bubble.left.fill"
        case .twoChoice:      return "rectangle.split.2x1.fill"
        case .ohgiri:         return "theatermasks.fill"
        case .wordWolf:       return "person.2.wave.2.fill"
        case .questions36:    return "heart.text.square.fill"
        case .adultDeep:      return "moon.stars.fill"
        case .coupleTruth:    return "heart.circle.fill"
        case .drinkingTaboo:  return "flame.fill"
        }
    }
}
