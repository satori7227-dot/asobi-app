import SwiftUI

struct CardDrawView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var deck: [Card] = Card.fullDeck.shuffled()
    @State private var drawn: [Card] = []
    @State private var drawTrigger: Int = 0

    struct Card: Hashable {
        let suit: Suit
        let rank: Int

        enum Suit: String, CaseIterable {
            case spade, heart, diamond, club
            var symbol: String {
                switch self {
                case .spade:   return "suit.spade.fill"
                case .heart:   return "suit.heart.fill"
                case .diamond: return "suit.diamond.fill"
                case .club:    return "suit.club.fill"
                }
            }
            var color: Color {
                self == .heart || self == .diamond ? .red : .primary
            }
        }

        var rankLabel: String {
            switch rank {
            case 1:  return "A"
            case 11: return "J"
            case 12: return "Q"
            case 13: return "K"
            default: return "\(rank)"
            }
        }

        static let fullDeck: [Card] = Suit.allCases.flatMap { suit in
            (1...13).map { Card(suit: suit, rank: $0) }
        }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                VStack(spacing: 4) {
                    Text("残り \(deck.count) / 52 枚")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    ProgressView(value: Double(deck.count), total: 52)
                        .progressViewStyle(.linear)
                        .tint(.red)
                        .frame(maxWidth: 220)
                        .animation(.easeInOut(duration: 0.25), value: deck.count)
                }
                .padding(.horizontal)

                if let last = drawn.last {
                    cardView(last)
                        .frame(width: 160, height: 220)
                        .symbolEffect(.bounce, value: drawTrigger)
                } else {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(.regularMaterial)
                        .overlay {
                            Image(systemName: "rectangle.stack.fill")
                                .font(.system(size: 60))
                                .foregroundStyle(.secondary)
                        }
                        .frame(width: 160, height: 220)
                }

                if drawn.count > 1 {
                    ScrollView(.horizontal) {
                        HStack {
                            ForEach(drawn.dropLast().reversed(), id: \.self) { c in
                                cardView(c)
                                    .frame(width: 64, height: 90)
                            }
                        }
                        .padding(.horizontal)
                    }
                }

                Spacer()

                HStack(spacing: 12) {
                    Button {
                        reset()
                    } label: {
                        Label("リセット", systemImage: "arrow.counterclockwise")
                            .frame(maxWidth: .infinity).padding()
                            .background(.regularMaterial, in: Capsule())
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("トランプをリセット")

                    Button {
                        draw()
                    } label: {
                        Text("1枚引く")
                            .font(.title3.weight(.bold))
                            .frame(maxWidth: .infinity).padding()
                            .background(.red, in: Capsule())
                            .foregroundStyle(.white)
                    }
                    .buttonStyle(.plain)
                    .disabled(deck.isEmpty)
                    .accessibilityLabel(deck.isEmpty ? "デッキが空" : "トランプを1枚引く")
                }
                .padding(.horizontal)
            }
            .padding()
            .navigationTitle("トランプ")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) { Button("閉じる") { dismiss() } }
            }
        }
    }

    private func cardView(_ c: Card) -> some View {
        VStack {
            HStack {
                Text(c.rankLabel)
                    .font(.title.weight(.bold))
                Spacer()
            }
            Spacer()
            Image(systemName: c.suit.symbol)
                .font(.system(size: 48))
            Spacer()
            HStack {
                Spacer()
                Text(c.rankLabel)
                    .font(.title.weight(.bold))
                    .rotationEffect(.degrees(180))
            }
        }
        .foregroundStyle(c.suit.color)
        .padding()
        .background(.background, in: RoundedRectangle(cornerRadius: 12))
        .overlay {
            RoundedRectangle(cornerRadius: 12)
                .stroke(.secondary.opacity(0.3), lineWidth: 1)
        }
    }

    private func draw() {
        guard !deck.isEmpty else { return }
        withAnimation(.spring) {
            drawn.append(deck.removeLast())
            drawTrigger += 1
        }
    }

    private func reset() {
        withAnimation(.spring) {
            deck = Card.fullDeck.shuffled()
            drawn = []
        }
    }
}
