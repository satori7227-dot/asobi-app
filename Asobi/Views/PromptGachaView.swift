import SwiftUI

struct PromptGachaView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(PromptRepository.self) private var repo
    @Environment(PurchaseStore.self) private var purchases
    @Environment(ReviewPromptManager.self) private var reviewPrompt
    @State private var category: PromptCategory = .gesture
    @State private var current: String?
    @State private var currentPair: WordWolfPair?
    @State private var showMinority: Bool = false
    @State private var revealTrigger: Int = 0
    @State private var showPurchase: Bool = false
    @State private var promptDrawCount: Int = 0

    /// 現在のカテゴリが課金ゲート対象か。
    /// 判定は PurchaseStore に委譲しており、`Constants.premiumEnabled = false` の間は常に false を返す。
    /// IAP 解禁時もこのプロパティを変えずに済む設計。
    private var isLocked: Bool {
        !purchases.isUnlocked(promptCategory: category)
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(PromptCategory.allCases) { c in
                            CategoryChip(category: c, selected: category == c, locked: !purchases.isUnlocked(promptCategory: c))
                                .onTapGesture {
                                    category = c
                                    current = nil
                                    currentPair = nil
                                    showMinority = false
                                    // カテゴリ変更=別のお題系ゲームを始める意図と見なし、
                                    // 「3回引いて完了」カウンタもリセットする。
                                    promptDrawCount = 0
                                }
                        }
                    }
                    .padding(.horizontal)
                }

                Spacer()

                if isLocked {
                    lockedBody
                } else if category == .wordWolf {
                    wordWolfBody
                } else {
                    plainBody
                }

                Spacer()

                if isLocked {
                    Button {
                        showPurchase = true
                    } label: {
                        Label("¥240 でパック解放", systemImage: "lock.open.fill")
                            .font(.title3.weight(.bold))
                            .frame(maxWidth: .infinity).padding()
                            .background(.blue, in: Capsule())
                            .foregroundStyle(.white)
                    }
                    .buttonStyle(.plain)
                    .padding(.horizontal)
                } else {
                    Button {
                        next()
                    } label: {
                        Text(current == nil && currentPair == nil ? "お題を出す" : "次のお題")
                            .font(.title3.weight(.bold))
                            .frame(maxWidth: .infinity).padding()
                            .background(.blue, in: Capsule())
                            .foregroundStyle(.white)
                    }
                    .buttonStyle(.plain)
                    .padding(.horizontal)
                }
            }
            .padding(.vertical)
            .navigationTitle("お題")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) { Button("閉じる") { dismiss() } }
            }
            .sheet(isPresented: $showPurchase) {
                PurchaseSheetView(target: .promptCategory(category))
            }
        }
    }

    @ViewBuilder
    private var lockedBody: some View {
        VStack(spacing: 16) {
            Image(systemName: "lock.fill")
                .font(.system(size: 80))
                .foregroundStyle(.secondary.opacity(0.5))
            Text(category.displayName)
                .font(.title2.weight(.bold))
            Text("20問の特別お題が解放されます")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
    }

    @ViewBuilder
    private var plainBody: some View {
        if let current = current {
            VStack(spacing: 12) {
                Image(systemName: category.symbol)
                    .font(.system(size: 36))
                    .foregroundStyle(.blue)
                Text(current)
                    .font(.system(size: 32, weight: .heavy, design: .rounded))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                    .symbolEffect(.bounce, value: revealTrigger)
                    .id(current)
                    .transition(.opacity)
            }
        } else {
            VStack(spacing: 12) {
                Image(systemName: category.symbol)
                    .font(.system(size: 80))
                    .foregroundStyle(.blue.opacity(0.3))
                Text(category.displayName)
                    .font(.title2.weight(.semibold))
                    .foregroundStyle(.secondary)
            }
        }
    }

    @ViewBuilder
    private var wordWolfBody: some View {
        if let pair = currentPair {
            VStack(spacing: 16) {
                Text("ワードウルフお題")
                    .font(.headline)
                    .foregroundStyle(.secondary)

                VStack(spacing: 8) {
                    Text("多数派").font(.caption).foregroundStyle(.secondary)
                    Text(pair.majority).font(.title.weight(.heavy))
                }
                .frame(maxWidth: .infinity).padding()
                .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))

                Button {
                    withAnimation(.spring) { showMinority.toggle() }
                } label: {
                    HStack {
                        Image(systemName: showMinority ? "eye.slash.fill" : "eye.fill")
                        Text(showMinority ? "ウルフのお題を隠す" : "ウルフのお題を見る")
                    }
                    .font(.subheadline.weight(.semibold))
                    .padding(.horizontal, 16).padding(.vertical, 10)
                    .background(.regularMaterial, in: Capsule())
                }
                .buttonStyle(.plain)

                if showMinority {
                    VStack(spacing: 8) {
                        Text("ウルフ").font(.caption).foregroundStyle(.secondary)
                        Text(pair.minority).font(.title.weight(.heavy))
                            .foregroundStyle(.red)
                    }
                    .frame(maxWidth: .infinity).padding()
                    .background(.red.opacity(0.1), in: RoundedRectangle(cornerRadius: 16))
                    .transition(.opacity)
                }
            }
            .padding(.horizontal)
        } else {
            VStack(spacing: 12) {
                Image(systemName: PromptCategory.wordWolf.symbol)
                    .font(.system(size: 80))
                    .foregroundStyle(.blue.opacity(0.3))
                Text("ワードウルフ")
                    .font(.title2.weight(.semibold))
                    .foregroundStyle(.secondary)
            }
        }
    }

}

private struct CategoryChip: View {
    let category: PromptCategory
    let selected: Bool
    let locked: Bool

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: locked ? "lock.fill" : category.symbol)
                .font(.caption)
            Text(category.displayName)
                .font(.caption.weight(.semibold))
            if locked {
                Text("¥240")
                    .font(.caption2.weight(.bold))
                    .padding(.horizontal, 4).padding(.vertical, 1)
                    .background(.blue.opacity(0.18), in: Capsule())
                    .foregroundStyle(.blue)
            }
        }
        .padding(.horizontal, 12).padding(.vertical, 8)
        .background(
            selected ? Color.blue.opacity(0.2) : Color(.secondarySystemBackground),
            in: Capsule()
        )
        .foregroundStyle(selected ? .blue : .primary)
    }
}

extension PromptGachaView {
    private func next() {
        showMinority = false
        if category == .wordWolf {
            currentPair = repo.randomWordWolfPair()
        } else {
            withAnimation(.easeInOut(duration: 0.2)) {
                current = repo.randomString(in: category)
            }
        }
        revealTrigger += 1
        promptDrawCount += 1
        // お題3回引いた=「お題系ゲーム1本」相当の完了シグナル。
        // 4回目以降はカウントしない（このセッション内で乱発しない）。
        if promptDrawCount == 3 {
            reviewPrompt.recordCompletedGame(source: .promptGachaThreshold)
        }
    }
}
