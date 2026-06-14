import Foundation

struct Team: Identifiable, Codable {
    var id: UUID = UUID()
    var name: String
    var players: [Player] = []
    var lineupHistory: [Lineup] = []
    var createdAt: Date = Date()
}
