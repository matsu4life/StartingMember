# StartingMember 設計書

## 1. アプリ概要

| 項目 | 内容 |
|------|------|
| アプリ名 | StartingMember |
| バンドルID | com.matsumoto.StartingMember |
| バージョン | 1.0 |
| プラットフォーム | iOS 18.0以上 / iPhone専用 |
| 言語 | Swift / SwiftUI |
| 開発者 | TAKAYUKI MATSUMOTO |
| 配信地域 | 日本のみ |
| 価格 | 無料 |

### コンセプト

サッカーチームのスタメンをかんたんに組んで共有できるiOSアプリ。  
**プライバシーファースト設計** — すべてのデータは端末内にのみ保存し、外部送信は一切行わない。

---

## 2. 主な機能

| 機能 | 説明 |
|------|------|
| チーム管理 | 複数チームの作成・編集・削除 |
| 選手登録 | 名前・背番号・ポジション・写真・キャプテン設定 |
| スタッフ登録 | 監督・コーチ等の役割・写真管理 |
| フォーメーション設定 | 5人制〜11人制対応、プリセット＋カスタム |
| スタメン編集 | ドラッグ＆ドロップで選手をピッチ上に配置 |
| スタメン共有 | 画像カードを生成してシェア |
| スタメン履歴 | 過去のスタメンを保存・呼び出し |
| 背景写真 | チーム一覧・選手一覧の背景に写真を設定（透明度・サイズ調整可） |

---

## 3. アーキテクチャ

```
StartingMember/
├── Models/
│   ├── Team.swift               チームモデル
│   ├── Player.swift             選手モデル（Status・Position・IconStyle列挙型を含む）
│   ├── Player+Image.swift       写真処理拡張（photoUIImage・initial）
│   ├── Staff.swift              スタッフモデル
│   ├── Lineup.swift             スタメン・フォーメーションモデル
│   ├── FormationPresets.swift   フォーメーションプリセット定義
│   └── BackgroundRemover.swift  背景透過処理（Vision フレームワーク）
│
├── ViewModels/
│   └── AppStore.swift           @MainActor ObservableObject（全データ管理）
│
├── Views/
│   ├── SplashView.swift         起動画面（soccer_playerアニメーション）
│   ├── TeamListView.swift       チーム一覧・背景写真設定
│   ├── TeamSettingsView.swift   チーム設定（名前・ユニフォーム・エンブレム）
│   ├── PlayerListView.swift     選手・スタッフ一覧
│   ├── PlayerEditView.swift     選手編集（写真・ポジション・役割）
│   ├── PlayerAvatar.swift       丸型選手アイコン（写真 or 背番号）
│   ├── StaffEditView.swift      スタッフ編集
│   ├── LineupSetupView.swift    スタメン設定（フォーメーション・試合形式選択）
│   ├── LineupEditorView.swift   スタメン編集（ピッチUI・ドラッグ配置・共有）
│   ├── LineupHistoryView.swift  スタメン履歴一覧
│   ├── SoccerBackground.swift   ピッチ描画（PitchBackground）・背景画像（BackgroundImageView）
│   ├── JerseyView.swift         ユニフォーム描画
│   ├── TeamEmblemIcon.swift     チームエンブレムアイコン
│   ├── PhotoCropView.swift      写真トリミング
│   └── CameraView.swift         カメラ撮影
│
└── Assets.xcassets/
    ├── AppIcon                  アプリアイコン（1024x1024）
    ├── soccer_player            スプラッシュキャラクター画像
    ├── jersey_mask              ユニフォームマスク
    ├── shorts_mask              パンツマスク
    └── socks_mask               ソックスマスク
```

---

## 4. データモデル

### Team

```swift
struct Team: Identifiable, Codable {
    var id: UUID
    var name: String
    var emblemData: Data?           // エンブレム画像
    var flagEmoji: String?
    var jerseyPattern: JerseyPattern
    var jerseyPrimaryHex: String    // ユニフォームメインカラー
    var jerseySecondaryHex: String
    var jerseyPantsHex: String
    var jerseySockHex: String
    var players: [Player]
    var staff: [StaffMember]
    var lineupHistory: [Lineup]
    var createdAt: Date
}
```

### Player

```swift
struct Player: Identifiable, Codable {
    var id: UUID
    var name: String
    var number: Int                 // 背番号
    var photoData: Data?            // 表示用（切り抜き後）
    var originalPhotoData: Data?    // 元写真（再加工用）
    var backgroundRemoved: Bool     // 背景透過フラグ
    var preferredPositions: [Position]
    var customPositions: [String]   // 自由入力ポジション
    var isCaptain: Bool
    var isViceCaptain: Bool
    var note: String
    var todayStatus: PlayerStatus   // 出場可 / 欠席 / 怪我
}
```

### Lineup

```swift
struct Lineup: Identifiable, Codable {
    var id: UUID
    var date: Date
    var opponentName: String
    var gameFormat: GameFormat      // 5/7/8/11人制・その他
    var formation: Formation
    var assignments: [PositionAssignment]  // slotID → playerID
    var selectedStaffIDs: [UUID]
    var pitchStyle: PitchStyle      // stripes / checker / diamond / plain
    var note: String
}
```

---

## 5. データ永続化

| データ | 保存先 | 形式 |
|--------|--------|------|
| チーム・選手・スタッフ・スタメン履歴 | Documents/teams.json | JSON（Codable） |
| 背景写真 | Documents/background.jpg | JPEG |
| 背景透明度・サイズ | UserDefaults | Double |

- 外部サーバー送信：**なし**
- 広告・トラッキングSDK：**なし**
- ネットワーク通信：**なし**

---

## 6. 画面遷移

```
SplashView
    └── TeamListView（チーム一覧）
            ├── TeamSettingsView（チーム設定）
            └── PlayerListView（選手一覧）
                    ├── PlayerEditView（選手編集）
                    ├── StaffEditView（スタッフ編集）
                    ├── LineupSetupView（スタメン設定）
                    │       └── LineupEditorView（スタメン編集）
                    │               └── シェアシート
                    └── LineupHistoryView（履歴）
                            └── LineupEditorView（履歴から編集）
```

---

## 7. フォーメーション対応

| 試合形式 | 対応フォーメーション例 |
|----------|----------------------|
| 11人制 | 4-3-3 / 4-4-2 / 4-2-3-1 / 3-5-2 など |
| 8人制 | 3-3-1 / 2-4-1 など |
| 7人制 | 3-2-1 / 2-3-1 など |
| 5人制 | 2-1-1 / 1-2-1 など |
| カスタム | 任意人数・自由配置 |

---

## 8. プライバシー・権限

| 権限 | 用途 |
|------|------|
| NSCameraUsageDescription | 選手・スタッフの写真撮影 |
| NSPhotoLibraryUsageDescription | 選手・スタッフの写真登録・背景写真設定 |

---

## 9. ビルド設定

| 項目 | 値 |
|------|----|
| TARGETED_DEVICE_FAMILY | 1（iPhone のみ） |
| IPHONEOS_DEPLOYMENT_TARGET | 26.5（iOS 18相当） |
| SWIFT_VERSION | 5.0 |
| GENERATE_INFOPLIST_FILE | YES（自動生成） |
| 対応向き | Portrait のみ |

---

## 10. 更新履歴

| バージョン | 日付 | 内容 |
|-----------|------|------|
| 1.0 (build 3) | 2026-06-14 | 初回リリース申請。アイコン背番号表示・リセット確認ダイアログ・写真削除機能・シェアカード日付修正・スプラッシュ画像変更 |
