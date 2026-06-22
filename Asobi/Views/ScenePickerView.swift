import SwiftUI

struct ScenePickerView: View {
    @Binding var path: NavigationPath
    @Binding var showSuggestion: Bool
    @Binding var showFavorites: Bool
    @Binding var showTools: Bool
    @Binding var showCollections: Bool
    @Binding var showSettings: Bool
    @Environment(GameRepository.self) private var repo
    @Environment(PurchaseStore.self) private var purchases
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var animateIn = false
    @State private var purchaseTarget: PurchaseSheetView.Target?

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                if let err = repo.loadError {
                    HStack(spacing: 12) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundStyle(.orange)
                        VStack(alignment: .leading, spacing: 4) {
                            Text("データ読み込みエラー").font(.subheadline.weight(.semibold))
                            Text(err).font(.caption).foregroundStyle(.secondary)
                        }
                        Spacer()
                    }
                    .padding()
                    .background(.orange.opacity(0.12), in: RoundedRectangle(cornerRadius: 12))
                    .padding(.horizontal)
                }

                VStack(spacing: 8) {
                    Text("ASOBI")
                        .font(.system(.largeTitle, design: .rounded, weight: .heavy))
                        .tracking(6)
                        .minimumScaleFactor(0.7)
                        .accessibilityAddTraits(.isHeader)
                        .accessibilityIdentifier("scene-picker-title")
                    Text("どんな場面ですか？")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding(.top, 16)
                .accessibilityElement(children: .combine)

                VStack(spacing: 16) {
                    ForEach(Array(GameScene.initial.enumerated()), id: \.element.id) { index, scene in
                        SceneCard(scene: scene, isLocked: !purchases.isUnlocked(scene: scene))
                            .contentShape(RoundedRectangle(cornerRadius: 20))
                            .onTapGesture {
                                if purchases.isUnlocked(scene: scene) {
                                    path.append(AsobiRoute.context(scene))
                                } else {
                                    purchaseTarget = .scene(scene)
                                }
                            }
                            .contextMenu {
                                if purchases.isUnlocked(scene: scene) {
                                    Button {
                                        // デフォルト状況（4 人・ふつう・短時間）で即提案へジャンプ。
                                        var ctx = ProposalContext()
                                        ctx.playerCount = 4
                                        ctx.tension = .medium
                                        ctx.duration = .short
                                        path.append(AsobiRoute.proposal(scene, ctx))
                                    } label: {
                                        Label("おまかせで3つ出す", systemImage: "sparkles")
                                    }
                                    Button {
                                        // 道具なしでもいい想定でおまかせ提案。
                                        var ctx = ProposalContext()
                                        ctx.playerCount = 4
                                        ctx.tension = .medium
                                        ctx.duration = .short
                                        ctx.noItemsOnly = true
                                        path.append(AsobiRoute.proposal(scene, ctx))
                                    } label: {
                                        Label("手ぶらでおまかせ", systemImage: "hand.raised.fill")
                                    }
                                }
                            }
                            .opacity(animateIn ? 1 : 0)
                            .offset(y: animateIn || reduceMotion ? 0 : 28)
                            .animation(
                                reduceMotion
                                    ? .none
                                    : .spring(duration: 0.5).delay(Double(index) * 0.08),
                                value: animateIn
                            )
                            .accessibilityElement(children: .ignore)
                            .accessibilityLabel(
                                Text(scene.localizedName)
                                + Text(purchases.isUnlocked(scene: scene) ? " シーン" : " シーン（プレミアム）")
                            )
                            .accessibilityHint(Text(purchases.isUnlocked(scene: scene) ? "タップしてこのシーンに合うゲームを探します" : "プレミアムパック ¥120 で開放できます"))
                            .accessibilityAddTraits(.isButton)
                            .accessibilityIdentifier("scene-tile-\(scene.id)")
                    }

                    if Constants.premiumEnabled && !purchases.hasAllIn && !purchases.hasActiveSubscription {
                        Button {
                            purchaseTarget = .allIn
                        } label: {
                            HStack {
                                Image(systemName: "sparkles")
                                    .font(.title3)
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("オールインパック ¥1,200")
                                        .font(.subheadline.weight(.bold))
                                    Text("全シーン・全お題が永続解放")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundStyle(.tertiary)
                            }
                            .padding()
                            .background(
                                Color(red: 0.85, green: 0.47, blue: 0.34).opacity(0.12),
                                in: RoundedRectangle(cornerRadius: 16)
                            )
                            .foregroundStyle(.primary)
                        }
                        .buttonStyle(.plain)
                        .padding(.top, 4)
                    }
                }
                .padding(.horizontal)

                Spacer(minLength: 32)
            }
        }
        .toolbar {
            ToolbarItemGroup(placement: .topBarLeading) {
                Button {
                    showFavorites = true
                } label: {
                    Label("お気に入り", systemImage: "star.fill")
                        .foregroundStyle(.yellow)
                }
                .accessibilityLabel("お気に入り一覧を開く")
                Button {
                    showCollections = true
                } label: {
                    Label("コレクション", systemImage: "rectangle.stack.fill")
                }
                .accessibilityLabel("コレクション一覧を開く")
            }
            ToolbarItemGroup(placement: .topBarTrailing) {
                // ツール（最頻出）は単独で残し、その他は Menu にまとめてアイコン密度を下げる。
                Button {
                    showTools = true
                } label: {
                    Label("ツール", systemImage: "die.face.5.fill")
                }
                .accessibilityLabel("ツールセットを開く")

                Menu {
                    Button {
                        showSuggestion = true
                    } label: {
                        Label("アイデアを送る", systemImage: "lightbulb.fill")
                    }
                    Button {
                        showSettings = true
                    } label: {
                        Label("設定", systemImage: "gearshape.fill")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
                .accessibilityLabel("その他のメニュー")
                .accessibilityIdentifier("scene-picker-more-menu")
            }
        }
        .onAppear { animateIn = true }
        .sheet(item: Binding(
            get: { purchaseTarget.map { IdentifiedTarget(target: $0) } },
            set: { purchaseTarget = $0?.target }
        )) { wrapped in
            PurchaseSheetView(target: wrapped.target)
        }
    }
}

private struct IdentifiedTarget: Identifiable {
    let id = UUID()
    let target: PurchaseSheetView.Target
}

private struct SceneCard: View {
    let scene: GameScene
    let isLocked: Bool

    var body: some View {
        HStack(spacing: 16) {
            ZStack(alignment: .bottomTrailing) {
                Image(systemName: scene.symbolName)
                    .font(.system(size: 28, weight: .semibold))
                    .frame(width: 56, height: 56)
                    .background(scene.accent.opacity(0.18), in: Circle())
                    .foregroundStyle(scene.accent)
                if isLocked {
                    Image(systemName: "lock.fill")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(.white)
                        .padding(5)
                        .background(.secondary, in: Circle())
                }
            }

            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    Text(scene.localizedName)
                        .font(.title2.weight(.bold))
                        .foregroundStyle(.primary)
                    if isLocked {
                        Text("¥120")
                            .font(.caption.weight(.bold))
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(scene.accent.opacity(0.18), in: Capsule())
                            .foregroundStyle(scene.accent)
                    }
                }
                Text(isLocked ? "タップでパック解放" : "タップしてゲームを探す")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Image(systemName: "chevron.right")
                .foregroundStyle(.tertiary)
        }
        .padding()
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 20))
        .opacity(isLocked ? 0.85 : 1.0)
    }
}
