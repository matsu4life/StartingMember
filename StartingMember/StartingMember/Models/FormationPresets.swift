import Foundation

struct FormationPresets {

    // 11人制
    static let eleven: [Formation] = [
        make("4-3-3", .eleven, slots: [
            (.gk,  0.50, 0.92),
            (.lb,  0.15, 0.75), (.cb, 0.38, 0.75), (.cb, 0.62, 0.75), (.rb, 0.85, 0.75),
            (.cmf, 0.25, 0.55), (.cmf, 0.50, 0.50), (.cmf, 0.75, 0.55),
            (.lw,  0.15, 0.28), (.cf, 0.50, 0.20), (.rw, 0.85, 0.28)
        ]),
        make("4-4-2", .eleven, slots: [
            (.gk,  0.50, 0.92),
            (.lb,  0.15, 0.75), (.cb, 0.38, 0.75), (.cb, 0.62, 0.75), (.rb, 0.85, 0.75),
            (.lmf, 0.15, 0.55), (.cmf, 0.38, 0.52), (.cmf, 0.62, 0.52), (.rmf, 0.85, 0.55),
            (.cf,  0.35, 0.22), (.cf, 0.65, 0.22)
        ]),
        make("3-4-2-1", .eleven, slots: [
            (.gk,  0.50, 0.92),
            (.cb,  0.25, 0.75), (.cb, 0.50, 0.78), (.cb, 0.75, 0.75),
            (.lmf, 0.12, 0.57), (.cmf, 0.38, 0.54), (.cmf, 0.62, 0.54), (.rmf, 0.88, 0.57),
            (.ss,  0.35, 0.35), (.ss, 0.65, 0.35),
            (.cf,  0.50, 0.18)
        ]),
        make("4-2-3-1", .eleven, slots: [
            (.gk,  0.50, 0.92),
            (.lb,  0.15, 0.75), (.cb, 0.38, 0.75), (.cb, 0.62, 0.75), (.rb, 0.85, 0.75),
            (.dmf, 0.38, 0.58), (.dmf, 0.62, 0.58),
            (.lw,  0.15, 0.40), (.amf, 0.50, 0.38), (.rw, 0.85, 0.40),
            (.cf,  0.50, 0.20)
        ]),
        make("3-5-2", .eleven, slots: [
            (.gk,  0.50, 0.92),
            (.cb,  0.25, 0.75), (.cb, 0.50, 0.78), (.cb, 0.75, 0.75),
            (.lmf, 0.10, 0.52), (.cmf, 0.32, 0.54), (.cmf, 0.50, 0.50), (.cmf, 0.68, 0.54), (.rmf, 0.90, 0.52),
            (.cf,  0.35, 0.22), (.cf, 0.65, 0.22)
        ]),
    ]

    // 8人制
    static let eight: [Formation] = [
        make("2-3-2", .eight, slots: [
            (.gk,  0.50, 0.92),
            (.cb,  0.30, 0.74), (.cb, 0.70, 0.74),
            (.lmf, 0.18, 0.52), (.cmf, 0.50, 0.48), (.rmf, 0.82, 0.52),
            (.cf,  0.35, 0.22), (.cf, 0.65, 0.22)
        ]),
        make("3-3-1", .eight, slots: [
            (.gk,  0.50, 0.92),
            (.cb,  0.22, 0.74), (.cb, 0.50, 0.77), (.cb, 0.78, 0.74),
            (.lmf, 0.22, 0.50), (.cmf, 0.50, 0.46), (.rmf, 0.78, 0.50),
            (.cf,  0.50, 0.20)
        ]),
        make("1-3-2-1", .eight, slots: [
            (.gk,  0.50, 0.92),
            (.cb,  0.50, 0.76),
            (.lmf, 0.20, 0.58), (.cmf, 0.50, 0.55), (.rmf, 0.80, 0.58),
            (.ss,  0.35, 0.36), (.ss, 0.65, 0.36),
            (.cf,  0.50, 0.20)
        ]),
        make("2-4-1", .eight, slots: [
            (.gk,  0.50, 0.92),
            (.cb,  0.30, 0.75), (.cb, 0.70, 0.75),
            (.lmf, 0.15, 0.52), (.cmf, 0.38, 0.50), (.cmf, 0.62, 0.50), (.rmf, 0.85, 0.52),
            (.cf,  0.50, 0.20)
        ]),
    ]

    // 7人制
    static let seven: [Formation] = [
        make("2-3-1", .seven, slots: [
            (.gk,  0.50, 0.92),
            (.cb,  0.28, 0.74), (.cb, 0.72, 0.74),
            (.lmf, 0.18, 0.50), (.cmf, 0.50, 0.46), (.rmf, 0.82, 0.50),
            (.cf,  0.50, 0.20)
        ]),
        make("3-2-1", .seven, slots: [
            (.gk,  0.50, 0.92),
            (.cb,  0.22, 0.74), (.cb, 0.50, 0.77), (.cb, 0.78, 0.74),
            (.cmf, 0.33, 0.50), (.cmf, 0.67, 0.50),
            (.cf,  0.50, 0.20)
        ]),
        make("2-2-2", .seven, slots: [
            (.gk,  0.50, 0.92),
            (.cb,  0.28, 0.74), (.cb, 0.72, 0.74),
            (.cmf, 0.28, 0.52), (.cmf, 0.72, 0.52),
            (.cf,  0.33, 0.22), (.cf, 0.67, 0.22)
        ]),
    ]

    // 5人制（フットサル）
    static let five: [Formation] = [
        make("1-2-1", .five, slots: [
            (.gk,  0.50, 0.90),
            (.cb,  0.28, 0.68), (.cb, 0.72, 0.68),
            (.amf, 0.50, 0.42),
            (.cf,  0.50, 0.18)
        ]),
        make("2-1-1", .five, slots: [
            (.gk,  0.50, 0.90),
            (.cb,  0.28, 0.68), (.cb, 0.72, 0.68),
            (.cmf, 0.50, 0.46),
            (.cf,  0.50, 0.20)
        ]),
        make("1-1-2", .five, slots: [
            (.gk,  0.50, 0.90),
            (.cb,  0.50, 0.68),
            (.cmf, 0.50, 0.46),
            (.cf,  0.30, 0.20), (.cf, 0.70, 0.20)
        ]),
    ]

    static func presets(for format: GameFormat) -> [Formation] {
        switch format {
        case .five:   return five
        case .seven:  return seven
        case .eight:  return eight
        case .eleven: return eleven
        case .custom: return []
        }
    }

    // 任意の人数に対して自動レイアウトのフォーメーションを生成
    static func autoFormation(playerCount: Int) -> Formation {
        let count = max(1, playerCount)
        var slots: [(Position, Double, Double)] = []

        // GK（1人の場合はGKのみ）
        slots.append((.gk, 0.50, 0.90))

        let outfield = count - 1
        guard outfield > 0 else {
            return makeCustom(name: "\(count)人", slots: slots)
        }

        // 残りをいくつの行に分けるか
        let rowCount: Int
        switch outfield {
        case 1...2: rowCount = 1
        case 3...5: rowCount = 2
        case 6...9: rowCount = 3
        default:    rowCount = 4
        }

        // 各行のy位置（上(攻撃)から下(守備)へ）
        let yPositions: [Double] = [0.20, 0.42, 0.62, 0.76]

        // 均等に行へ配分
        var remaining = outfield
        var rowSizes: [Int] = []
        for i in 0..<rowCount {
            let rowsLeft = rowCount - i
            let inThisRow = (remaining + rowsLeft - 1) / rowsLeft
            rowSizes.append(inThisRow)
            remaining -= inThisRow
        }

        for (rowIdx, rowSize) in rowSizes.enumerated() {
            let y = rowIdx < yPositions.count ? yPositions[rowIdx] : 0.80
            for i in 0..<rowSize {
                let x = (Double(i) + 1.0) / Double(rowSize + 1)
                slots.append((.cmf, x, y))
            }
        }

        return makeCustom(name: "\(count)人", slots: slots)
    }

    // MARK: - ヘルパー

    private static func make(_ name: String, _ format: GameFormat,
                              slots: [(Position, Double, Double)]) -> Formation {
        Formation(name: name, gameFormat: format,
                  slots: slots.map { FormationSlot(position: $0.0, xRatio: $0.1, yRatio: $0.2) })
    }

    private static func makeCustom(name: String, slots: [(Position, Double, Double)]) -> Formation {
        Formation(name: name, gameFormat: .custom,
                  slots: slots.map { FormationSlot(position: $0.0, xRatio: $0.1, yRatio: $0.2) })
    }
}
