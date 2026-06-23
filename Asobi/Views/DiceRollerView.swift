import SwiftUI

struct DiceRollerView: View {
    /// サイコロ個数の上限。LazyVGrid 3 列で 10 個までは 4 行で収まる視認上の上限。
    static let maxDice = 10

    @Environment(\.dismiss) private var dismiss
    @State private var count: Int = 2
    @State private var rolls: [Int] = []
    @State private var rollTrigger: Int = 0

    private let faceSymbols = ["die.face.1.fill","die.face.2.fill","die.face.3.fill",
                                "die.face.4.fill","die.face.5.fill","die.face.6.fill"]

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                HStack(spacing: 16) {
                    Button {
                        if count > 1 { count -= 1 }
                    } label: { Image(systemName: "minus.circle.fill").font(.title) }
                    .buttonStyle(.plain)
                    .accessibilityLabel("サイコロの数を減らす")
                    Text("\(count) 個")
                        .font(.system(.title, design: .rounded, weight: .bold))
                        .frame(minWidth: 100)
                        .contentTransition(.numericText())
                        .accessibilityLabel("サイコロ \(count) 個")
                    Button {
                        if count < 6 { count += 1 }
                    } label: { Image(systemName: "plus.circle.fill").font(.title) }
                    .buttonStyle(.plain)
                    .accessibilityLabel("サイコロの数を増やす")
                }
                .foregroundStyle(.purple)

                if rolls.isEmpty {
                    Spacer()
                    Image(systemName: "die.face.5.fill")
                        .font(.system(size: 100))
                        .foregroundStyle(.purple.opacity(0.3))
                        .accessibilityHidden(true)
                    Text("「振る」を押してください")
                        .foregroundStyle(.secondary)
                    Spacer()
                } else {
                    Spacer()
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                        ForEach(Array(rolls.enumerated()), id: \.offset) { idx, roll in
                            Image(systemName: faceSymbols[max(0, min(5, roll-1))])
                                .font(.system(size: 60))
                                .foregroundStyle(.purple)
                                .symbolEffect(.bounce, value: rollTrigger)
                                .accessibilityLabel("\(idx + 1) 個目: \(roll)")
                        }
                    }
                    .padding(.horizontal)
                    Text("合計: \(rolls.reduce(0, +))")
                        .font(.title.weight(.heavy))
                        .contentTransition(.numericText())
                    Spacer()
                }

                Button {
                    roll()
                } label: {
                    Text(rolls.isEmpty ? "振る" : "もう一度")
                        .font(.title3.weight(.bold))
                        .frame(maxWidth: .infinity).padding()
                        .background(.purple, in: Capsule())
                        .foregroundStyle(.white)
                }
                .padding(.horizontal)
                .accessibilityLabel(rolls.isEmpty ? "サイコロを振る" : "もう一度サイコロを振る")
            }
            .padding()
            .navigationTitle("サイコロ")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) { Button("閉じる") { dismiss() } }
            }
        }
    }

    private func roll() {
        Haptics.heavy()
        withAnimation(.spring) {
            rolls = (0..<count).map { _ in Int.random(in: 1...6) }
            rollTrigger += 1
        }
    }
}
