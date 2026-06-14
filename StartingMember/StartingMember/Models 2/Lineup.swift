import Foundation

struct Lineup: Identifiable, Codable {
    var id: UUID = UUID()
    var date: Date = Date()
    var opponentName: String = ""
    var gameFormat: GameFormat = .eleven
    var formation: Formation
    var assignments: [PositionAssignment] = []  // ポジション → 選手
    var benchPlayerIDs: [UUID] = []
    var note: String = ""
}

// ポジションスロットに選手を紐付ける
struct PositionAssignment: Identifiable, Codable {
    var id: UUID = UUID()
    var slotID: UUID          // FormationSlotのID
    var playerID: UUID
}

enum GameFormat: String, Codable, CaseIterable {
    case eight  = "8人制"
    case eleven = "11人制"

    var playerCount: Int {
        switch self {
        case .eight:  return 8
        case .eleven: return 11
        }
    }
}

struct Formation: Identifiable, Codable {
    var id: UUID = UUID()
    var name: String          // 例: "4-3-3"
    var gameFormat: GameFormat
    var slots: [FormationSlot]
}

struct FormationSlot: Identifiable, Codable {
    var id: UUID = UUID()
    var position: Position
    var xRatio: Double        // ピッチ横幅に対する比率 0.0〜1.0
    var yRatio: Double        // ピッチ縦幅に対する比率 0.0〜1.0
}
