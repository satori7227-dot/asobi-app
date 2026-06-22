import SwiftUI

struct KingGameDistributorView: View {
    /// 人数の下限・上限。王様くじは最低 2 人、UI レイアウト上 12 人までを上限とする。
    static let minPlayerCount = 2
    static let maxPlayerCount = 12

    @Environment(\.dismiss) private var dismiss
    @Environment(ReviewPromptManager.self) private var reviewPrompt
    @State private var playerCount: Int = 5
    @State private var numbers: [Int] = []
    @State private var kingIndex: Int = -1
    @State private var stage: Stage = .setup
    @State private var currentPlayer: Int = 0
    @State private var revealed: Bool = false

    enum Stage {
        case setup
        case handoff
        case reveal
        case done
    }

    var body: some View {
        NavigationStack {
            ZStack {
                switch stage {
                case .setup:    setupView
                case .handoff:  handoffView
                case .reveal:   revealView
                case .done:     doneView
                }
            }
            .navigationTitle("王様くじ")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    if stage != .setup {
                        Button("最初から") { reset() }
                    }
                }
                ToolbarItem(placement: .topBarTrailing) { Button("閉じる") { dismiss() } }
            }
        }
    }

    private var setupView: some View {
        VStack(spacing: 24) {
            Spacer()
            Image(systemName: "crown.fill")
                .font(.system(size: 80))
                .foregroundStyle(.yellow)
            Text("人数を選んでください")
                .font(.title2.weight(.semibold))

            HStack(spacing: 16) {
                Button { if playerCount > Self.minPlayerCount { playerCount -= 1 } } label: {
                    Image(systemName: "minus.circle.fill").font(.title)
                }.buttonStyle(.plain)
                Text("\(playerCount) 人")
                    .font(.system(size: 40, weight: .bold, design: .rounded))
                    .frame(minWidth: 120)
                    .contentTransition(.numericText())
                Button { if playerCount < Self.maxPlayerCount { playerCount += 1 } } label: {
                    Image(systemName: "plus.circle.fill").font(.title)
                }.buttonStyle(.plain)
            }
            .foregroundStyle(.yellow)

            Text("1人だけ王様、他は1〜\(playerCount-1)番が配られます")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            Spacer()

            Button {
                startDistribution()
            } label: {
                Text("配り始める")
                    .font(.title3.weight(.bold))
                    .frame(maxWidth: .infinity).padding()
                    .background(.yellow, in: Capsule())
                    .foregroundStyle(.black)
            }
            .padding(.horizontal)
        }
        .padding()
    }

    private var handoffView: some View {
        VStack(spacing: 24) {
            Spacer()
            Image(systemName: "iphone.gen3.radiowaves.left.and.right")
                .font(.system(size: 80))
                .foregroundStyle(.yellow)
            Text("\(currentPlayer + 1) 人目に渡す")
                .font(.system(size: 32, weight: .heavy, design: .rounded))
            Text("他の人に見られないように、本人だけがタップしてください")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            Spacer()
            Button {
                stage = .reveal
                revealed = false
            } label: {
                Text("受け取った（本人）")
                    .font(.title3.weight(.bold))
                    .frame(maxWidth: .infinity).padding()
                    .background(.yellow, in: Capsule())
                    .foregroundStyle(.black)
            }
            .padding(.horizontal)
        }
        .padding()
    }

    private var revealView: some View {
        VStack(spacing: 24) {
            Spacer()
            if !revealed {
                Image(systemName: "eye.slash.fill")
                    .font(.system(size: 80))
                    .foregroundStyle(.secondary)
                Text("長押しで自分の番号を表示")
                    .font(.title2.weight(.semibold))
                    .foregroundStyle(.secondary)
                Text("\(currentPlayer + 1) 人目")
                    .font(.headline)
                    .foregroundStyle(.tertiary)
                Spacer()
                tapToRevealButton
            } else {
                let isKing = currentPlayer == kingIndex
                let num = numbers[currentPlayer]
                if isKing {
                    Image(systemName: "crown.fill")
                        .font(.system(size: 120))
                        .foregroundStyle(.yellow)
                    Text("王様！")
                        .font(.system(size: 56, weight: .heavy, design: .rounded))
                        .foregroundStyle(.yellow)
                } else {
                    Text("\(num)")
                        .font(.system(size: 140, weight: .heavy, design: .rounded))
                        .foregroundStyle(.primary)
                    Text("番")
                        .font(.title)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Button {
                    nextPlayer()
                } label: {
                    Text(currentPlayer + 1 < playerCount ? "次の人へ渡す" : "全員に配り終わった")
                        .font(.title3.weight(.bold))
                        .frame(maxWidth: .infinity).padding()
                        .background(.yellow, in: Capsule())
                        .foregroundStyle(.black)
                }
                .padding(.horizontal)
            }
        }
        .padding()
    }

    private var tapToRevealButton: some View {
        Button {
            // タップで即表示
        } label: {
            Text("タップ&長押しで表示")
                .font(.title3.weight(.bold))
                .frame(maxWidth: .infinity).padding()
                .background(.regularMaterial, in: Capsule())
        }
        .buttonStyle(.plain)
        .padding(.horizontal)
        .simultaneousGesture(
            LongPressGesture(minimumDuration: 0.4)
                .onEnded { _ in
                    withAnimation { revealed = true }
                }
        )
        .simultaneousGesture(
            TapGesture()
                .onEnded {
                    withAnimation { revealed = true }
                }
        )
    }

    private var doneView: some View {
        VStack(spacing: 24) {
            Spacer()
            Image(systemName: "crown.fill")
                .font(.system(size: 100))
                .foregroundStyle(.yellow)
                .symbolEffect(.bounce, value: stage)
            Text("配布完了！")
                .font(.system(size: 32, weight: .heavy, design: .rounded))
            Text("王様が指令を出してください")
                .font(.title3)
                .foregroundStyle(.secondary)
            Spacer()
            Button {
                reset()
            } label: {
                Text("もう一度配る")
                    .font(.title3.weight(.bold))
                    .frame(maxWidth: .infinity).padding()
                    .background(.yellow, in: Capsule())
                    .foregroundStyle(.black)
            }
            .padding(.horizontal)
        }
        .padding()
    }

    private func startDistribution() {
        Haptics.medium()
        var nums = Array(1...(playerCount - 1))
        nums.shuffle()
        let kingPos = Int.random(in: 0..<playerCount)
        var result: [Int] = []
        var idx = 0
        for i in 0..<playerCount {
            if i == kingPos {
                result.append(0)
            } else {
                result.append(nums[idx])
                idx += 1
            }
        }
        numbers = result
        kingIndex = kingPos
        currentPlayer = 0
        stage = .handoff
    }

    private func nextPlayer() {
        if currentPlayer + 1 < playerCount {
            currentPlayer += 1
            revealed = false
            stage = .handoff
        } else {
            stage = .done
            // 配布完了＝ゲーム1本完遂の強いシグナル。
            reviewPrompt.recordCompletedGame(source: .kingGameDistributed)
            // 楽しい体験の頂点。条件揃っていればレビュー要請のチャンスを与える。
            reviewPrompt.requestReviewIfAppropriate()
        }
    }

    private func reset() {
        stage = .setup
        currentPlayer = 0
        numbers = []
        kingIndex = -1
        revealed = false
    }
}
