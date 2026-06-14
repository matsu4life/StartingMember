import SwiftUI
import PhotosUI

struct StaffEditView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) var dismiss

    let teamID: UUID
    @State var staff: StaffMember
    let isNew: Bool

    @State private var photoItem: PhotosPickerItem?
    @State private var isProcessing = false
    @State private var imageToCrop: UIImage?

    var body: some View {
        NavigationStack {
            Form {
                // 写真セクション（PlayerEditView と同構造）
                Section("写真") {
                    HStack {
                        Spacer()
                        VStack(spacing: 12) {
                            if staff.originalPhotoData != nil {
                                Button {
                                    openCrop()
                                } label: {
                                    staffAvatar(size: 100)
                                }
                                .buttonStyle(.plain)
                                Text("タップで位置を調整")
                                    .font(.caption2).foregroundColor(.secondary)
                            } else {
                                PhotosPicker(selection: $photoItem, matching: .images) {
                                    staffAvatar(size: 100)
                                }
                            }

                            PhotosPicker(selection: $photoItem, matching: .images) {
                                Label(staff.originalPhotoData == nil ? "写真を選ぶ" : "写真を変える",
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

                    if staff.originalPhotoData != nil {
                        Toggle("背景を透過する（人物だけ残す）", isOn: Binding(
                            get: { staff.backgroundRemoved },
                            set: { newVal in
                                staff.backgroundRemoved = newVal
                                openCrop()
                            }
                        ))
                    }
                }

                // 基本情報
                Section("基本情報") {
                    TextField("名前", text: $staff.name)
                    Picker("役職", selection: $staff.role) {
                        ForEach(StaffRole.allCases, id: \.self) { role in
                            Text(role.rawValue).tag(role)
                        }
                    }
                }

                // メモ
                Section("メモ（任意）") {
                    TextField("例：水曜参加不可", text: $staff.note, axis: .vertical)
                        .lineLimit(3, reservesSpace: false)
                }

                if !isNew {
                    Section {
                        Button("このスタッフを削除", role: .destructive) {
                            store.deleteStaff(id: staff.id, from: teamID)
                            dismiss()
                        }
                    }
                }
            }
            .scrollDismissesKeyboard(.interactively)
            .navigationTitle(isNew ? "スタッフを追加" : "スタッフを編集")
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
                        .disabled(staff.name.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
            .onChange(of: photoItem) { _, item in
                Task { await loadPhoto(item) }
            }
            .sheet(item: Binding(
                get: { imageToCrop.map { CroppableImage(image: $0) } },
                set: { if $0 == nil { imageToCrop = nil } }
            )) { wrapper in
                PhotoCropView(image: wrapper.image) { cropped in
                    if let png = cropped.pngData() {
                        staff.photoData = png
                    }
                }
            }
        }
    }

    // MARK: - アバター

    @ViewBuilder
    private func staffAvatar(size: CGFloat) -> some View {
        ZStack {
            Circle()
                .fill(Color(.systemGray5))
                .frame(width: size, height: size)
            if let data = staff.photoData, let img = UIImage(data: data) {
                Image(uiImage: img)
                    .resizable().scaledToFill()
                    .frame(width: size, height: size)
                    .clipShape(Circle())
            } else {
                Image(systemName: staff.role.icon)
                    .font(.system(size: size * 0.38))
                    .foregroundColor(.secondary)
            }
        }
    }

    // MARK: - 写真処理

    private func loadPhoto(_ item: PhotosPickerItem?) async {
        guard let item,
              let data = try? await item.loadTransferable(type: Data.self),
              UIImage(data: data) != nil else { return }
        staff.originalPhotoData = data
        staff.backgroundRemoved = false
        openCrop()
    }

    private func openCrop() {
        guard let data = staff.originalPhotoData,
              let original = UIImage(data: data) else { return }
        Task {
            isProcessing = true
            defer { isProcessing = false }
            let source: UIImage
            if staff.backgroundRemoved {
                source = BackgroundRemover.removeBackground(from: original) ?? original
            } else {
                source = original
            }
            if let png = source.pngData() { staff.photoData = png }
            imageToCrop = source
        }
    }

    private func hideKeyboard() {
        UIApplication.shared.sendAction(
            #selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }

    // MARK: - 保存

    private func save() {
        var s = staff
        s.name = s.name.trimmingCharacters(in: .whitespaces)
        if isNew {
            store.addStaff(s, to: teamID)
        } else {
            store.updateStaff(s, in: teamID)
        }
        dismiss()
    }
}
