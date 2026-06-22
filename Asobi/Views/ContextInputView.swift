import SwiftUI

struct ContextInputView: View {
    let scene: GameScene
    @Binding var path: NavigationPath
    @Binding var context: ProposalContext

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 28) {
                    SceneHeader(scene: scene)

                    section(title: "人数") {
                        HStack {
                            Button {
                                if context.playerCount > 2 { context.playerCount -= 1 }
                            } label: {
                                Image(systemName: "minus.circle.fill").font(.title)
                            }
                            .buttonStyle(.plain)
                            Text("\(context.playerCount) 人")
                                .font(.system(.largeTitle, design: .rounded, weight: .bold))
                                .frame(maxWidth: .infinity)
                                .contentTransition(.numericText())
                                .minimumScaleFactor(0.7)
                            Button {
                                if context.playerCount < 10 { context.playerCount += 1 }
                            } label: {
                                Image(systemName: "plus.circle.fill").font(.title)
                            }
                            .buttonStyle(.plain)
                        }
                        .foregroundStyle(scene.accent)
                    }

                    section(title: "テンション") {
                        HStack(spacing: 12) {
                            ForEach(Tension.allCases) { t in
                                tensionButton(t)
                            }
                        }
                    }

                    section(title: "所要時間") {
                        HStack(spacing: 12) {
                            ForEach(Duration.allCases) { d in
                                durationButton(d)
                            }
                        }
                    }

                    section(title: "持ち物") {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack(spacing: 12) {
                                itemsButton(allow: true,  label: "ありOK",   symbol: "shippingbox.fill")
                                itemsButton(allow: false, label: "手ぶら", symbol: "hand.raised.fill")
                            }
                            Text("※ サイコロ・トランプ・コイン等はアプリで対応するため「手ぶら」でも候補に出ます")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                .padding()
            }

            Button {
                path.append(AsobiRoute.proposal(scene, context))
            } label: {
                Text("ゲームを探す")
                    .font(.title3.weight(.bold))
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(scene.accent, in: Capsule())
                    .foregroundStyle(.white)
            }
            .padding()
        }
        .navigationBarTitleDisplayMode(.inline)
    }

    /// `section(title: "人数") { ... }` で見出し付き VStack を作るヘルパ。
    /// 引数の title は LocalizedStringKey として渡され、xcstrings から翻訳される。
    /// 呼び出し側は文字列リテラルで渡すことで Swift コンパイラが自動的に
    /// LocalizedStringKey にブリッジするため、引数記述は従来と変わらない。
    @ViewBuilder
    private func section<Content: View>(title: LocalizedStringKey, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title).font(.headline)
            content()
        }
    }

    private func tensionButton(_ t: Tension) -> some View {
        let selected = context.tension == t
        return Button {
            withAnimation(.spring) { context.tension = t }
        } label: {
            VStack(spacing: 8) {
                Image(systemName: t.symbol).font(.title2)
                Text(t.localizedDisplayName).font(.caption.weight(.semibold))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                selected ? scene.accent.opacity(0.2) : Color(.secondarySystemBackground),
                in: RoundedRectangle(cornerRadius: 16)
            )
            .foregroundStyle(selected ? scene.accent : .primary)
        }
        .buttonStyle(.plain)
    }

    private func durationButton(_ d: Duration) -> some View {
        let selected = context.duration == d
        return Button {
            withAnimation(.spring) { context.duration = d }
        } label: {
            Text(d.localizedDisplayName)
                .font(.subheadline.weight(.semibold))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    selected ? scene.accent.opacity(0.2) : Color(.secondarySystemBackground),
                    in: RoundedRectangle(cornerRadius: 16)
                )
                .foregroundStyle(selected ? scene.accent : .primary)
        }
        .buttonStyle(.plain)
    }

    private func itemsButton(allow: Bool, label: String, symbol: String) -> some View {
        let selected = context.noItemsOnly == !allow
        return Button {
            withAnimation(.spring) { context.noItemsOnly = !allow }
        } label: {
            VStack(spacing: 8) {
                Image(systemName: symbol).font(.title2)
                Text(label).font(.caption.weight(.semibold))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                selected ? scene.accent.opacity(0.2) : Color(.secondarySystemBackground),
                in: RoundedRectangle(cornerRadius: 16)
            )
            .foregroundStyle(selected ? scene.accent : .primary)
        }
        .buttonStyle(.plain)
    }
}

struct SceneHeader: View {
    let scene: GameScene

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: scene.symbolName)
                .font(.system(size: 28))
                .foregroundStyle(scene.accent)
            Text(scene.localizedName).font(.largeTitle.weight(.heavy))
            Spacer()
        }
    }
}
