import Foundation

enum Constants {
    /// プレミアム機能（IAP）の有効化フラグ
    /// - false: 初回リリース時。全シーン・全お題が無料で開放、ロックUI 非表示
    /// - true: Phase β 以降。プレミアムシーン・お題に課金ゲート、StoreKit 連動
    static let premiumEnabled = false

    /// オンボーディング 3 画面の表示制御
    /// - false: 起動時に常に表示（開発時）
    /// - true: AppStorage で初回のみ表示
    static let onboardingPersistent = true

    /// 月間プレイ回数ベースのソフトペイウォール
    /// - false: 初回リリース時。無制限プレイ可
    /// - true: 月 PlayCountStore.monthlyLimit 本超でペイウォール提示
    static let softPaywallEnabled = false

    /// Tip Jar（投げ銭IAP）の UI 表示
    /// - false: IAP 未登録の間は設定画面に出さない
    /// - true: Apple Developer 契約後に有効化
    static let tipJarEnabled = false

    /// 匿名イベント計測（AsobiAnalytics）の有効化
    /// - false: 初回リリース時。no-op、App Privacy = Data Not Collected を維持
    /// - true: TelemetryDeck 等のバックエンドを差し込んだ後に有効化（Privacy Manifest 更新必須）
    static let analyticsEnabled = false
}
