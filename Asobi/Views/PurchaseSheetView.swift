import SwiftUI

struct PurchaseSheetView: View {
    enum Target {
        case scene(GameScene)
        case promptCategory(PromptCategory)
        case allIn
    }

    let target: Target
    @Environment(\.dismiss) private var dismiss
    @Environment(PurchaseStore.self) private var purchases

    private var headline: String {
        switch target {
        case .scene(let s):
            return "\(s.name) シーンを開放"
        case .promptCategory(let c):
            return "\(c.displayName) パックを開放"
        case .allIn:
            return "オールインパック"
        }
    }

    private var subtitle: String {
        switch target {
        case .scene:
            return "このシーン専用のゲーム10種類が解放されます"
        case .promptCategory:
            return "20問の特別お題が解放されます"
        case .allIn:
            return "現在＆将来追加される全シーン・全お題パックが永続解放"
        }
    }

    private var price: String {
        switch target {
        case .scene:           return "¥120"
        case .promptCategory:  return "¥240"
        case .allIn:           return "¥1,200"
        }
    }

    private var symbolName: String {
        switch target {
        case .scene(let s):           return s.symbolName
        case .promptCategory(let c):  return c.symbol
        case .allIn:                  return "sparkles"
        }
    }

    private var accent: Color {
        switch target {
        case .scene(let s):  return s.accent
        case .promptCategory: return .blue
        case .allIn:          return Color(red: 0.85, green: 0.47, blue: 0.34)
        }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Spacer()
                Image(systemName: symbolName)
                    .font(.system(size: 80))
                    .foregroundStyle(accent)
                    .symbolEffect(.bounce, options: .nonRepeating)

                VStack(spacing: 12) {
                    Text(headline)
                        .font(.largeTitle.weight(.heavy))
                        .multilineTextAlignment(.center)
                    Text(subtitle)
                        .font(.body)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)
                }

                VStack(spacing: 8) {
                    Text(price)
                        .font(.system(size: 56, weight: .black, design: .rounded))
                        .foregroundStyle(accent)
                    Text("買い切り・以降ずっと使える")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                VStack(spacing: 12) {
                    Button {
                        unlock()
                    } label: {
                        Text("購入する（開発中：仮解放）")
                            .font(.title3.weight(.bold))
                            .frame(maxWidth: .infinity).padding()
                            .background(accent, in: Capsule())
                            .foregroundStyle(.white)
                    }
                    .buttonStyle(.plain)

                    Button {
                        dismiss()
                    } label: {
                        Text("あとで")
                            .font(.body.weight(.semibold))
                            .foregroundStyle(.secondary)
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal)

                Text("※ App Store 公開時に StoreKit で本物の決済に置き換えます。現状はテスト用の解放ボタンです。")
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
                    .padding(.bottom, 16)
            }
            .padding()
            .navigationTitle("コンテンツパック")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("閉じる") { dismiss() }
                }
            }
        }
    }

    private func unlock() {
        Haptics.success()
        switch target {
        case .scene(let s):
            purchases.unlockScene(s.id)
        case .promptCategory(let c):
            purchases.unlockPromptCategory(c)
        case .allIn:
            purchases.unlockAll()
        }
        dismiss()
    }
}
