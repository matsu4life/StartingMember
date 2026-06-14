import SwiftUI
import PhotosUI

struct PlayerEditView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) var dismiss

    let teamID: UUID
    @State var player: Player
    let isNew: Bool

    @State private var photoItem: PhotosPickerItem?
    @State private var isProcessing = false
    @State private var imageToCrop: UIImage?
    @State private var newCustomPosition = ""

    var body: some View {
        NavigationStack {
            Form {
                // 写真セクション
                Section("写真") {
                    HStack {
                        Spacer()
                        VStack(spacing: 12) {
                            if player.originalPhotoData != nil {
                                // 写真あり：アイコンをタップで位置調整へ
                                Button {
                                    openCrop()
                                } label: {
                                    PlayerAvatar(player: player, size: 100, showCaptainBadge: true)
                                }
                                .buttonStyle(.plain)
                                Text("タップで位置を調整")
                                    .font(.caption2).foregroundColor(.secondary)
                            } else {
                                // 写真なし：空アイコンをタップで写真選択へ
                                PhotosPicker(selection: $photoItem, matching: .images) {
                                    PlayerAvatar(player: player, size: 100, showCaptainBadge: true)
                                }
                            }

                            PhotosPicker(selection: $photoItem, matching: .images) {
                                Label(player.originalPhotoData == nil ? "写真を選ぶ" : "写真を変える",
                                      systemImage: "photo")
                            }

                            if isProcessing {
                                HStack(spacing: 6) {
                                    ProgressView()
                                    Text("処理中…").font(.caption).foregroundColor(.secondary)
                                }
                            }
                        }
                        Spacer()
                    }
                    .padding(.vertical, 8)

                    if player.originalPhotoData != nil {
                        Toggle("背景を透過する（人物だけ残す）", isOn: Binding(
                            get: { player.backgroundRemoved },
                            set: { newValue in
                                player.backgroundRemoved = newValue
                                openCrop()
                            }
                        ))
                    }
                }

                // 基本情報
                Section("基本情報") {
                    TextField("名前", text: $player.name)
                    HStack {
                        Text("背番号")
                        Spacer()
                        TextField("番号", value: $player.number, format: .number)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 80)
                    }
                }

                // 役割
                Section("役割") {
                    Toggle("キャプテン", isOn: $player.isCaptain)
                    Toggle("副キャプテン", isOn: $player.isViceCaptain)
                }

                // ポジション適性（任意）
                Section {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 56), spacing: 8)], spacing: 8) {
                        ForEach(Position.allCases, id: \.self) { pos in
                            let selected = player.preferredPositions.contains(pos)
                            Button {
                                togglePosition(pos)
                            } label: {
                                Text(pos.displayName)
                                    .font(.subheadline)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 8)
                                    .background(selected ? Color.accentColor : Color(.systemGray5))
                                    .foregroundColor(selected ? .white : .primary)
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.vertical, 4)

                    // 自由入力（カタカナ可）
                    if !player.customPositions.isEmpty {
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 80), spacing: 8)], spacing: 8) {
                            ForEach(player.customPositions, id: \.self) { text in
                                Button {
                                    player.customPositions.removeAll { $0 == text }
                                } label: {
                                    HStack(spacing: 4) {
                                        Text(text).font(.subheadline)
                                        Image(systemName: "xmark.circle.fill").font(.caption2)
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 8)
                                    .background(Color.accentColor.opacity(0.15))
                                    .foregroundColor(.accentColor)
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }

                    HStack {
                        TextField("自由に入力（例：ボランチ、キーパー）", text: $newCustomPosition)
                        Button("追加") { addCustomPosition() }
                            .disabled(newCustomPosition.trimmingCharacters(in: .whitespaces).isEmpty)
                    }
                } header: {
                    Text("得意ポジション（任意）")
                } footer: {
                    Text("ルールが分からなくてもOK。下の欄に「まんなか」「うしろ」など自由に書けます。")
                }

                // メモ
                Section("メモ（任意）") {
                    TextField("例：足が速い、両足使える など", text: $player.note, axis: .vertical)
                }

                if !isNew {
                    Section {
                        Button("この選手を削除", role: .destructive) {
                            store.deletePlayer(id: player.id, from: teamID)
                            dismiss()
                        }
                    }
                }
            }
            .scrollDismissesKeyboard(.interactively)
            .navigationTitle(isNew ? "選手を追加" : "選手を編集")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("完了") { hideKeyboard() }
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("キャンセル") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("保存") { save() }
                        .disabled(player.name.isEmpty)
                }
            }
            .onChange(of: photoItem) { _, newItem in
                Task { await loadPhoto(newItem) }
            }
            .sheet(item: Binding(
                get: { imageToCrop.map { CroppableImage(image: $0) } },
                set: { if $0 == nil { imageToCrop = nil } }
            )) { wrapper in
                PhotoCropView(image: wrapper.image) { cropped in
                    if let png = cropped.pngData() {
                        player.photoData = png
                    }
                }
            }
        }
    }

    private func addCustomPosition() {
        let text = newCustomPosition.trimmingCharacters(in: .whitespaces)
        guard !text.isEmpty, !player.customPositions.contains(text) else { return }
        player.customPositions.append(text)
        newCustomPosition = ""
    }

    private func hideKeyboard() {
        UIApplication.shared.sendAction(
            #selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }

    private func togglePosition(_ pos: Position) {
        if let idx = player.preferredPositions.firstIndex(of: pos) {
            player.preferredPositions.remove(at: idx)
        } else {
            player.preferredPositions.append(pos)
        }
    }

    // 新しい写真を取り込む。元写真を保持し、初期は背景そのまま。
    private func loadPhoto(_ item: PhotosPickerItem?) async {
        guard let item,
              let data = try? await item.loadTransferable(type: Data.self),
              UIImage(data: data) != nil else { return }

        player.originalPhotoData = data
        player.backgroundRemoved = false
        openCrop()
    }

    // 元写真から「透過する/しない」を反映した画像を作り、位置調整画面を開く。
    // いつ呼んでも元写真から作り直すので、透過のオン/オフを後から自由に切り替えられる。
    private func openCrop() {
        guard let data = player.originalPhotoData,
              let original = UIImage(data: data) else { return }

        Task {
            isProcessing = true
            defer { isProcessing = false }

            let source: UIImage
            if player.backgroundRemoved {
                source = BackgroundRemover.removeBackground(from: original) ?? original
            } else {
                source = original
            }

            // 調整しなくてもアイコンが出るよう仮保存してから調整画面へ
            if let png = source.pngData() { player.photoData = png }
            imageToCrop = source
        }
    }

    private func save() {
        if isNew {
            store.addPlayer(player, to: teamID)
        } else {
            store.updatePlayer(player, in: teamID)
        }
        dismiss()
    }
}

// sheet(item:) 用に UIImage を識別可能にするラッパー
struct CroppableImage: Identifiable {
    let id = UUID()
    let image: UIImage
}
