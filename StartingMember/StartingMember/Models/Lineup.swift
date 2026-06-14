import Foundation

struct Lineup: Identifiable, Codable {
    var id: UUID = UUID()
    var date: Date = Date()
    var opponentName: String = ""
    var gameFormat: GameFormat = .eleven
    var customPlayerCount: Int = 0      // gameFormat == .custom の時だけ使用
    var formation: Formation
    var assignments: [PositionAssignment] = []
    var benchPlayerIDs: [UUID] = []
    var selectedStaffIDs: [UUID] = []
    var pitchStyle: PitchStyle = .stripes
    var note: String = ""

    init(opponentName: String = "",
         gameFormat: GameFormat = .eleven,
         customPlayerCount: Int = 0,
         formation: Formation,
         assignments: [PositionAssignment] = [],
         selectedStaffIDs: [UUID] = [],
         pitchStyle: PitchStyle = .stripes,
         note: String = "") {
        self.opponentName = opponentName
        self.gameFormat = gameFormat
        self.customPlayerCount = customPlayerCount
        self.formation = formation
        self.assignments = assignments
        self.selectedStaffIDs = selectedStaffIDs
        self.pitchStyle = pitchStyle
        self.note = note
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id = try c.decodeIfPresent(UUID.self, forKey: .id) ?? UUID()
        date = try c.decodeIfPresent(Date.self, forKey: .date) ?? Date()
        opponentName = try c.decodeIfPresent(String.self, forKey: .opponentName) ?? ""
        gameFormat = try c.decodeIfPresent(GameFormat.self, forKey: .gameFormat) ?? .eleven
        customPlayerCount = try c.decodeIfPresent(Int.self, forKey: .customPlayerCount) ?? 0
        formation = try c.decode(Formation.self, forKey: .formation)
        assignments = try c.decodeIfPresent([PositionAssignment].self, forKey: .assignments) ?? []
        benchPlayerIDs    = try c.decodeIfPresent([UUID].self,       forKey: .benchPlayerIDs)   ?? []
        selectedStaffIDs  = try c.decodeIfPresent([UUID].self,       forKey: .selectedStaffIDs) ?? []
        pitchStyle        = try c.decodeIfPresent(PitchStyle.self,   forKey: .pitchStyle)       ?? .stripes
        note              = try c.decodeIfPresent(String.self,        forKey: .note)             ?? ""
    }
}

struct PositionAssignment: Identifiable, Codable {
    var id: UUID = UUID()
    var slotID: UUID
    var playerID: UUID
}

enum GameFormat: String, Codable, CaseIterable {
    case five   = "5人制（フットサル）"
    case seven  = "7人制"
    case eight  = "8人制"
    case eleven = "11人制"
    case custom = "その他"

    var defaultPlayerCount: Int {
        switch self {
        case .five:   return 5
        case .seven:  return 7
        case .eight:  return 8
        case .eleven: return 11
        case .custom: return 6
        }
    }

    var hasPresets: Bool { self != .custom }
}

struct Formation: Identifiable, Codable {
    var id: UUID = UUID()
    var name: String
    var gameFormat: GameFormat
    var slots: [FormationSlot]
}

struct FormationSlot: Identifiable, Codable {
    var id: UUID = UUID()
    var position: Position
    var xRatio: Double
    var yRatio: Double
}
