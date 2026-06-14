import SwiftUI
import PhotosUI

struct TeamListView: View {
    @EnvironmentObject var store: AppStore

    @State private var showingNewTeam = false
    @State private var newTeamName = ""
    @State private var settingsTarget: Team?
    @State private var renameTarget: Team?
    @State private var renameText = ""
    @State private var bgPhotoItem: PhotosPickerItem?
    @State private var showBgPicker = false
    @State private var showBgSettings = false

    private var hasBG: Bool { store.backgroundImageData != nil }

    var body: some View {
        NavigationStack {
            ZStack {
                // 背景写真
                if let data = store.backgroundImageData, let img = UIImage(data: data) {
                    BackgroundImageView(image: img,
                                       scale: store.backgroundScale,
                                       opacity: store.backgroundOpacity)
                }

                List {
                    if store.teams.isEmpty {
                        ContentUnavailableView {
                            Label("チームがありません", systemImage: "sportscourt")
                        } description: {
                            Text("右上の＋からチームを作りましょう")
                        } actions: {
                            Button {
                                newTeamName = ""
                                showingNewTeam = true
                            } label: {
                                Text("チームを作る")
                            }
                            .buttonStyle(.borderedProminent)
                        }
                        .listRowBackground(Color.clear)
                    } else {
                        ForEach(store.teams) { team in
                            ZStack(alignment: .trailing) {
                                NavigationLink {
                                    PlayerListView(teamID: team.id)
                                } label: {
                                    HStack(spacing: 0) {
                                        RoundedRectangle(cornerRadius: 2)
                                            .fill(Color(hex: team.jerseyPrimaryHex))
                                            .frame(width: 4)
                                            .padding(.vertical, 6)

                                        ZStack {
                                            RoundedRectangle(cornerRadius: 10)
                                                .fill(Color(hex: team.jerseyPrimaryHex).opacity(hasBG ? 0.35 : 0.15))
                                                .frame(width: 44, height: 44)
                                            TeamEmblemIcon(team: team, size: 36)
                                        }
                                        .padding(.horizontal, 10)

                                        VStack(alignment: .leading, spacing: 2) {
                                            Text(team.name)
                                                .font(.body)
                                                .foregroundColor(.primary)
                                            let staffCount = team.staff.count
                                            let detail = "\(team.players.count)人登録" +
                                                (staffCount > 0 ? "　スタッフ\(staffCount)人" : "")
                                            Text(detail)
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                        }
                                        Spacer()
                                        Color.clear.frame(width: 36)
                                    }
                                }

                                Button {
                                    settingsTarget = team
                                } label: {
                                    Image(systemName: "gearshape")
                                        .font(.system(size: 18))
                                        .foregroundColor(.secondary)
                                        .frame(width: 44, height: 44)
                                }
                                .buttonStyle(.plain)
                            }
                            .listRowBackground(
                                hasBG
                                    ? AnyView(RoundedRectangle(cornerRadius: 12)
                                        .fill(.ultraThinMaterial)
                                        .padding(.vertical, 2))
                                    : AnyView(Color.clear)
                            )
                            .swipeActions(edge: .trailing) {
                                Button(role: .destructive) {
                                    store.deleteTeam(id: team.id)
                                } label: {
                                    Label("削除", systemImage: "trash")
                                }
                            }
                        }
                    }
                }
                .listStyle(.insetGrouped)
                .scrollContentBackground(hasBG ? .hidden : .visible)
            }
            .navigationTitle("チーム一覧")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        newTeamName = ""
                        showingNewTeam = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
                ToolbarItem(placement: .topBarLeading) {
                    bgMenu
                }
            }
            .alert("新しいチーム", isPresented: $showingNewTeam) {
                TextField("チーム名", text: $newTeamName)
                Button("作成") {
                    let name = newTeamName.trimmingCharacters(in: .whitespaces)
                    if !name.isEmpty { store.addTeam(name: name) }
                }
                Button("キャンセル", role: .cancel) {}
            }
            .sheet(item: $settingsTarget) { team in
                TeamSettingsView(team: team)
                    .environmentObject(store)
            }
            .sheet(isPresented: $showBgSettings) {
                BackgroundSettingsSheet()
                    .environmentObject(store)
            }
            .alert("チーム名を変更", isPresented: Binding(
                get: { renameTarget != nil },
                set: { if !$0 { renameTarget = nil } }
            )) {
                TextField("チーム名", text: $renameText)
                Button("変更") {
                    if var team = renameTarget {
                        team.name = renameText.trimmingCharacters(in: .whitespaces)
                        if !team.name.isEmpty { store.updateTeam(team) }
                    }
                    renameTarget = nil
                }
                Button("キャンセル", role: .cancel) { renameTarget = nil }
            }
            .onChange(of: bgPhotoItem) { _, item in
                Task {
                    guard let item,
                          let data = try? await item.loadTransferable(type: Data.self),
                          let img  = UIImage(data: data) else { return }
                    bgPhotoItem = nil
                    store.setBackground(img)
                }
            }
        }
    }

    @ViewBuilder
    private var bgMenu: some View {
        Menu {
            Button {
                showBgPicker = true
            } label: {
                Label(hasBG ? "背景写真を変更" : "背景写真を設定", systemImage: "photo")
            }
            if hasBG {
                Button {
                    showBgSettings = true
                } label: {
                    Label("背景を調整", systemImage: "slider.horizontal.3")
                }
                Button(role: .destructive) {
                    store.clearBackground()
                } label: {
                    Label("背景をデフォルトに戻す", systemImage: "xmark.circle")
                }
            }
        } label: {
            Image(systemName: hasBG ? "photo.fill" : "photo")
                .font(.system(size: 16))
        }
        .photosPicker(isPresented: $showBgPicker, selection: $bgPhotoItem, matching: .images)
    }
}

// MARK: - 背景調整シート

struct BackgroundSettingsSheet: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                // プレビュー背景
                if let data = store.backgroundImageData, let img = UIImage(data: data) {
                    BackgroundImageView(image: img,
                                       scale: store.backgroundScale,
                                       opacity: store.backgroundOpacity)
                } else {
                    Color(.systemGroupedBackground).ignoresSafeArea()
                }

                VStack {
                    // プレビュー用サンプルカード
                    RoundedRectangle(cornerRadius: 12)
                        .fill(.ultraThinMaterial)
                        .frame(height: 64)
                        .overlay(
                            HStack(spacing: 12) {
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.blue.opacity(0.4))
                                    .frame(width: 44, height: 44)
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("チーム名").font(.body)
                                    Text("11人登録").font(.caption).foregroundColor(.secondary)
                                }
                                Spacer()
                            }
                            .padding(.horizontal, 16)
                        )
                        .padding(.horizontal, 20)
                        .padding(.top, 40)

                    Spacer()

                    // スライダーパネル
                    VStack(spacing: 20) {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Image(systemName: "circle.lefthalf.filled")
                                Text("画像の透明度")
                                    .font(.subheadline)
                                Spacer()
                                Text("\(Int(store.backgroundOpacity * 100))%")
                                    .font(.caption).monospacedDigit()
                                    .foregroundColor(.secondary)
                            }
                            Slider(value: $store.backgroundOpacity, in: 0.0...1.0)
                                .onChange(of: store.backgroundOpacity) { _, _ in
                                    store.saveBackgroundSettings()
                                }
                        }

                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Image(systemName: "arrow.up.left.and.arrow.down.right")
                                Text("画像の大きさ")
                                    .font(.subheadline)
                                Spacer()
                                Text(String(format: "%.0f%%", store.backgroundScale * 100))
                                    .font(.caption).monospacedDigit()
                                    .foregroundColor(.secondary)
                            }
                            Slider(value: $store.backgroundScale, in: 1.0...2.0)
                                .onChange(of: store.backgroundScale) { _, _ in
                                    store.saveBackgroundSettings()
                                }
                        }
                    }
                    .padding(24)
                    .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 20))
                    .padding(.horizontal, 16)
                    .padding(.bottom, 32)
                }
            }
            .navigationTitle("背景の調整")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("完了") { dismiss() }
                }
            }
        }
    }
}
