import SwiftUI

struct CoinFlipView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var result: Side?
    @State private var rotationDeg: Double = 0
    @State private var flipping = false

    enum Side: String {
        case heads = "表"
        case tails = "裏"
        var symbol: String {
            self == .heads ? "circle.circle.fill" : "circle.circle"
        }
        var color: Color {
            self == .heads ? .yellow : .gray
        }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 32) {
                Spacer()
                Image(systemName: result?.symbol ?? "circle.dashed")
                    .font(.system(size: 140))
                    .foregroundStyle(result?.color ?? .secondary.opacity(0.4))
                    .rotation3DEffect(.degrees(rotationDeg), axis: (x: 0, y: 1, z: 0))

                if let result = result {
                    Text(result.rawValue)
                        .font(.system(size: 56, weight: .heavy, design: .rounded))
                        .contentTransition(.opacity)
                } else {
                    Text("どっち？")
                        .font(.title.weight(.semibold))
                        .foregroundStyle(.secondary)
                }
                Spacer()

                Button {
                    flip()
                } label: {
                    Text(result == nil ? "投げる" : "もう一度")
                        .font(.title3.weight(.bold))
                        .frame(maxWidth: .infinity).padding()
                        .background(.yellow, in: Capsule())
                        .foregroundStyle(.black)
                }
                .padding(.horizontal)
                .disabled(flipping)
            }
            .padding()
            .navigationTitle("コイン")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) { Button("閉じる") { dismiss() } }
            }
        }
    }

    private func flip() {
        flipping = true
        Haptics.medium()
        withAnimation(.easeInOut(duration: 0.6)) {
            rotationDeg += 720
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            result = Bool.random() ? .heads : .tails
            Haptics.tap()
            flipping = false
        }
    }
}
