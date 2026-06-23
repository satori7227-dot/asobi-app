import SwiftUI
import UIKit

enum FeedbackCategory: String, CaseIterable, Identifiable {
    case gameRequest
    case bug
    case question
    case other

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .gameRequest: return "新ゲーム要望"
        case .bug:         return "不具合報告"
        case .question:    return "質問"
        case .other:       return "その他"
        }
    }

    var localizedDisplayName: LocalizedStringKey { LocalizedStringKey(displayName) }

    var emoji: String {
        switch self {
        case .gameRequest: return "💡"
        case .bug:         return "🐛"
        case .question:    return "❓"
        case .other:       return "📝"
        }
    }
}

struct SuggestionFormView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.openURL) private var openURL
    @State private var bodyText: String = ""
    @State private var selectedSceneId: String = "any"
    @State private var selectedCategory: FeedbackCategory = .gameRequest
    @State private var copyFallbackShown: Bool = false

    private static let maxBodyLength = 1000
    private static let supportEmail = "satori7227@gmail.com"

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("こんなゲームが欲しい")
                        .font(.title.weight(.bold))

                    Text("種類を選んで、内容を教えてください。送信ボタンで標準メールアプリが開き、開発者宛のメール下書きが作成されます。")
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
                            .onChange(of: bodyText) { _, new in
                                if new.count > Self.maxBodyLength {
                                    bodyText = String(new.prefix(Self.maxBodyLength))
                                }
                            }
                    }

                    HStack {
                        Spacer()
                        Text("\(bodyText.count) / \(Self.maxBodyLength)")
                            .font(.caption2)
                            .foregroundStyle(bodyText.count >= Self.maxBodyLength ? .orange : .secondary)
                    }

                    Button {
                        openMailDraft()
                    } label: {
                        Text("メールアプリで送る")
                            .font(.body.weight(.semibold))
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.accentColor, in: Capsule())
                            .foregroundStyle(.white)
                    }
                    .disabled(bodyText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    .buttonStyle(.plain)
                    .accessibilityIdentifier("suggestion-send-button")

                    if copyFallbackShown {
                        VStack(alignment: .leading, spacing: 8) {
                            Label("メールアプリが見つかりませんでした", systemImage: "exclamationmark.triangle.fill")
                                .foregroundStyle(.orange)
                                .font(.subheadline.weight(.semibold))
                            Text("以下のメールアドレスをクリップボードにコピーしました。お好みのメールアプリ・Web メール等から送信してください。")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Text(Self.supportEmail)
                                .font(.caption.monospaced())
                                .padding(.vertical, 6)
                                .padding(.horizontal, 10)
                                .background(.orange.opacity(0.15), in: Capsule())
                        }
                        .padding()
                        .background(.orange.opacity(0.1), in: RoundedRectangle(cornerRadius: 12))
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

    private func openMailDraft() {
        let trimmed = bodyText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        guard let url = mailtoURL(body: trimmed) else { return }

        if UIApplication.shared.canOpenURL(url) {
            openURL(url) { _ in }
            Haptics.success()
            copyFallbackShown = false
        } else {
            UIPasteboard.general.string = Self.supportEmail
            Haptics.warning()
            copyFallbackShown = true
        }
    }

    private func mailtoURL(body: String) -> URL? {
        let sceneLabel: String = {
            if selectedSceneId == "any" { return "どのシーンでも" }
            return GameScene.initial.first { $0.id == selectedSceneId }?.name ?? selectedSceneId
        }()
        let subject = "[ASOBI] \(selectedCategory.displayName) / \(sceneLabel)"
        var components = URLComponents()
        components.scheme = "mailto"
        components.path = Self.supportEmail
        components.queryItems = [
            URLQueryItem(name: "subject", value: subject),
            URLQueryItem(name: "body", value: body),
        ]
        return components.url
    }
}
