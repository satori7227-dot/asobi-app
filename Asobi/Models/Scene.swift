import SwiftUI

struct GameScene: Identifiable, Codable, Hashable {
    let id: String
    let name: String
    let symbolName: String
    let assetName: String

    var accent: Color { Color("SceneColors/\(assetName)") }

    /// 表示用のローカライズキー。`Text(scene.localizedName)` で xcstrings から
    /// 端末言語に応じた翻訳が引かれる。`Text(scene.name)` は変数文字列なので
    /// SwiftUI の自動ローカライズが効かない（必ずこちらを使う）。
    var localizedName: LocalizedStringKey { LocalizedStringKey(name) }

    static let initial: [GameScene] = [
        GameScene(id: "drinking",   name: "飲み会",         symbolName: "wineglass.fill",                       assetName: "Drinking"),
        GameScene(id: "travel",     name: "旅行",           symbolName: "airplane",                              assetName: "Travel"),
        GameScene(id: "penalty",    name: "罰ゲーム決め",   symbolName: "die.face.5.fill",                       assetName: "Penalty"),
        GameScene(id: "family",     name: "家族・親戚",     symbolName: "person.3.fill",                         assetName: "Family"),
        GameScene(id: "couple",     name: "カップル・2人",  symbolName: "heart.fill",                            assetName: "Couple"),
        GameScene(id: "outdoor",    name: "キャンプ・BBQ",  symbolName: "tent.fill",                             assetName: "Outdoor"),
        GameScene(id: "remote",     name: "リモート飲み",   symbolName: "laptopcomputer",                        assetName: "Remote"),
        GameScene(id: "konkatsu",   name: "婚活・お見合い", symbolName: "heart.text.square.fill",                assetName: "Konkatsu"),
        GameScene(id: "shukatsu",   name: "新人歓迎・研修", symbolName: "briefcase.fill",                        assetName: "Shukatsu"),
        GameScene(id: "dosokai",    name: "同窓会",         symbolName: "graduationcap.fill",                    assetName: "Dosokai"),
        GameScene(id: "sobetsukai", name: "送別会",         symbolName: "hand.wave.fill",                        assetName: "Sobetsukai"),
        GameScene(id: "kids",       name: "子供パーティー", symbolName: "balloon.fill",                          assetName: "Kids"),
        GameScene(id: "offkai",     name: "オフ会・初対面", symbolName: "bubble.left.and.bubble.right.fill",    assetName: "Offkai"),
    ]
}
