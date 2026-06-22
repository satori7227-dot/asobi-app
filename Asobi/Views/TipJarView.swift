import SwiftUI

/// Tip Jar（投げ銭）画面雛形。
///
/// StoreKit2 連携は Apple Developer Program 契約後に
/// App Store Connect で消費型 IAP を3つ登録した上で
/// productIDs に id を入れて Product.products(for:) を呼ぶ。
///
/// 初期リリースでは Constants.tipJarEnabled = false で settings 画面から外しておく。
struct TipJarView: View {
    /// App Store Connect 側の Product ID（登録後に上書き）。
    enum TipTier: String, CaseIterable, Identifiable {
        case small = "com.idogawa.Asobi.tip.small"
        case medium = "com.idogawa.Asobi.tip.medium"
        case large = "com.idogawa.Asobi.tip.large"

        var id: String { rawValue }
        var displayYen: Int {
            switch self {
            case .small: return 120
            case .medium: return 600
            case .large: return 1200
            }
        }
        var emoji: String {
            switch self {
            case .small: return "☕"
            case .medium: return "🍰"
            case .large: return "🎁"
            }
        }
        var headline: String {
            switch self {
            case .small: return "コーヒー1杯"
            case .medium: return "ケーキセット"
            case .large: return "ちょっといいランチ"
            }
        }
        var subline: String {
            switch self {
            case .small: return "開発の眠気覚ましに"
            case .medium: return "更新のごほうびに"
            case .large: return "次の機能の助けに"
            }
        }
    }

    @Environment(\.dismiss) private var dismiss
    @State private var thanksTier: TipTier?
    @State private var lastError: String?

    var body: some View {
        NavigationStack {
            List {
                Section {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("ASOBI を応援する")
                            .font(.title3.bold())
                        Text("いただいたチップは新シーンや新お題の調査・追加に使わせていただきます。サブスクとは別枠で、何度でも送れます。")
                            .font(.callout)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 4)
                } header: {
                    Text("Tip Jar")
                }

                Section {
                    ForEach(TipTier.allCases) { tier in
                        Button {
                            send(tier)
                        } label: {
                            HStack(spacing: 12) {
                                Text(tier.emoji).font(.title)
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(tier.headline).font(.headline)
                                    Text(tier.subline)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                Spacer()
                                Text("¥\(tier.displayYen)")
                                    .font(.subheadline.monospacedDigit())
                            }
                            .padding(.vertical, 6)
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel("\(tier.headline) ¥\(tier.displayYen) を送る")
                    }
                } footer: {
                    Text("Apple ID の決済から課金されます。サブスク契約とは別枠の単発支払いです。")
                        .font(.footnote)
                }

                if let error = lastError {
                    Section { Text(error).foregroundStyle(.red) }
                }
            }
            .navigationTitle("開発を応援する")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("閉じる") { dismiss() }
                }
            }
            .alert("ありがとうございます！", isPresented: Binding(
                get: { thanksTier != nil },
                set: { if !$0 { thanksTier = nil } }
            )) {
                Button("どういたしまして") { thanksTier = nil }
            } message: {
                if let tier = thanksTier {
                    Text("\(tier.emoji) ¥\(tier.displayYen) を受け取りました。次の更新で還元できるよう励みます。")
                }
            }
        }
    }

    private func send(_ tier: TipTier) {
        AsobiLogger.purchase.info("tip jar tapped tier=\(tier.rawValue, privacy: .public)")
        // StoreKit2 接続後にここで Product.purchase() を呼ぶ。
        // 暫定実装ではローカル合計だけ更新して感謝表示する。
        let currentTotal = UserDefaults.standard.integer(forKey: AppStorageKeys.tipJarTotalYen)
        UserDefaults.standard.set(currentTotal + tier.displayYen, forKey: AppStorageKeys.tipJarTotalYen)
        thanksTier = tier
        Haptics.success()
    }
}

#Preview {
    TipJarView()
}
