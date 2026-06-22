import SwiftUI

/// アプリ設定 / About 画面。
///
/// 現状の収納物:
/// - About 情報（バージョン・ビルド番号・対応言語）
/// - プライバシーポリシーへのリンク
/// - サポート（意見箱への動線）
/// - Tip Jar（Constants.tipJarEnabled が true のときだけ表示）
///
/// 将来追加する候補は次のとおりだが、今は出さない:
/// - 言語切替（端末設定への誘導 Link）
/// - Restore Purchases
/// - 通知設定
struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(FeedbackStore.self) private var feedback
    @Environment(CollectionStore.self) private var collections
    @State private var showTipJar = false
    @State private var showSuggestion = false

    private var totalPlayed: Int {
        UserDefaults.standard.integer(forKey: AppStorageKeys.totalPlayedGames)
    }

    private var appVersion: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "—"
    }

    private var buildNumber: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "—"
    }

    private var privacyPolicyURL: URL? {
        URL(string: "https://satori7227-dot.github.io/asobi-privacy/")
    }

    var body: some View {
        NavigationStack {
            List {
                Section("ASOBI について") {
                    LabeledContent("バージョン", value: "\(appVersion) (\(buildNumber))")
                    LabeledContent("対応言語", value: "日本語 / English")
                }

                Section("あなたの記録") {
                    LabeledContent("お気に入り", value: "\(feedback.favoriteGameIds.count)")
                    LabeledContent("コレクション", value: "\(collections.collections.count)")
                    LabeledContent("これまでに遊んだ数", value: "\(totalPlayed)")
                }

                Section("リンク") {
                    if let url = privacyPolicyURL {
                        Link(destination: url) {
                            Label("プライバシーポリシー", systemImage: "lock.shield")
                        }
                    }
                    Button {
                        showSuggestion = true
                    } label: {
                        Label("意見・要望を送る", systemImage: "lightbulb.fill")
                    }
                    .foregroundStyle(.primary)
                }

                if Constants.tipJarEnabled {
                    Section("応援") {
                        Button {
                            showTipJar = true
                        } label: {
                            Label("開発を応援する", systemImage: "heart.fill")
                                .foregroundStyle(.pink)
                        }
                    }
                }

                Section {
                    Text("ASOBI は個人開発の iOS アプリです。コードの大半とゲーム DB のキュレーションは1人で行っています。意見箱からのフィードバックが何より励みになります。")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle("設定")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("閉じる") { dismiss() }
                }
            }
            .sheet(isPresented: $showTipJar) { TipJarView() }
            .sheet(isPresented: $showSuggestion) { SuggestionFormView() }
        }
    }
}

#Preview {
    SettingsView()
        .environment(FeedbackStore())
        .environment(CollectionStore())
}
