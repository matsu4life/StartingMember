import Foundation

struct StaffMember: Identifiable, Codable {
    var id: UUID = UUID()
    var name: String
    var role: StaffRole = .coach
    var photoData: Data? = nil
    var originalPhotoData: Data? = nil
    var backgroundRemoved: Bool = false
    var note: String = ""

    init(name: String, role: StaffRole = .coach) {
        self.name = name
        self.role = role
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id                = try c.decodeIfPresent(UUID.self,      forKey: .id)                ?? UUID()
        name              = try c.decode(String.self,             forKey: .name)
        role              = try c.decodeIfPresent(StaffRole.self, forKey: .role)              ?? .coach
        photoData         = try c.decodeIfPresent(Data.self,      forKey: .photoData)
        originalPhotoData = try c.decodeIfPresent(Data.self,      forKey: .originalPhotoData)
        backgroundRemoved = try c.decodeIfPresent(Bool.self,      forKey: .backgroundRemoved) ?? false
        note              = try c.decodeIfPresent(String.self,    forKey: .note)              ?? ""
    }
}

enum StaffRole: String, Codable, CaseIterable {
    case headCoach = "監督"
    case coach     = "コーチ"
    case trainer   = "トレーナー"
    case other     = "その他"

    var icon: String {
        switch self {
        case .headCoach: return "person.bust"
        case .coach:     return "figure.mind.and.body"
        case .trainer:   return "cross.case"
        case .other:     return "person"
        }
    }
}
