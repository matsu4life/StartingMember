import SwiftUI

struct LineupHistoryView: View {
    @EnvironmentObject var store: AppStore
    let team: Team

    @State private var recallLineup: Lineup?
    @State private var showEditor = false
    @State private var deleteTarget: Lineup?

    private var history: [Lineup] {
        team.lineupHistory.sorted { $0.date > $1.date }
    }

    var body: some View {
        Group {
            if history.isEmpty {
                ContentUnavailableView(
                    "履歴がありません",
                    systemImage: "clock.arrow.circlepath",
                    description: Text("スタメンを保存すると履歴に残ります")
                )
            } else {
                List {
                    ForEach(history) { lineup in
                        Button {
                            recallLineup = lineup
                            showEditor = true
                        } label: {
                            LineupHistoryRow(lineup: lineup)
                        }
                        .foregroundColor(.primary)
                        .swipeActions(edge: .trailing) {
                            Button(role: .destructive) {
                                store.deleteLineup(id: lineup.id, from: team.id)
                            } label: {
                                Label("削除", systemImage: "trash")
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle("スタメン履歴")
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(isPresented: $showEditor) {
            if let lineup = recallLineup {
                LineupEditorView(
                    team: team,
                    formation: lineup.formation,
                    customPlayerCount: lineup.customPlayerCount,
                    recalledLineup: lineup
                )
            }
        }
    }
}

struct LineupHistoryRow: View {
    let lineup: Lineup

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(formattedDate(lineup.date))
                    .font(.subheadline.bold())
                Spacer()
                Text(lineup.gameFormat.rawValue + "  " + lineup.formation.name)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(Color(.systemGray5))
                    .clipShape(Capsule())
            }
            if !lineup.opponentName.isEmpty {
                Text("vs \(lineup.opponentName)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            Text("配置済み \(lineup.assignments.count)人")
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 4)
    }

    private func formattedDate(_ date: Date) -> String {
        let f = DateFormatter()
        f.locale = Locale(identifier: "ja_JP")
        f.dateFormat = "yyyy年M月d日（E）"
        return f.string(from: date)
    }
}
