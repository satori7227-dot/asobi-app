import SwiftUI

struct RoulettePickerView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(ReviewPromptManager.self) private var reviewPrompt
    @State private var newName: String = ""
    @State private var names: [String] = []
    @State private var winner: String?
    @State private var spinning = false
    @State private var spinTrigger: Int = 0
    @State private var spinTask: Task<Void, Never>?

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                HStack {
                    TextField("名前を追加", text: $newName)
                        .textFieldStyle(.roundedBorder)
                        .onSubmit(addName)
                    Button {
                        addName()
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("名前を追加")
                }
                .padding(.horizontal)

                if !names.isEmpty {
                    ScrollView {
                        VStack(spacing: 6) {
                            ForEach(Array(names.enumerated()), id: \.offset) { idx, name in
                                HStack {
                                    Text(name)
                                        .fontWeight(name == winner ? .heavy : .regular)
                                        .foregroundStyle(name == winner ? Color.green : .primary)
                                    Spacer()
                                    if name == winner {
                                        Image(systemName: "star.fill")
                                            .foregroundStyle(.green)
                                            .symbolEffect(.bounce, value: spinTrigger)
                                    }
                                    Button {
                                        remove(at: idx)
                                    } label: {
                                        Image(systemName: "minus.circle")
                                            .foregroundStyle(.secondary)
                                    }
                                    .buttonStyle(.plain)
                                    .accessibilityLabel("\(name) を削除")
                                }
                                .padding(.horizontal, 12)
                                .padding(.vertical, 10)
                                .background(
                                    name == winner ? Color.green.opacity(0.15) : Color(.secondarySystemBackground),
                                    in: RoundedRectangle(cornerRadius: 12)
                                )
                            }
                        }
                        .padding(.horizontal)
                    }
                } else {
                    Spacer()
                    Image(systemName: "person.crop.circle.badge.questionmark.fill")
                        .font(.system(size: 80))
                        .foregroundStyle(.secondary.opacity(0.4))
                    Text("名前を2件以上追加してください")
                        .foregroundStyle(.secondary)
                    Spacer()
                }

                Button {
                    spin()
                } label: {
                    Text(winner == nil ? "ルーレット開始" : "もう一度")
                        .font(.title3.weight(.bold))
                        .frame(maxWidth: .infinity).padding()
                        .background(.green, in: Capsule())
                        .foregroundStyle(.white)
                }
                .padding(.horizontal)
                .disabled(names.count < 2 || spinning)
                .accessibilityLabel(winner == nil ? "ルーレットを回す" : "もう一度ルーレットを回す")
            }
            .padding(.vertical)
            .navigationTitle("ルーレット")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) { Button("閉じる") { dismiss() } }
            }
            .onDisappear {
                spinTask?.cancel()
                spinning = false
            }
        }
    }

    /// 名前1件あたりの最大文字数。UI 内のリスト行を1行で収めるための上限。
    private static let nameMaxLength = 30

    private func addName() {
        let trimmed = String(newName.trimmingCharacters(in: .whitespaces).prefix(Self.nameMaxLength))
        guard !trimmed.isEmpty else { return }
        // 既存名と重複したら追加しない（同名で見分けがつかなくなるのを防ぐ）。
        guard !names.contains(trimmed) else {
            newName = ""
            Haptics.warning()
            return
        }
        names.append(trimmed)
        newName = ""
    }

    private func remove(at idx: Int) {
        guard names.indices.contains(idx) else { return }
        if names[idx] == winner { winner = nil }
        names.remove(at: idx)
    }

    private func spin() {
        spinTask?.cancel()
        spinning = true
        winner = nil
        spinTask = Task { @MainActor in
            let total = 18
            for _ in 0..<total {
                if Task.isCancelled { return }
                winner = names.randomElement()
                Haptics.selection()
                try? await Task.sleep(nanoseconds: 80_000_000)
            }
            spinning = false
            spinTrigger += 1
            Haptics.success()
            // ルーレット確定＝罰ゲーム決め1回相当の完了シグナル。
            reviewPrompt.recordCompletedGame(source: .rouletteSpun)
        }
    }
}
