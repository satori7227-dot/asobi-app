import SwiftUI

/// 提案画面の上部に「いま何の条件で絞り込んでいるか」を Capsule で見せるバー。
/// タップすると条件編集に戻るアクションを呼ぶ。
struct ContextChipsBar: View {
    let scene: GameScene
    let context: ProposalContext
    var onEdit: () -> Void = {}

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ContextChip(symbol: scene.symbolName, text: scene.localizedName, tint: .accentColor)
                ContextChip(symbol: "person.2.fill", text: LocalizedStringKey("\(context.playerCount) 人"))
                ContextChip(symbol: context.tension.symbol, text: context.tension.localizedDisplayName)
                ContextChip(symbol: "clock", text: context.duration.localizedDisplayName)
                if context.noItemsOnly {
                    ContextChip(symbol: "hand.raised.fill", text: "手ぶら", tint: .green)
                }
                Button(action: onEdit) {
                    Label("条件変更", systemImage: "slider.horizontal.3")
                        .font(.caption.weight(.semibold))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(
                            Capsule()
                                .fill(Color.accentColor.opacity(0.14))
                        )
                        .foregroundStyle(Color.accentColor)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("絞り込み条件を変更")
            }
            .padding(.horizontal)
            .padding(.vertical, 6)
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("現在の絞り込み条件")
    }
}

private struct ContextChip: View {
    let symbol: String
    let text: LocalizedStringKey
    var tint: Color = .secondary

    /// 推奨：固定リテラルや LocalizedStringKey をそのまま渡す経路。
    /// SwiftUI の文字列リテラル解析が効き、xcstrings から自動翻訳される。
    init(symbol: String, text: LocalizedStringKey, tint: Color = .secondary) {
        self.symbol = symbol
        self.text = text
        self.tint = tint
    }

    /// 利便用：String を渡す経路。だが**変数 String を渡すと翻訳されない**。
    /// 文字列補間を含む動的ラベルを翻訳したい場合は、`LocalizedStringKey("\(value) 人")`
    /// で明示的に LocalizedStringKey 化した側のイニシャライザを使うこと。
    /// このイニシャライザは「翻訳不要な値（記号・数字単体・固有名）」用と割り切る。
    init(symbol: String, text: String, tint: Color = .secondary) {
        self.symbol = symbol
        self.text = LocalizedStringKey(text)
        self.tint = tint
    }

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: symbol)
                .imageScale(.small)
            Text(text)
                .font(.caption.weight(.medium))
                .lineLimit(1)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(
            Capsule()
                .fill(tint.opacity(0.14))
        )
        .foregroundStyle(tint == .secondary ? Color.primary : tint)
    }
}

#Preview {
    let scene = GameScene(id: "drinking", name: "飲み会", symbolName: "wineglass.fill", assetName: "Drinking")
    return ContextChipsBar(
        scene: scene,
        context: ProposalContext(playerCount: 4, tension: .medium, duration: .short, noItemsOnly: true)
    )
}
