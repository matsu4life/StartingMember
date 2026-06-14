import Foundation

struct Team: Identifiable, Codable {
    var id: UUID = UUID()
    var name: String
    var emblemData: Data? = nil
    var flagEmoji: String? = nil
    var jerseyPattern: JerseyPattern = .solid
    var jerseyPrimaryHex: String   = "2563EB"
    var jerseySecondaryHex: String = "FFFFFF"
    var jerseyPantsHex: String     = "1D4ED8"
    var jerseySockHex: String      = "FFFFFF"
    var players: [Player] = []
    var staff: [StaffMember] = []
    var lineupHistory: [Lineup] = []
    var createdAt: Date = Date()

    init(name: String) {
        self.name = name
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id = try c.decodeIfPresent(UUID.self, forKey: .id) ?? UUID()
        name = try c.decode(String.self, forKey: .name)
        emblemData = try c.decodeIfPresent(Data.self, forKey: .emblemData)
        flagEmoji = try c.decodeIfPresent(String.self, forKey: .flagEmoji)
        jerseyPattern      = try c.decodeIfPresent(JerseyPattern.self, forKey: .jerseyPattern) ?? .solid
        jerseyPrimaryHex   = try c.decodeIfPresent(String.self, forKey: .jerseyPrimaryHex)   ?? "2563EB"
        jerseySecondaryHex = try c.decodeIfPresent(String.self, forKey: .jerseySecondaryHex) ?? "FFFFFF"
        jerseyPantsHex     = try c.decodeIfPresent(String.self, forKey: .jerseyPantsHex)     ?? "1D4ED8"
        jerseySockHex      = try c.decodeIfPresent(String.self, forKey: .jerseySockHex)      ?? "FFFFFF"
        players = try c.decodeIfPresent([Player].self,       forKey: .players)       ?? []
        staff   = try c.decodeIfPresent([StaffMember].self, forKey: .staff)         ?? []
        lineupHistory = try c.decodeIfPresent([Lineup].self, forKey: .lineupHistory) ?? []
        createdAt = try c.decodeIfPresent(Date.self, forKey: .createdAt) ?? Date()
    }
}
