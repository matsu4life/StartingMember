import SwiftUI

struct LineupSetupView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) var dismiss
    let teamID: UUID

    @State private var format: GameFormat = .eleven
    @State private var selectedFormation: Formation?
    @State private var customCount: Int = 6
    @State private var goToEditor = false

    private var presets: [Formation] { FormationPresets.presets(for: format) }

    private var resolvedFormation: Formation {
        if format == .custom {
            return FormationPresets.autoFormation(playerCount: customCount)
        }
        return selectedFormation ?? presets[0]
    }

    var body: some View {
        NavigationStack {
            Form {
                // 人数（形式）選択
                Section("人数") {
                    ForEach(GameFormat.allCases, id: \.self) { f in
                        HStack {
                            Text(f.rawValue)
                            Spacer()
                            if format == f {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.accentColor)
                            }
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            format = f
                            selectedFormation = nil
                        }
                    }
                }

                // その他：人数入力
                if format == .custom {
                    Section("出場人数") {
                        Stepper("\(customCount)人", value: $customCount, in: 2...20)
                        Text("フォーメーションは人数に合わせて自動配置されます")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }

                // フォーメーション選択（プリセットがある場合のみ）
                if format != .custom && !presets.isEmpty {
                    Section("フォーメーション") {
                        ForEach(presets) { formation in
                            HStack {
                                Text(formation.name)
                                Spacer()
                                if selectedFormation?.id == formation.id {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.accentColor)
                                }
                            }
                            .contentShape(Rectangle())
                            .onTapGesture { selectedFormation = formation }
                        }
                    }
                }
            }
            .navigationTitle("スタメンを組む")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 13, weight: .semibold))
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("次へ") { goToEditor = true }
                }
            }
            .navigationDestination(isPresented: $goToEditor) {
                LineupEditorView(
                    team: store.teams.first { $0.id == teamID }!,
                    formation: resolvedFormation,
                    customPlayerCount: format == .custom ? customCount : 0
                )
            }
            .onAppear {
                if selectedFormation == nil {
                    selectedFormation = presets.first
                }
            }
            .onChange(of: format) { _, _ in
                selectedFormation = presets.first
            }
        }
    }
}
