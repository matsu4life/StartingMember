import Foundation
import SwiftUI
import Combine

// アプリ全体のデータを管理するクラス
// 端末内（UserDefaults）にのみ保存。外部送信なし。
@MainActor
class AppStore: ObservableObject {

    @Published var teams: [Team] = []
    @Published var selectedTeamID: UUID?
    @Published var backgroundImageData: Data? = nil
    @Published var backgroundOpacity: Double = 1.0   // 画像自体の透明度 (0=透明 / 1=不透明)
    @Published var backgroundScale: Double  = 1.0   // 画像の拡大率

    var selectedTeam: Team? {
        teams.first { $0.id == selectedTeamID }
    }

    // 端末内のファイルに保存（写真を含むため UserDefaults は使わない）
    private var saveURL: URL {
        let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return dir.appendingPathComponent("teams.json")
    }

    private var bgURL: URL {
        let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return dir.appendingPathComponent("background.jpg")
    }

    init() {
        load()
        loadBackground()
        if teams.isEmpty {
            // 初回起動時にサンプルチームを作成
            let sample = Team(name: "マイチーム")
            teams.append(sample)
            selectedTeamID = sample.id
            save()
        } else {
            selectedTeamID = teams.first?.id
        }
    }

    // MARK: - 背景写真

    func setBackground(_ image: UIImage) {
        let data = image.jpegData(compressionQuality: 0.85)
        backgroundImageData = data
        try? data?.write(to: bgURL, options: .atomic)
    }

    func clearBackground() {
        backgroundImageData = nil
        try? FileManager.default.removeItem(at: bgURL)
    }

    func saveBackgroundSettings() {
        UserDefaults.standard.set(backgroundOpacity, forKey: "bgOpacity")
        UserDefaults.standard.set(backgroundScale,   forKey: "bgScale")
    }

    private func loadBackground() {
        backgroundImageData = try? Data(contentsOf: bgURL)
        backgroundOpacity = UserDefaults.standard.object(forKey: "bgOpacity") as? Double ?? 1.0
        backgroundScale   = UserDefaults.standard.object(forKey: "bgScale")   as? Double ?? 1.0
    }

    // MARK: - チーム操作

    func addTeam(name: String) {
        let team = Team(name: name)
        teams.append(team)
        selectedTeamID = team.id
        save()
    }

    func deleteTeam(id: UUID) {
        teams.removeAll { $0.id == id }
        selectedTeamID = teams.first?.id
        save()
    }

    func updateTeam(_ team: Team) {
        if let index = teams.firstIndex(where: { $0.id == team.id }) {
            teams[index] = team
            save()
        }
    }

    // MARK: - 選手操作

    func addPlayer(_ player: Player, to teamID: UUID) {
        guard let index = teams.firstIndex(where: { $0.id == teamID }) else { return }
        teams[index].players.append(player)
        save()
    }

    func updatePlayer(_ player: Player, in teamID: UUID) {
        guard let tIndex = teams.firstIndex(where: { $0.id == teamID }),
              let pIndex = teams[tIndex].players.firstIndex(where: { $0.id == player.id }) else { return }
        teams[tIndex].players[pIndex] = player
        save()
    }

    func deletePlayer(id: UUID, from teamID: UUID) {
        guard let tIndex = teams.firstIndex(where: { $0.id == teamID }) else { return }
        teams[tIndex].players.removeAll { $0.id == id }
        save()
    }

    // MARK: - スタッフ操作

    func addStaff(_ staff: StaffMember, to teamID: UUID) {
        guard let index = teams.firstIndex(where: { $0.id == teamID }) else { return }
        teams[index].staff.append(staff)
        save()
    }

    func updateStaff(_ staff: StaffMember, in teamID: UUID) {
        guard let tIndex = teams.firstIndex(where: { $0.id == teamID }),
              let sIndex = teams[tIndex].staff.firstIndex(where: { $0.id == staff.id }) else { return }
        teams[tIndex].staff[sIndex] = staff
        save()
    }

    func deleteStaff(id: UUID, from teamID: UUID) {
        guard let tIndex = teams.firstIndex(where: { $0.id == teamID }) else { return }
        teams[tIndex].staff.removeAll { $0.id == id }
        save()
    }

    // MARK: - スタメン履歴

    func saveLineup(_ lineup: Lineup, to teamID: UUID) {
        guard let index = teams.firstIndex(where: { $0.id == teamID }) else { return }
        if let lIndex = teams[index].lineupHistory.firstIndex(where: { $0.id == lineup.id }) {
            teams[index].lineupHistory[lIndex] = lineup
        } else {
            teams[index].lineupHistory.insert(lineup, at: 0)
        }
        save()
    }

    func deleteLineup(id: UUID, from teamID: UUID) {
        guard let index = teams.firstIndex(where: { $0.id == teamID }) else { return }
        teams[index].lineupHistory.removeAll { $0.id == id }
        save()
    }

    // MARK: - 永続化（端末ローカルのみ）

    private func save() {
        guard let data = try? JSONEncoder().encode(teams) else { return }
        try? data.write(to: saveURL, options: .atomic)
    }

    private func load() {
        guard let data = try? Data(contentsOf: saveURL),
              let decoded = try? JSONDecoder().decode([Team].self, from: data) else { return }
        teams = decoded
    }
}
