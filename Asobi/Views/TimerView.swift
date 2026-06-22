import SwiftUI
import AudioToolbox

struct TimerView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(ReviewPromptManager.self) private var reviewPrompt
    @State private var seconds: Int = 30
    @State private var remaining: Int = 30
    @State private var running = false
    @State private var countdownTask: Task<Void, Never>?

    private let presets = [5, 10, 30, 60, 180, 300]

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Spacer()
                ZStack {
                    Circle()
                        .stroke(.orange.opacity(0.15), lineWidth: 16)
                    Circle()
                        .trim(from: 0, to: progress)
                        .stroke(.orange, style: StrokeStyle(lineWidth: 16, lineCap: .round))
                        .rotationEffect(.degrees(-90))
                        .animation(.linear(duration: 0.2), value: progress)
                    VStack {
                        Text(formatTime(remaining))
                            .font(.system(size: 56, weight: .heavy, design: .rounded))
                            .contentTransition(.numericText())
                        Text("/ \(formatTime(seconds))")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
                .frame(width: 240, height: 240)

                HStack(spacing: 8) {
                    ForEach(presets, id: \.self) { p in
                        Button {
                            setPreset(p)
                        } label: {
                            Text(formatTime(p))
                                .font(.caption.weight(.semibold))
                                .padding(.horizontal, 10).padding(.vertical, 6)
                                .background(
                                    seconds == p ? Color.orange.opacity(0.2) : Color(.secondarySystemBackground),
                                    in: Capsule()
                                )
                                .foregroundStyle(seconds == p ? .orange : .primary)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal)

                Stepper(value: Binding(
                    get: { seconds },
                    set: { setPreset($0) }
                ), in: 1...3600, step: 10) {
                    Text("自分で指定: \(seconds) 秒")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                }
                .padding(.horizontal, 32)
                .accessibilityIdentifier("timer-custom-stepper")

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

                    Button {
                        running ? stop() : start()
                    } label: {
                        Text(running ? "一時停止" : (remaining == 0 ? "リセット" : "スタート"))
                            .font(.title3.weight(.bold))
                            .frame(maxWidth: .infinity).padding()
                            .background(.orange, in: Capsule())
                            .foregroundStyle(.white)
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal)
            }
            .padding(.vertical)
            .navigationTitle("タイマー")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) { Button("閉じる") { dismiss() } }
            }
            .onDisappear {
                countdownTask?.cancel()
                running = false
            }
        }
    }

    private var progress: Double {
        guard seconds > 0 else { return 0 }
        return Double(remaining) / Double(seconds)
    }

    private func formatTime(_ s: Int) -> String {
        let m = s / 60
        let rest = s % 60
        return String(format: "%d:%02d", m, rest)
    }

    private func setPreset(_ p: Int) {
        stop()
        seconds = p
        remaining = p
    }

    private func start() {
        let preset = seconds
        if remaining == 0 { remaining = seconds }
        running = true
        countdownTask?.cancel()
        countdownTask = Task { @MainActor in
            while remaining > 0 {
                if Task.isCancelled { return }
                try? await Task.sleep(nanoseconds: 1_000_000_000)
                if Task.isCancelled { return }
                if remaining > 0 { remaining -= 1 }
            }
            running = false
            playFinishSound()
            // 30秒以上のタイマーが自然満了 = 制限時間ゲーム1本相当のシグナル。
            // 5秒・10秒の試運転は除外する。
            if preset >= 30 {
                reviewPrompt.recordCompletedGame(source: .timerFinished)
            }
        }
    }

    private func stop() {
        countdownTask?.cancel()
        running = false
    }

    private func playFinishSound() {
        AudioServicesPlaySystemSound(1005)
    }

    private func reset() {
        stop()
        remaining = seconds
    }
}
