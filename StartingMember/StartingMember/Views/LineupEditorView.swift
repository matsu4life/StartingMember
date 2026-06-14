import SwiftUI

struct LineupEditorView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) var dismiss

    let team: Team
    let formation: Formation
    var customPlayerCount: Int = 0
    var recalledLineup: Lineup? = nil   // 履歴から呼び出した場合にセット

    // slot.id → player.id
    @State private var assignments: [UUID: UUID] = [:]
    @State private var opponentName = ""
    @State private var matchDate: Date = Date()
    @State private var note = ""
    @State private var selectedStaffIDs: Set<UUID> = []
    @State private var pitchStyle: PitchStyle = .stripes
    @State private var pickingSlotID: UUID?
    @State private var showStaffPicker = false
    @State private var showShareSheet = false
    @State private var shareImage: UIImage?
    @State private var showSavedToast = false
    @State private var showResetConfirm = false

    // 自由位置調整：slot.id → (xRatio, yRatio) の上書き
    @State private var positionOverrides: [UUID: CGPoint] = [:]   // pitch座標系（ピクセル）

    // ドラッグ中の状態
    @State private var draggingFromSlotID: UUID?
    @State private var draggingPlayerID: UUID?
    @State private var dragPoint: CGPoint = .zero
    @State private var pitchSize: CGSize = .zero

    private var allPlayers: [Player] { team.players.sorted { $0.number < $1.number } }

    private var benchPlayers: [Player] {
        let assignedIDs = Set(assignments.values)
        return allPlayers.filter { !assignedIDs.contains($0.id) }
    }

    private func assignedPlayer(for slot: FormationSlot) -> Player? {
        guard slot.id != draggingFromSlotID,
              let pid = assignments[slot.id] else { return nil }
        return allPlayers.first { $0.id == pid }
    }

    var body: some View {
        ZStack {
            Color(red: 0.06, green: 0.12, blue: 0.22).ignoresSafeArea()

            VStack(spacing: 0) {
                // ヘッダー：エンブレム・対戦相手・日付
                HStack(spacing: 10) {
                    TeamEmblemIcon(team: team, size: 32)

                    HStack(spacing: 4) {
                        Image(systemName: "sportscourt")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.5))
                        TextField("対戦相手（任意）", text: $opponentName)
                            .foregroundColor(.white)
                            .font(.subheadline)
                            .tint(.white)
                            .submitLabel(.done)
                    }

                    Spacer()

                    HStack(spacing: 4) {
                        Image(systemName: "calendar")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.5))
                        DatePicker("", selection: $matchDate, displayedComponents: .date)
                            .labelsHidden()
                            .colorScheme(.dark)
                            .scaleEffect(0.85)
                            .frame(width: 100)
                    }
                }
                .padding(.horizontal, 12)
                .padding(.top, 8)
                .padding(.bottom, 2)

                // スタッフ行（登録済みの場合のみ表示）
                if !team.staff.isEmpty {
                    Button {
                        showStaffPicker = true
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "person.bust")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.5))
                            if selectedStaffIDs.isEmpty {
                                Text("スタッフ・監督を選ぶ（任意）")
                                    .font(.caption)
                                    .foregroundColor(.white.opacity(0.4))
                            } else {
                                let selected = team.staff.filter { selectedStaffIDs.contains($0.id) }
                                Text(selected.map { "\($0.role.rawValue)：\($0.name)" }.joined(separator: "　"))
                                    .font(.caption)
                                    .foregroundColor(.white.opacity(0.75))
                                    .lineLimit(1)
                            }
                            Spacer()
                        }
                    }
                    .padding(.horizontal, 12)
                    .padding(.bottom, 4)
                }

                // ピッチ
                GeometryReader { geo in
                    ZStack {
                        PitchBackground(style: pitchStyle)

                        ForEach(formation.slots) { slot in
                            let baseX = geo.size.width * slot.xRatio
                            let baseY = geo.size.height * slot.yRatio
                            let isDraggingThis = draggingFromSlotID == slot.id
                            let pos = positionOverrides[slot.id] ?? CGPoint(x: baseX, y: baseY)

                            // ゴースト：ドラッグ中は元位置に薄い円を表示
                            if isDraggingThis {
                                Circle()
                                    .strokeBorder(Color.white.opacity(0.3), lineWidth: 1.5)
                                    .frame(width: 44, height: 44)
                                    .position(x: baseX, y: baseY)
                                    .allowsHitTesting(false)
                            }

                            // SlotView は常にレンダリング（ドラッグ中は透明化）
                            // → ビューを消すとジェスチャーが切れるため透明で維持する
                            SlotView(
                                slot: slot,
                                player: isDraggingThis ? nil : assignedPlayer(for: slot),
                                isDragTarget: false,
                                onTap: {
                                    guard draggingFromSlotID == nil else { return }
                                    pickingSlotID = slot.id
                                },
                                onRemove: {
                                    assignments.removeValue(forKey: slot.id)
                                    positionOverrides.removeValue(forKey: slot.id)
                                }
                            )
                            .position(isDraggingThis ? CGPoint(x: baseX, y: baseY) : pos)
                            .opacity(isDraggingThis ? 0 : 1)
                            .gesture(slotDragGesture(slot: slot))
                        }

                        // ドラッグ中の浮遊アイコン
                        if let pid = draggingPlayerID,
                           let player = allPlayers.first(where: { $0.id == pid }) {
                            PlayerAvatar(player: player, size: 52, showCaptainBadge: false)
                                .scaleEffect(1.12)
                                .shadow(color: .white.opacity(0.6), radius: 12)
                                .position(dragPoint)
                                .allowsHitTesting(false)
                                .animation(nil, value: dragPoint)
                        }
                    }
                    .coordinateSpace(name: "pitch")
                    .onAppear { pitchSize = geo.size }
                    .onChange(of: geo.size) { _, s in pitchSize = s }
                }
                .aspectRatio(0.65, contentMode: .fit)
                .padding(.horizontal, 4)

                benchBar

                HStack(spacing: 12) {
                    Button {
                        showResetConfirm = true
                    } label: {
                        Image(systemName: "arrow.counterclockwise")
                            .foregroundColor(.white.opacity(0.7))
                    }
                    .confirmationDialog("メンバーをリセットしますか？", isPresented: $showResetConfirm, titleVisibility: .visible) {
                        Button("リセット", role: .destructive) {
                            assignments = [:]
                            positionOverrides = [:]
                        }
                        Button("キャンセル", role: .cancel) {}
                    }

                    Menu {
                        ForEach(PitchStyle.allCases, id: \.self) { s in
                            Button {
                                withAnimation { pitchStyle = s }
                            } label: {
                                Label(s.rawValue,
                                      systemImage: pitchStyle == s ? "checkmark" : "")
                            }
                        }
                    } label: {
                        Image(systemName: "square.grid.2x2")
                            .foregroundColor(.white.opacity(0.7))
                    }

                    Spacer()

                    Button {
                        saveLineup()
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                            showSavedToast = true
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
                            withAnimation(.easeOut(duration: 0.3)) {
                                showSavedToast = false
                            }
                        }
                    } label: {
                        Label("保存", systemImage: "checkmark")
                            .font(.subheadline.bold())
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(Color.white.opacity(0.15))
                            .foregroundColor(.white)
                            .clipShape(Capsule())
                    }

                    Button {
                        captureAndShare()
                    } label: {
                        Label("共有", systemImage: "square.and.arrow.up")
                            .font(.subheadline.bold())
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(Color.accentColor)
                            .foregroundColor(.white)
                            .clipShape(Capsule())
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
            }
        }
        .overlay(alignment: .top) {
            if showSavedToast {
                HStack(spacing: 8) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                        .font(.system(size: 16))
                    Text("保存しました")
                        .font(.subheadline.bold())
                        .foregroundColor(.white)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background(.ultraThinMaterial, in: Capsule())
                .padding(.top, 12)
                .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
        .navigationTitle("スタメン")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .onAppear {
            guard let recalled = recalledLineup else { return }
            opponentName = recalled.opponentName
            matchDate = recalled.date
            note = recalled.note
            selectedStaffIDs = Set(recalled.selectedStaffIDs)
            pitchStyle = recalled.pitchStyle
            assignments = Dictionary(
                uniqueKeysWithValues: recalled.assignments.map { ($0.slotID, $0.playerID) }
            )
        }
        .sheet(isPresented: Binding(
            get: { pickingSlotID != nil },
            set: { if !$0 { pickingSlotID = nil } }
        )) {
            PlayerPickerView(
                players: benchPlayers,
                slotID: pickingSlotID!
            ) { slotID, playerID in
                assignments[slotID] = playerID
                pickingSlotID = nil
            } onCancel: {
                pickingSlotID = nil
            }
        }
        .sheet(isPresented: $showStaffPicker) {
            StaffPickerView(
                staff: team.staff,
                selected: $selectedStaffIDs
            )
        }
        .sheet(isPresented: $showShareSheet) {
            if let img = shareImage {
                ShareSheet(image: img)
            } else {
                ProgressView("画像を生成中...")
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                            showShareSheet = false
                        }
                    }
            }
        }
    }

    // MARK: - ドラッグジェスチャー（位置の自由調整）

    private func slotDragGesture(slot: FormationSlot) -> some Gesture {
        LongPressGesture(minimumDuration: 0.35)
            .sequenced(before: DragGesture(minimumDistance: 0, coordinateSpace: .named("pitch")))
            .onChanged { value in
                switch value {
                case .second(true, let drag):
                    // 長押し完了後（drag は nil = まだ指が動いていない / non-nil = 移動中）
                    if draggingFromSlotID == nil {
                        guard assignments[slot.id] != nil else { return }
                        draggingFromSlotID = slot.id
                        draggingPlayerID = assignments[slot.id]
                        dragPoint = positionOverrides[slot.id]
                            ?? CGPoint(x: pitchSize.width * slot.xRatio,
                                       y: pitchSize.height * slot.yRatio)
                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                    }
                    // 指が動いていれば位置を更新
                    if let drag, draggingFromSlotID == slot.id {
                        dragPoint = drag.location
                    }
                default:
                    break
                }
            }
            .onEnded { _ in
                guard let fromSlotID = draggingFromSlotID else { return }
                positionOverrides[fromSlotID] = dragPoint
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                draggingFromSlotID = nil
                draggingPlayerID = nil
                dragPoint = .zero
            }
    }

    private func dist(_ a: CGPoint, _ b: CGPoint) -> CGFloat {
        sqrt(pow(a.x - b.x, 2) + pow(a.y - b.y, 2))
    }

    // MARK: - ベンチ

    private var benchBar: some View {
        VStack(spacing: 4) {
            Text("ベンチ / 未配置  \(benchPlayers.count)人")
                .font(.caption)
                .foregroundColor(.white.opacity(0.5))

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    if benchPlayers.isEmpty {
                        Text("全員配置済み")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.4))
                            .padding(.horizontal, 12)
                    } else {
                        ForEach(benchPlayers) { player in
                            VStack(spacing: 3) {
                                PlayerAvatar(player: player, size: 44, showCaptainBadge: false)
                                Text(player.name)
                                    .font(.system(size: 11))
                                    .foregroundColor(.white.opacity(0.85))
                                    .lineLimit(1)
                            }
                            .frame(width: 56)
                        }
                    }
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
            }
        }
        .background(Color.white.opacity(0.06))
    }

    // MARK: - 保存・共有

    private func saveLineup() {
        let assignmentList = assignments.map {
            PositionAssignment(slotID: $0.key, playerID: $0.value)
        }
        var lineup = Lineup(
            opponentName: opponentName,
            gameFormat: formation.gameFormat,
            customPlayerCount: customPlayerCount,
            formation: formation,
            assignments: assignmentList,
            selectedStaffIDs: Array(selectedStaffIDs),
            pitchStyle: pitchStyle,
            note: note
        )
        lineup.date = matchDate
        // 履歴から呼び出した場合はIDを引き継ぎ（上書き保存）
        if let recalled = recalledLineup {
            lineup.id = recalled.id
        }
        store.saveLineup(lineup, to: team.id)
    }

    @MainActor
    private func captureAndShare() {
        showShareSheet = true
        Task { @MainActor in
            let renderer = ImageRenderer(content:
                LineupShareCard(
                    team: team,
                    formation: formation,
                    assignments: assignments,
                    positionOverrides: positionOverrides,
                    opponentName: opponentName,
                    allPlayers: allPlayers,
                    selectedStaffIDs: selectedStaffIDs,
                    pitchStyle: pitchStyle,
                    matchDate: matchDate
                )
                .frame(width: 390, height: 700)
            )
            renderer.scale = 3.0
            shareImage = renderer.uiImage
        }
    }
}

// MARK: - スロットビュー

struct SlotView: View {
    let slot: FormationSlot
    let player: Player?
    var isDragTarget: Bool = false
    let onTap: () -> Void
    let onRemove: () -> Void

    var body: some View {
        VStack(spacing: 2) {
            if let player {
                ZStack {
                    PlayerAvatar(player: player, size: 46, showCaptainBadge: true)
                        .overlay(
                            isDragTarget
                                ? Circle().strokeBorder(Color.yellow, lineWidth: 2)
                                : nil
                        )
                    // ×ボタン（右上）
                    VStack {
                        HStack {
                            Spacer()
                            Button(action: onRemove) {
                                Image(systemName: "xmark.circle.fill")
                                    .font(.system(size: 14))
                                    .foregroundColor(.white)
                                    .background(Color.black.opacity(0.5), in: Circle())
                            }
                            .offset(x: 6, y: -6)
                        }
                        Spacer()
                    }
                    .frame(width: 46, height: 46)
                }
                .transition(.scale(scale: 0.3).combined(with: .opacity))
                Text(player.name)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.white)
                    .lineLimit(1)
                    .shadow(radius: 1)
                    .transition(.opacity)
            } else {
                Button(action: onTap) {
                    ZStack {
                        Circle()
                            .strokeBorder(
                                isDragTarget ? Color.yellow : Color.white.opacity(0.5),
                                lineWidth: isDragTarget ? 2.5 : 1.5
                            )
                            .frame(width: 44, height: 44)
                            .background(Circle().fill(
                                isDragTarget
                                    ? Color.yellow.opacity(0.2)
                                    : Color.white.opacity(0.08)
                            ))
                        Text(slot.position.displayName)
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(isDragTarget ? .yellow : .white.opacity(0.9))
                    }
                }
                .buttonStyle(.plain)
                .transition(.opacity)
                Text(" ").font(.system(size: 11))
            }
        }
        .frame(width: 56)
        .animation(.spring(response: 0.3, dampingFraction: 0.55), value: player?.id)
    }
}

// MARK: - 選手選択シート

struct PlayerPickerView: View {
    let players: [Player]
    let slotID: UUID
    let onSelect: (UUID, UUID) -> Void
    let onCancel: () -> Void

    var body: some View {
        NavigationStack {
            Group {
                if players.isEmpty {
                    ContentUnavailableView(
                        "ベンチの選手がいません",
                        systemImage: "person.slash",
                        description: Text("全選手が配置済みです")
                    )
                } else {
                    List(players) { player in
                        Button {
                            onSelect(slotID, player.id)
                        } label: {
                            HStack(spacing: 12) {
                                PlayerAvatar(player: player, size: 40, showCaptainBadge: true)
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(player.name).foregroundColor(.primary)
                                    let pos = player.preferredPositions.map { $0.displayName } + player.customPositions
                                    if !pos.isEmpty {
                                        Text(pos.joined(separator: " "))
                                            .font(.caption).foregroundColor(.secondary)
                                    }
                                }
                                Spacer()
                                Text("#\(player.number)")
                                    .font(.headline).foregroundColor(.secondary)
                            }
                        }
                    }
                }
            }
            .navigationTitle("選手を選ぶ")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("キャンセル", action: onCancel)
                }
            }
        }
    }
}

// MARK: - 共有カード

struct LineupShareCard: View {
    let team: Team
    let formation: Formation
    let assignments: [UUID: UUID]
    let positionOverrides: [UUID: CGPoint]
    let opponentName: String
    let allPlayers: [Player]
    var selectedStaffIDs: Set<UUID> = []
    var pitchStyle: PitchStyle = .stripes
    var matchDate: Date = Date()

    private func player(for slot: FormationSlot) -> Player? {
        guard let pid = assignments[slot.id] else { return nil }
        return allPlayers.first { $0.id == pid }
    }

    @ViewBuilder
    private func shareTokenPosition(slot: FormationSlot, geo: GeometryProxy) -> some View {
        let pos: CGPoint = {
            if let ov = positionOverrides[slot.id] {
                let scaleX = geo.size.width / 390.0
                let scaleY = geo.size.height / (390.0 / 0.65)
                return CGPoint(x: ov.x * scaleX, y: ov.y * scaleY)
            }
            return CGPoint(x: geo.size.width * slot.xRatio, y: geo.size.height * slot.yRatio)
        }()
        SlotShareToken(slot: slot, player: player(for: slot))
            .position(pos)
    }

    var body: some View {
        ZStack {
            Color(red: 0.06, green: 0.12, blue: 0.22)
            VStack(spacing: 0) {
                VStack(spacing: 4) {
                    Text(team.name).font(.headline).foregroundColor(.white)
                    if !opponentName.isEmpty {
                        Text("vs \(opponentName)").font(.subheadline).foregroundColor(.white.opacity(0.7))
                    }
                    Text(formation.name + "  " + formattedDate())
                        .font(.caption).foregroundColor(.white.opacity(0.5))
                    let staffLine = team.staff
                        .filter { selectedStaffIDs.contains($0.id) }
                        .map { "\($0.role.rawValue)：\($0.name)" }
                        .joined(separator: "　")
                    if !staffLine.isEmpty {
                        Text(staffLine)
                            .font(.caption2).foregroundColor(.white.opacity(0.45))
                    }
                }
                .padding(.vertical, 10)

                GeometryReader { geo in
                    let slots = formation.slots
                    ZStack {
                        PitchBackground(style: pitchStyle)
                        ForEach(slots) { slot in
                            shareTokenPosition(slot: slot, geo: geo)
                        }
                    }
                }
                .aspectRatio(0.65, contentMode: .fit)
                .padding(.horizontal, 4)

                Text("StartingMember")
                    .font(.caption2).foregroundColor(.white.opacity(0.25))
                    .padding(.top, 6).padding(.bottom, 8)
            }
        }
    }

    private func formattedDate() -> String {
        let f = DateFormatter()
        f.locale = Locale(identifier: "ja_JP")
        f.dateFormat = "M/d"
        return f.string(from: matchDate)
    }
}

struct SlotShareToken: View {
    let slot: FormationSlot
    let player: Player?

    var body: some View {
        VStack(spacing: 2) {
            if let player {
                PlayerAvatar(player: player, size: 42, showCaptainBadge: true)
                Text(player.name)
                    .font(.system(size: 8, weight: .medium))
                    .foregroundColor(.white)
                    .lineLimit(1)
                    .shadow(radius: 1)
            } else {
                ZStack {
                    Circle()
                        .strokeBorder(Color.white.opacity(0.3), lineWidth: 1)
                        .frame(width: 42, height: 42)
                    Text(slot.position.displayName)
                        .font(.system(size: 9))
                        .foregroundColor(.white.opacity(0.6))
                }
                Text(" ").font(.system(size: 8))
            }
        }
        .frame(width: 52)
    }
}

// MARK: - スタッフ選択シート

struct StaffPickerView: View {
    let staff: [StaffMember]
    @Binding var selected: Set<UUID>
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack {
            List(staff) { member in
                Button {
                    if selected.contains(member.id) {
                        selected.remove(member.id)
                    } else {
                        selected.insert(member.id)
                    }
                } label: {
                    HStack(spacing: 12) {
                        ZStack {
                            Circle().fill(Color(.systemGray5)).frame(width: 40, height: 40)
                            if let data = member.photoData, let img = UIImage(data: data) {
                                Image(uiImage: img)
                                    .resizable().scaledToFill()
                                    .frame(width: 40, height: 40)
                                    .clipShape(Circle())
                            } else {
                                Image(systemName: member.role.icon)
                                    .font(.system(size: 16))
                                    .foregroundColor(.secondary)
                            }
                        }
                        VStack(alignment: .leading, spacing: 2) {
                            Text(member.name).foregroundColor(.primary)
                            Text(member.role.rawValue)
                                .font(.caption).foregroundColor(.secondary)
                        }
                        Spacer()
                        if selected.contains(member.id) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.accentColor)
                                .font(.system(size: 20))
                        }
                    }
                }
                .buttonStyle(.plain)
            }
            .navigationTitle("スタッフを選ぶ")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("完了") { dismiss() }
                }
                if !selected.isEmpty {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("クリア") { selected.removeAll() }
                    }
                }
            }
        }
    }
}

// MARK: - 共有シート

struct ShareSheet: UIViewControllerRepresentable {
    let image: UIImage
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: [image], applicationActivities: nil)
    }
    func updateUIViewController(_ vc: UIActivityViewController, context: Context) {}
}
