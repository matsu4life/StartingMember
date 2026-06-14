import SwiftUI

struct PlayerListView: View {
    @EnvironmentObject var store: AppStore
    let teamID: UUID

    @State private var editingPlayer: Player?
    @State private var editingStaff: StaffMember?
    @State private var showingNew = false
    @State private var showingNewStaff = false
    @State private var showingLineup = false
    @State private var showingHistory = false

    private var team: Team? {
        store.teams.first { $0.id == teamID }
    }

    var body: some View {
        ZStack {
            // 背景写真（TeamListView と共有）
            if let data = store.backgroundImageData, let img = UIImage(data: data) {
                BackgroundImageView(image: img,
                                    scale: store.backgroundScale,
                                    opacity: store.backgroundOpacity)
            }

            List {
                if let team, !team.players.isEmpty {
                    Section("登録選手 \(team.players.count)人") {
                        ForEach(team.players.sorted { $0.number < $1.number }) { player in
                            Button {
                                editingPlayer = player
                            } label: {
                                PlayerRow(player: player)
                            }
                            .foregroundColor(.primary)
                            .swipeActions(edge: .trailing) {
                                Button(role: .destructive) {
                                    store.deletePlayer(id: player.id, from: teamID)
                                } label: {
                                    Label("削除", systemImage: "trash")
                                }
                            }
                        }
                    }
                } else {
                    ContentUnavailableView(
                        "選手がいません",
                        systemImage: "person.3",
                        description: Text("右上の＋から選手を登録しましょう")
                    )
                }

                if let team {
                    Section("スタッフ") {
                        if team.staff.isEmpty {
                            Text("スタッフ未登録")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .padding(.vertical, 2)
                        } else {
                            ForEach(team.staff) { member in
                                Button {
                                    editingStaff = member
                                } label: {
                                    StaffRow(member: member)
                                }
                                .foregroundColor(.primary)
                                .swipeActions(edge: .trailing) {
                                    Button(role: .destructive) {
                                        store.deleteStaff(id: member.id, from: teamID)
                                    } label: {
                                        Label("削除", systemImage: "trash")
                                    }
                                }
                            }
                        }
                        Button {
                            showingNewStaff = true
                        } label: {
                            Label("スタッフを追加", systemImage: "plus")
                                .font(.subheadline)
                        }
                    }
                }
            }
            .listStyle(.insetGrouped)
            .scrollContentBackground(store.backgroundImageData != nil ? .hidden : .visible)
        }
        .navigationTitle(team?.name ?? "選手")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Menu {
                    Button {
                        showingNew = true
                    } label: {
                        Label("選手を追加", systemImage: "person.badge.plus")
                    }
                    Button {
                        showingNewStaff = true
                    } label: {
                        Label("スタッフを追加", systemImage: "person.bust")
                    }
                } label: {
                    Image(systemName: "plus")
                }
            }
            ToolbarItem(placement: .bottomBar) {
                Button {
                    showingHistory = true
                } label: {
                    Label("履歴", systemImage: "clock.arrow.circlepath")
                }
            }
            ToolbarItem(placement: .bottomBar) {
                Spacer()
            }
            ToolbarItem(placement: .bottomBar) {
                Button {
                    showingLineup = true
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "sportscourt.fill")
                        Text("スタメンを組む")
                            .fontWeight(.semibold)
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(Color.accentColor)
                    .foregroundColor(.white)
                    .clipShape(Capsule())
                }
                .buttonStyle(.plain)
            }
        }
        .sheet(isPresented: $showingNew) {
            PlayerEditView(
                teamID: teamID,
                player: Player(name: "", number: nextNumber()),
                isNew: true
            )
        }
        .sheet(item: $editingPlayer) { player in
            PlayerEditView(teamID: teamID, player: player, isNew: false)
        }
        .sheet(isPresented: $showingNewStaff) {
            StaffEditView(teamID: teamID, staff: StaffMember(name: ""), isNew: true)
                .environmentObject(store)
        }
        .sheet(item: $editingStaff) { member in
            StaffEditView(teamID: teamID, staff: member, isNew: false)
                .environmentObject(store)
        }
        .sheet(isPresented: $showingLineup) {
            LineupSetupView(teamID: teamID)
                .environmentObject(store)
        }
        .sheet(isPresented: $showingHistory) {
            HistorySheetWrapper(teamID: teamID)
                .environmentObject(store)
        }
    }

    private func nextNumber() -> Int {
        let used = Set(team?.players.map { $0.number } ?? [])
        for n in 1...99 where !used.contains(n) { return n }
        return 0
    }
}

struct HistorySheetWrapper: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) var dismiss
    let teamID: UUID

    var body: some View {
        NavigationStack {
            if let team = store.teams.first(where: { $0.id == teamID }) {
                LineupHistoryView(team: team)
                    .environmentObject(store)
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button {
                                dismiss()
                            } label: {
                                Image(systemName: "xmark")
                                    .font(.system(size: 13, weight: .semibold))
                            }
                        }
                    }
            }
        }
    }
}

struct StaffRow: View {
    let member: StaffMember

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(Color(.systemGray5))
                    .frame(width: 44, height: 44)
                if let data = member.photoData, let img = UIImage(data: data) {
                    Image(uiImage: img)
                        .resizable().scaledToFill()
                        .frame(width: 44, height: 44)
                        .clipShape(Circle())
                } else {
                    Image(systemName: member.role.icon)
                        .font(.system(size: 18))
                        .foregroundColor(.secondary)
                }
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(member.name).font(.body)
                Text(member.role.rawValue)
                    .font(.caption).foregroundColor(.secondary)
            }

            Spacer()
        }
        .padding(.vertical, 4)
    }
}

struct PlayerRow: View {
    let player: Player

    var body: some View {
        HStack(spacing: 12) {
            PlayerAvatar(player: player, size: 44, showCaptainBadge: true)

            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 6) {
                    Text(player.name).font(.body)
                    if player.isCaptain {
                        Text("C").font(.caption2).bold()
                            .foregroundColor(Color(red: 0.6, green: 0.45, blue: 0))
                    }
                    if player.isViceCaptain {
                        Text("副").font(.caption2).foregroundColor(.secondary)
                    }
                }
                let positions = player.preferredPositions.map { $0.displayName } + player.customPositions
                if !positions.isEmpty {
                    Text(positions.joined(separator: " "))
                        .font(.caption).foregroundColor(.secondary)
                }
            }

            Spacer()

            Text("#\(player.number)")
                .font(.headline).foregroundColor(.secondary)
        }
        .padding(.vertical, 4)
    }
}
