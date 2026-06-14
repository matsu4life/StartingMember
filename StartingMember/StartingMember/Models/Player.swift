import Foundation

struct Player: Identifiable, Codable {
    var id: UUID = UUID()
    var name: String
    var number: Int
    var photoData: Data?           // アイコン表示用（切り抜き・透過の最終結果）
    var originalPhotoData: Data?   // 取り込んだ元写真（背景あり）。後から再加工するため保持
    var backgroundRemoved: Bool = false  // 背景を透過しているか
    var iconStyle: IconStyle = .photo
    var preferredPositions: [Position] = []   // プリセットから選んだポジション
    var customPositions: [String] = []        // 自由入力（カタカナ可）
    var isCaptain: Bool = false
    var isViceCaptain: Bool = false
    var note: String = ""

    // 当日の状態（試合ごとにリセット）
    var todayStatus: PlayerStatus = .available

    init(name: String, number: Int) {
        self.name = name
        self.number = number
    }

    // 古い保存データ（新しい項目がない）でも読み込めるようにする
    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id = try c.decodeIfPresent(UUID.self, forKey: .id) ?? UUID()
        name = try c.decode(String.self, forKey: .name)
        number = try c.decode(Int.self, forKey: .number)
        photoData = try c.decodeIfPresent(Data.self, forKey: .photoData)
        originalPhotoData = try c.decodeIfPresent(Data.self, forKey: .originalPhotoData)
        backgroundRemoved = try c.decodeIfPresent(Bool.self, forKey: .backgroundRemoved) ?? false
        iconStyle = try c.decodeIfPresent(IconStyle.self, forKey: .iconStyle) ?? .photo
        preferredPositions = try c.decodeIfPresent([Position].self, forKey: .preferredPositions) ?? []
        customPositions = try c.decodeIfPresent([String].self, forKey: .customPositions) ?? []
        isCaptain = try c.decodeIfPresent(Bool.self, forKey: .isCaptain) ?? false
        isViceCaptain = try c.decodeIfPresent(Bool.self, forKey: .isViceCaptain) ?? false
        note = try c.decodeIfPresent(String.self, forKey: .note) ?? ""
        todayStatus = try c.decodeIfPresent(PlayerStatus.self, forKey: .todayStatus) ?? .available
    }
}

enum IconStyle: String, Codable, CaseIterable {
    case photo    = "写真"
    case anime    = "アニメ風"
    case pixel    = "16ビット風"
    case game     = "ゲーム風"
    case manga    = "漫画風"
}

enum PlayerStatus: String, Codable {
    case available = "出場可"
    case absent    = "欠席"
    case injured   = "怪我"
}

enum Position: String, Codable, CaseIterable {
    case gk  = "GK"
    case cb  = "CB"
    case lb  = "LB"
    case rb  = "RB"
    case dmf = "DMF"
    case cmf = "CMF"
    case amf = "AMF"
    case lmf = "LMF"
    case rmf = "RMF"
    case lw  = "LW"
    case rw  = "RW"
    case cf  = "CF"
    case ss  = "SS"

    var displayName: String { rawValue }
}
