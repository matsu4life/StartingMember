import Foundation

struct Player: Identifiable, Codable {
    var id: UUID = UUID()
    var name: String
    var number: Int
    var photoData: Data?           // 背景除去済みの顔写真
    var iconStyle: IconStyle = .photo
    var preferredPositions: [Position] = []
    var isCaptain: Bool = false
    var isViceCaptain: Bool = false
    var note: String = ""

    // 当日の状態（試合ごとにリセット）
    var todayStatus: PlayerStatus = .available
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
