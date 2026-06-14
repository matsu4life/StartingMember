import SwiftUI
import PhotosUI

// MARK: - チーム設定画面

struct TeamSettingsView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) var dismiss

    @State var team: Team
    @State private var photoItem: PhotosPickerItem?
    @State private var showCamera     = false
    @State private var showFlagPicker = false
    @State private var imageToCrop: UIImage?

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {

                // ══ キャラクタープレビュー（スクロールに追従しない固定ヘッダー）══
                playerHeader

                Divider()

                // ══ 設定フォーム（スクロール可）══
                List {
                    // チーム名
                    Section("チーム名") {
                        TextField("チーム名", text: $team.name)
                    }

                    // エンブレム
                    Section("エンブレム・ロゴ") {
                        emblemRow
                    }

                    // ユニフォーム色
                    Section("ユニフォーム") {
                        colorRow("メインカラー", hex: $team.jerseyPrimaryHex)
                        if team.jerseyPattern != .solid {
                            colorRow("サブカラー", hex: $team.jerseySecondaryHex)
                        }
                        colorRow("パンツ",       hex: $team.jerseyPantsHex)
                    }

                    // 国旗
                    Section("国旗") {
                        flagRow
                    }
                }
                .listStyle(.insetGrouped)
            }
            .navigationTitle("チーム設定")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("キャンセル") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("保存") {
                        let t = team.name.trimmingCharacters(in: .whitespaces)
                        if !t.isEmpty { team.name = t }
                        store.updateTeam(team)
                        dismiss()
                    }
                    .disabled(team.name.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
            .onChange(of: photoItem) { _, item in
                Task {
                    guard let item,
                          let data = try? await item.loadTransferable(type: Data.self),
                          let img  = UIImage(data: data) else { return }
                    photoItem   = nil
                    imageToCrop = img
                }
            }
            .sheet(isPresented: $showCamera) {
                CameraView { img in showCamera = false; imageToCrop = img }
            }
            .sheet(item: Binding(
                get: { imageToCrop.map { CroppableImage(image: $0) } },
                set: { if $0 == nil { imageToCrop = nil } }
            )) { w in
                PhotoCropView(image: w.image, cropShape: .roundedRect(cornerRadius: 16)) { c in
                    team.emblemData = c.pngData()
                }
            }
            .sheet(isPresented: $showFlagPicker) {
                FlagPickerView(selected: $team.flagEmoji)
            }
        }
    }

    // ── キャラクタープレビューヘッダー ─────────────────────────────

    private var playerHeader: some View {
        VStack(spacing: 12) {

            // ユニフォームプレビュー（中央）
            HStack {
                Spacer()
                UniformView(
                    primaryColor:   Color(hex: team.jerseyPrimaryHex),
                    secondaryColor: Color(hex: team.jerseySecondaryHex),
                    pattern:        team.jerseyPattern,
                    pantsColor:     Color(hex: team.jerseyPantsHex),
                    size:           110
                )
                .animation(.spring(response: 0.35, dampingFraction: 0.75),
                           value: team.jerseyPrimaryHex)
                .animation(.spring(response: 0.35, dampingFraction: 0.75),
                           value: team.jerseySecondaryHex)
                .animation(.spring(response: 0.35, dampingFraction: 0.75),
                           value: team.jerseyPantsHex)
                .animation(.spring(response: 0.35, dampingFraction: 0.75),
                           value: team.jerseyPattern)
                Spacer()
            }
            .frame(height: 185)
            .padding(.top, 8)

            // 柄セレクター（全幅）
            Picker("柄", selection: $team.jerseyPattern) {
                ForEach(JerseyPattern.allCases, id: \.self) { p in
                    Text(p.rawValue).tag(p)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal, 16)
            .padding(.bottom, 10)
        }
        .background(
            Color(hex: team.jerseyPrimaryHex).opacity(0.12)
                .ignoresSafeArea()
                .animation(.easeInOut(duration: 0.4), value: team.jerseyPrimaryHex)
        )
    }

    // ── カラーピッカー行（横スクロール、全幅）──────────────────────

    private func colorRow(_ label: String, hex: Binding<String>) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            // ラベル + 現在色 + システムピッカー
            HStack(spacing: 8) {
                Circle()
                    .fill(Color(hex: hex.wrappedValue))
                    .frame(width: 22, height: 22)
                    .overlay(Circle().strokeBorder(.black.opacity(0.15), lineWidth: 1))
                Text(label)
                    .font(.subheadline).fontWeight(.medium)
                Spacer()
                ColorPicker("", selection: Binding(
                    get: { Color(hex: hex.wrappedValue) },
                    set: { hex.wrappedValue = $0.toHex() }
                ), supportsOpacity: false)
                .labelsHidden()
                .frame(width: 32, height: 32)
            }

            // 横スクロール カラースウォッチ（listの横パディングを打ち消して全幅）
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(jerseyColorPresets, id: \.hex) { preset in
                        let selected = hex.wrappedValue.uppercased() == preset.hex.uppercased()
                        Button { hex.wrappedValue = preset.hex } label: {
                            ZStack {
                                Circle()
                                    .fill(Color(hex: preset.hex))
                                    .frame(width: 38, height: 38)
                                if selected {
                                    Circle()
                                        .strokeBorder(Color.accentColor, lineWidth: 3)
                                        .frame(width: 38, height: 38)
                                    Image(systemName: "checkmark")
                                        .font(.system(size: 12, weight: .bold))
                                        .foregroundColor(
                                            Color(hex: preset.hex).luminance > 0.5 ? .black : .white
                                        )
                                } else {
                                    Circle()
                                        .strokeBorder(.black.opacity(0.12), lineWidth: 1)
                                        .frame(width: 38, height: 38)
                                }
                            }
                            .scaleEffect(selected ? 1.18 : 1.0)
                            .animation(.spring(response: 0.25, dampingFraction: 0.6), value: selected)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 4)
            }
            .listRowInsets(EdgeInsets())   // List の横パディングを除去して全幅
            .padding(.horizontal, -16)     // Section の内側パディングを打ち消す
        }
        .padding(.vertical, 4)
    }

    // ── エンブレム行 ────────────────────────────────────────────────

    private var emblemRow: some View {
        HStack(spacing: 16) {
            // サムネイル
            ZStack {
                if let data = team.emblemData, let img = UIImage(data: data) {
                    Image(uiImage: img)
                        .resizable().scaledToFill()
                        .frame(width: 64, height: 64)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                } else {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(.systemGray5)).frame(width: 64, height: 64)
                    Image(systemName: "shield.fill")
                        .font(.system(size: 28)).foregroundColor(.secondary)
                }
            }
            .onTapGesture {
                if let data = team.emblemData, let img = UIImage(data: data) {
                    imageToCrop = img
                }
            }

            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 8) {
                    PhotosPicker(selection: $photoItem, matching: .images) {
                        Label(team.emblemData == nil ? "ライブラリ" : "変更", systemImage: "photo")
                            .font(.caption)
                    }
                    .buttonStyle(.bordered)

                    Button { showCamera = true } label: {
                        Label("カメラ", systemImage: "camera").font(.caption)
                    }
                    .buttonStyle(.bordered)
                }

                if team.emblemData != nil {
                    Button(role: .destructive) { team.emblemData = nil } label: {
                        Label("削除", systemImage: "trash").font(.caption)
                    }
                    .buttonStyle(.bordered)
                }
            }

            Spacer()
        }
        .padding(.vertical, 4)
    }

    // ── 国旗行 ──────────────────────────────────────────────────────

    private var flagRow: some View {
        Group {
            Button { showFlagPicker = true } label: {
                HStack {
                    if let flag = team.flagEmoji {
                        Text(flag).font(.system(size: 30))
                        Text("変更する").foregroundColor(.accentColor)
                    } else {
                        Image(systemName: "flag").foregroundColor(.secondary)
                        Text("国旗を選ぶ").foregroundColor(.accentColor)
                    }
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.caption).foregroundColor(.secondary)
                }
            }
            if team.flagEmoji != nil {
                Button(role: .destructive) { team.flagEmoji = nil } label: {
                    Label("国旗を外す", systemImage: "xmark")
                }
            }
        }
    }
}

// MARK: - Color 輝度（チェックマーク色判定用）

private extension Color {
    var luminance: Double {
        let ui = UIColor(self)
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        ui.getRed(&r, green: &g, blue: &b, alpha: &a)
        return 0.299*Double(r) + 0.587*Double(g) + 0.114*Double(b)
    }
}

// MARK: - 国旗ピッカー

private let flagList: [(emoji: String, name: String)] = [
    ("🇯🇵","日本"),("🇧🇷","ブラジル"),("🇩🇪","ドイツ"),("🇫🇷","フランス"),
    ("🇪🇸","スペイン"),("🇦🇷","アルゼンチン"),("🇵🇹","ポルトガル"),("🇮🇹","イタリア"),
    ("🏴󠁧󠁢󠁥󠁮󠁧󠁿","イングランド"),("🇺🇸","アメリカ"),("🇰🇷","韓国"),("🇨🇳","中国"),
    ("🇳🇱","オランダ"),("🇧🇪","ベルギー"),("🇲🇽","メキシコ"),("🇺🇾","ウルグアイ"),
    ("🇨🇭","スイス"),("🇦🇺","オーストラリア"),("🇸🇳","セネガル"),("🇲🇦","モロッコ"),
    ("🇬🇭","ガーナ"),("🇨🇮","コートジボワール"),("🇳🇬","ナイジェリア"),("🇨🇦","カナダ"),
    ("🇨🇴","コロンビア"),("🇨🇱","チリ"),("🇵🇪","ペルー"),("🇹🇳","チュニジア"),
    ("🇪🇬","エジプト"),("🇸🇦","サウジアラビア"),("🇮🇷","イラン"),("🇶🇦","カタール"),
    ("🇹🇷","トルコ"),("🇺🇦","ウクライナ"),("🇵🇱","ポーランド"),("🇷🇸","セルビア"),
    ("🇭🇷","クロアチア"),("🇩🇰","デンマーク"),("🇸🇪","スウェーデン"),("🇳🇴","ノルウェー"),
    ("🇬🇧","イギリス"),("🇮🇪","アイルランド"),("🏴󠁧󠁢󠁳󠁣󠁴󠁿","スコットランド"),("🇵🇭","フィリピン"),
    ("🇹🇭","タイ"),("🇻🇳","ベトナム"),("🇮🇩","インドネシア"),("🇲🇾","マレーシア"),
]

struct FlagPickerView: View {
    @Binding var selected: String?
    @Environment(\.dismiss) var dismiss
    @State private var search = ""

    private var filtered: [(emoji: String, name: String)] {
        search.isEmpty ? flagList : flagList.filter { $0.name.contains(search) }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 72), spacing: 12)], spacing: 16) {
                    ForEach(filtered, id: \.emoji) { flag in
                        Button {
                            selected = flag.emoji
                            dismiss()
                        } label: {
                            VStack(spacing: 4) {
                                Text(flag.emoji).font(.system(size: 40))
                                    .frame(width: 60, height: 52)
                                    .background(selected == flag.emoji
                                        ? Color.accentColor.opacity(0.2)
                                        : Color(.systemGray6))
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                                    .overlay(RoundedRectangle(cornerRadius: 10)
                                        .strokeBorder(selected == flag.emoji
                                            ? Color.accentColor : .clear, lineWidth: 2))
                                Text(flag.name).font(.system(size: 10))
                                    .foregroundColor(.secondary).lineLimit(1)
                            }
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding()
            }
            .searchable(text: $search, prompt: "国名で検索")
            .navigationTitle("国旗を選ぶ")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("キャンセル") { dismiss() }
                }
            }
        }
    }
}
