import SwiftUI

struct SuggestionFormView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var bodyText: String = ""
    @State private var selectedSceneId: String = "any"
    @State private var selectedCategory: FeedbackCategory = .gameRequest
    @State private var sendState: SendState = .idle

    enum SendState {
        case idle
        case sending
        case sent
        case failed(String)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("こんなゲームが欲しい")
                        .font(.title.weight(.bold))

                    Text("種類を選んで、内容を教えてください。送信ボタンで開発者に直接届きます。")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    VStack(alignment: .leading, spacing: 8) {
                        Text("種類").font(.caption.weight(.semibold)).foregroundStyle(.secondary)
                        HStack(spacing: 8) {
                            ForEach(FeedbackCategory.allCases) { cat in
                                Button {
                                    withAnimation(.spring) { selectedCategory = cat }
                                    Haptics.tap()
                                } label: {
                                    VStack(spacing: 4) {
                                        Text(cat.emoji).font(.title3)
                                        Text(cat.localizedDisplayName)
                                            .font(.caption2.weight(.semibold))
                                            .lineLimit(1)
                                            .minimumScaleFactor(0.7)
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 10)
                                    .background(
                                        selectedCategory == cat ? Color.accentColor.opacity(0.2) : Color(.secondarySystemBackground),
                                        in: RoundedRectangle(cornerRadius: 12)
                                    )
                                    .foregroundStyle(selectedCategory == cat ? Color.accentColor : .primary)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text("関連シーン").font(.caption.weight(.semibold)).foregroundStyle(.secondary)
                        Picker("シーン", selection: $selectedSceneId) {
                            Text("どのシーンでも").tag("any")
                            ForEach(GameScene.initial) { s in
                                Text(s.localizedName).tag(s.id)
                            }
                        }
                        .pickerStyle(.menu)
                    }

                    ZStack(alignment: .topLeading) {
                        if bodyText.isEmpty {
                            Text("例：3人で短時間で盛り上がれる罰ゲーム決めゲーム")
                                .foregroundStyle(.tertiary)
                                .padding(16)
                                .allowsHitTesting(false)
                        }
                        TextEditor(text: $bodyText)
                            .frame(minHeight: 200)
                            .padding(8)
                            .scrollContentBackground(.hidden)
                            .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 12))
                    }

                    Button {
                        Task { await send() }
                    } label: {
                        HStack {
                            if case .sending = sendState {
                                ProgressView()
                                    .progressViewStyle(.circular)
                                    .tint(.white)
                            }
                            Text(buttonLabel)
                                .font(.body.weight(.semibold))
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.accentColor, in: Capsule())
                        .foregroundStyle(.white)
                    }
                    .disabled(bodyText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isSending)
                    .buttonStyle(.plain)
                    .accessibilityIdentifier("suggestion-send-button")

                    switch sendState {
                    case .sent:
                        VStack(alignment: .leading, spacing: 6) {
                            Label("送信しました！", systemImage: "checkmark.circle.fill")
                                .foregroundStyle(.green)
                                .font(.subheadline.weight(.semibold))
                            Text("ご意見は開発者に直接届きました。今後のアップデートに反映していきます。")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        .padding()
                        .background(.green.opacity(0.1), in: RoundedRectangle(cornerRadius: 12))
                    case .failed(let msg):
                        VStack(alignment: .leading, spacing: 6) {
                            Label("送信に失敗しました", systemImage: "exclamationmark.triangle.fill")
                                .foregroundStyle(.orange)
                                .font(.subheadline.weight(.semibold))
                            Text(msg)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Text("ネットワーク接続を確認して、もう一度お試しください。")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            // Webhook 失敗時の最終フォールバック：標準メーラーで開発者に直接届ける。
                            if let url = mailtoFallbackURL() {
                                Link(destination: url) {
                                    Label("メールで送る", systemImage: "envelope.fill")
                                        .font(.caption.weight(.semibold))
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 6)
                                        .background(.orange.opacity(0.25), in: Capsule())
                                }
                                .padding(.top, 4)
                            }
                        }
                        .padding()
                        .background(.orange.opacity(0.1), in: RoundedRectangle(cornerRadius: 12))
                    default:
                        EmptyView()
                    }
                }
                .padding()
            }
            .navigationTitle("アイデア箱")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("閉じる") { dismiss() }
                }
            }
        }
    }

    /// Webhook 送信に失敗した場合の最終フォールバック。
    /// 標準メーラーを開いて開発者 (satori7227@gmail.com) 宛のメールに本文を仕込む。
    private func mailtoFallbackURL() -> URL? {
        let trimmed = bodyText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }
        let sceneLabel: String = {
            if selectedSceneId == "any" { return "どのシーンでも" }
            return GameScene.initial.first { $0.id == selectedSceneId }?.name ?? selectedSceneId
        }()
        let subject = "[ASOBI] \(selectedCategory.displayName) / \(sceneLabel)"
        let body = trimmed
        var components = URLComponents()
        components.scheme = "mailto"
        components.path = "satori7227@gmail.com"
        components.queryItems = [
            URLQueryItem(name: "subject", value: subject),
            URLQueryItem(name: "body", value: body),
        ]
        return components.url
    }

    private var isSending: Bool {
        if case .sending = sendState { return true }
        return false
    }

    private var buttonLabel: String {
        switch sendState {
        case .idle:      return "送信する"
        case .sending:   return "送信中..."
        case .sent:      return "もう一度送る"
        case .failed:    return "もう一度送る"
        }
    }

    private func send() async {
        let trimmed = bodyText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        let sceneLabel: String = {
            if selectedSceneId == "any" { return "どのシーンでも" }
            return GameScene.initial.first { $0.id == selectedSceneId }?.name ?? selectedSceneId
        }()

        sendState = .sending
        do {
            try await FeedbackWebhook.send(category: selectedCategory, sceneLabel: sceneLabel, body: trimmed)
            Haptics.success()
            sendState = .sent
            bodyText = ""
        } catch {
            Haptics.warning()
            sendState = .failed(error.localizedDescription)
        }
    }
}
