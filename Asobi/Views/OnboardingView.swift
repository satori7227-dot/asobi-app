import SwiftUI

struct OnboardingView: View {
    @Binding var isDone: Bool
    @State private var page = 0

    private let pages: [OnboardingPage] = [
        OnboardingPage(
            symbol: "sparkles",
            symbolColor: Color(red: 0.85, green: 0.47, blue: 0.34),
            title: "シーンに合うゲームを",
            subtitle: "飲み会・旅行・キャンプ・カップル・リモート飲み……\nどの場面でもアプリが3つ提案します。"
        ),
        OnboardingPage(
            symbol: "die.face.5.fill",
            symbolColor: .purple,
            title: "道具はアプリで",
            subtitle: "サイコロ・トランプ・コイン・ルーレット・タイマー・お題ガチャ・王様くじ。\n手ぶらでも遊べます。"
        ),
        OnboardingPage(
            symbol: "lightbulb.fill",
            symbolColor: .yellow,
            title: "あなたの一票が育てる",
            subtitle: "👍👎で精度が上がり、アイデア箱で新しいゲームを追加。\n使うほど自分に合う提案に。"
        ),
    ]

    var body: some View {
        VStack(spacing: 0) {
            // 右上の「スキップ」リンク。最終ページでは「はじめる」ボタンと役割が重なるので隠す。
            HStack {
                Spacer()
                if page < pages.count - 1 {
                    Button("スキップ") {
                        isDone = true
                    }
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 16)
                    .padding(.top, 12)
                    .accessibilityIdentifier("onboarding-skip-button")
                }
            }
            .frame(height: 44)

            TabView(selection: $page) {
                ForEach(Array(pages.enumerated()), id: \.offset) { idx, p in
                    OnboardingPageView(page: p).tag(idx)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .always))
            .indexViewStyle(.page(backgroundDisplayMode: .always))

            Button {
                if page < pages.count - 1 {
                    withAnimation(.spring) { page += 1 }
                } else {
                    isDone = true
                }
            } label: {
                Text(LocalizedStringKey(page < pages.count - 1 ? "次へ" : "はじめる"))
                    .font(.title3.weight(.bold))
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(red: 0.85, green: 0.47, blue: 0.34), in: Capsule())
                    .foregroundStyle(.white)
            }
            .buttonStyle(.plain)
            .padding(.horizontal)
            .padding(.bottom, 24)
            .accessibilityIdentifier("onboarding-next-button")
        }
        .background(.background)
    }
}

private struct OnboardingPage {
    let symbol: String
    let symbolColor: Color
    let title: String
    let subtitle: String

    var localizedTitle: LocalizedStringKey { LocalizedStringKey(title) }
    var localizedSubtitle: LocalizedStringKey { LocalizedStringKey(subtitle) }
}

private struct OnboardingPageView: View {
    let page: OnboardingPage

    var body: some View {
        VStack(spacing: 28) {
            Spacer()
            Image(systemName: page.symbol)
                .font(.system(size: 92))
                .foregroundStyle(page.symbolColor)
                .symbolEffect(.bounce, options: .nonRepeating)
            VStack(spacing: 12) {
                Text(page.localizedTitle)
                    .font(.largeTitle.weight(.heavy))
                    .multilineTextAlignment(.center)
                Text(page.localizedSubtitle)
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
            }
            Spacer()
            Spacer()
        }
    }
}
