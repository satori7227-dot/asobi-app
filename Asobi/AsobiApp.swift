import SwiftUI

@main
struct AsobiApp: App {
    @State private var repo = GameRepository()
    @State private var feedback = FeedbackStore()
    @State private var prompts = PromptRepository()
    @State private var purchases = PurchaseStore()
    @State private var playCount = PlayCountStore()
    @State private var reviewPrompt = ReviewPromptManager()
    @State private var collections = CollectionStore()
    @State private var deepLinkRouter = DeepLinkRouter()

    init() {
        PersistenceMigrator.migrateIfNeeded()
        let preferred = Locale.preferredLanguages.first ?? "unknown"
        let region = Locale.current.region?.identifier ?? "unknown"
        AsobiLogger.lifecycle.info(
            "ASOBI launched, schema=\(PersistenceSchema.current, privacy: .public) lang=\(preferred, privacy: .public) region=\(region, privacy: .public)"
        )
    }

    var body: some SwiftUI.Scene {
        WindowGroup {
            ContentView()
                .environment(repo)
                .environment(feedback)
                .environment(prompts)
                .environment(purchases)
                .environment(playCount)
                .environment(reviewPrompt)
                .environment(collections)
                .environment(deepLinkRouter)
                .onAppear { reviewPrompt.recordLaunch() }
                .onOpenURL { url in deepLinkRouter.handle(url: url) }
        }
    }
}

enum AsobiRoute: Hashable {
    case context(GameScene)
    case proposal(GameScene, ProposalContext)
}

struct ContentView: View {
    @State private var path = NavigationPath()
    @State private var showSuggestion = false
    @State private var showFavorites = false
    @State private var showTools = false
    @State private var showCollections = false
    @State private var showSettings = false
    @State private var deepLinkedGame: Game?
    @State private var lastContext = ProposalContext()
    @Environment(DeepLinkRouter.self) private var deepLinkRouter
    @Environment(GameRepository.self) private var repo
    @AppStorage(AppStorageKeys.onboardingDone) private var onboardingDone: Bool = false

    private func consume(_ link: DeepLink) {
        switch link {
        case .scene(let id):
            if let scene = GameScene.initial.first(where: { $0.id == id }) {
                path = NavigationPath()
                path.append(AsobiRoute.context(scene))
            }
        case .game(let id):
            // 指定 id のゲームをシートで開く。見つからなければ何もしない。
            if let game = repo.games.first(where: { $0.id == id }) {
                deepLinkedGame = game
            }
        case .favorites:
            showFavorites = true
        case .collections:
            showCollections = true
        }
        deepLinkRouter.pending = nil
    }

    var body: some View {
        NavigationStack(path: $path) {
            ScenePickerView(
                path: $path,
                showSuggestion: $showSuggestion,
                showFavorites: $showFavorites,
                showTools: $showTools,
                showCollections: $showCollections,
                showSettings: $showSettings
            )
            .navigationTitle("ASOBI")
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(for: AsobiRoute.self) { route in
                switch route {
                case .context(let scene):
                    ContextInputView(scene: scene, path: $path, context: $lastContext)
                case .proposal(let scene, let context):
                    ProposalView(scene: scene, context: context)
                }
            }
            .sheet(isPresented: $showSuggestion) {
                SuggestionFormView()
            }
            .sheet(isPresented: $showFavorites) {
                FavoritesView()
            }
            .sheet(isPresented: $showTools) {
                ToolsetView()
            }
            .sheet(isPresented: $showCollections) {
                CollectionsView()
            }
            .sheet(item: $deepLinkedGame) { game in
                // Deep Link 経由で開く詳細。シーン情報がないので、ゲームが属する先頭シーンで代用する。
                let scene = GameScene.initial.first { game.scenes.contains($0.id) }
                    ?? GameScene.initial[0]
                GameDetailView(game: game, scene: scene)
                    .presentationDetents([.medium, .large])
            }
            .sheet(isPresented: $showSettings) {
                SettingsView()
            }
            .fullScreenCover(isPresented: Binding(
                get: { !onboardingDone },
                set: { newValue in onboardingDone = !newValue }
            )) {
                OnboardingView(isDone: Binding(
                    get: { onboardingDone },
                    set: { onboardingDone = $0 }
                ))
            }
            .onChange(of: deepLinkRouter.pending) { _, newValue in
                if let link = newValue { consume(link) }
            }
        }
    }
}

#Preview {
    ContentView()
        .environment(GameRepository())
        .environment(FeedbackStore())
        .environment(PromptRepository())
        .environment(PurchaseStore())
        .environment(PlayCountStore())
        .environment(ReviewPromptManager())
        .environment(CollectionStore())
        .environment(DeepLinkRouter())
}
