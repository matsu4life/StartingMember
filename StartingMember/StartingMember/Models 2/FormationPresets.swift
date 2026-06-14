import Foundation

struct FormationPresets {

    // 11人制フォーメーション
    static let eleven: [Formation] = [
        make11("4-3-3", slots: [
            (.gk,  0.50, 0.92),
            (.lb,  0.15, 0.75), (.cb, 0.38, 0.75), (.cb, 0.62, 0.75), (.rb, 0.85, 0.75),
            (.cmf, 0.25, 0.55), (.cmf, 0.50, 0.50), (.cmf, 0.75, 0.55),
            (.lw,  0.15, 0.28), (.cf, 0.50, 0.20), (.rw, 0.85, 0.28)
        ]),
        make11("4-4-2", slots: [
            (.gk,  0.50, 0.92),
            (.lb,  0.15, 0.75), (.cb, 0.38, 0.75), (.cb, 0.62, 0.75), (.rb, 0.85, 0.75),
            (.lmf, 0.15, 0.55), (.cmf, 0.38, 0.52), (.cmf, 0.62, 0.52), (.rmf, 0.85, 0.55),
            (.cf,  0.35, 0.22), (.cf, 0.65, 0.22)
        ]),
        make11("3-4-2-1", slots: [
            (.gk,  0.50, 0.92),
            (.cb,  0.25, 0.75), (.cb, 0.50, 0.78), (.cb, 0.75, 0.75),
            (.lmf, 0.12, 0.57), (.cmf, 0.38, 0.54), (.cmf, 0.62, 0.54), (.rmf, 0.88, 0.57),
            (.ss,  0.35, 0.35), (.ss, 0.65, 0.35),
            (.cf,  0.50, 0.18)
        ]),
        make11("4-2-3-1", slots: [
            (.gk,  0.50, 0.92),
            (.lb,  0.15, 0.75), (.cb, 0.38, 0.75), (.cb, 0.62, 0.75), (.rb, 0.85, 0.75),
            (.dmf, 0.38, 0.58), (.dmf, 0.62, 0.58),
            (.lw,  0.15, 0.40), (.amf, 0.50, 0.38), (.rw, 0.85, 0.40),
            (.cf,  0.50, 0.20)
        ]),
        make11("3-5-2", slots: [
            (.gk,  0.50, 0.92),
            (.cb,  0.25, 0.75), (.cb, 0.50, 0.78), (.cb, 0.75, 0.75),
            (.lmf, 0.10, 0.52), (.cmf, 0.32, 0.54), (.cmf, 0.50, 0.50), (.cmf, 0.68, 0.54), (.rmf, 0.90, 0.52),
            (.cf,  0.35, 0.22), (.cf, 0.65, 0.22)
        ]),
    ]

    // 8人制フォーメーション
    static let eight: [Formation] = [
        make8("2-3-2", slots: [
            (.gk,  0.50, 0.92),
            (.cb,  0.30, 0.74), (.cb, 0.70, 0.74),
            (.lmf, 0.18, 0.52), (.cmf, 0.50, 0.48), (.rmf, 0.82, 0.52),
            (.cf,  0.35, 0.22), (.cf, 0.65, 0.22)
        ]),
        make8("3-3-1", slots: [
            (.gk,  0.50, 0.92),
            (.cb,  0.22, 0.74), (.cb, 0.50, 0.77), (.cb, 0.78, 0.74),
            (.lmf, 0.22, 0.50), (.cmf, 0.50, 0.46), (.rmf, 0.78, 0.50),
            (.cf,  0.50, 0.20)
        ]),
        make8("1-3-2-1", slots: [
            (.gk,  0.50, 0.92),
            (.cb,  0.50, 0.76),
            (.lmf, 0.20, 0.58), (.cmf, 0.50, 0.55), (.rmf, 0.80, 0.58),
            (.ss,  0.35, 0.36), (.ss, 0.65, 0.36),
            (.cf,  0.50, 0.20)
        ]),
        make8("2-4-1", slots: [
            (.gk,  0.50, 0.92),
            (.cb,  0.30, 0.75), (.cb, 0.70, 0.75),
            (.lmf, 0.15, 0.52), (.cmf, 0.38, 0.50), (.cmf, 0.62, 0.50), (.rmf, 0.85, 0.52),
            (.cf,  0.50, 0.20)
        ]),
    ]

    static func presets(for format: GameFormat) -> [Formation] {
        format == .eleven ? eleven : eight
    }

    private static func make11(_ name: String, slots: [(Position, Double, Double)]) -> Formation {
        Formation(name: name, gameFormat: .eleven, slots: slots.map {
            FormationSlot(position: $0.0, xRatio: $0.1, yRatio: $0.2)
        })
    }

    private static func make8(_ name: String, slots: [(Position, Double, Double)]) -> Formation {
        Formation(name: name, gameFormat: .eight, slots: slots.map {
            FormationSlot(position: $0.0, xRatio: $0.1, yRatio: $0.2)
        })
    }
}
