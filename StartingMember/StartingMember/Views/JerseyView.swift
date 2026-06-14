import SwiftUI

// MARK: - パターン種別

enum JerseyPattern: String, Codable, CaseIterable {
    case solid   = "単色"
    case stripes = "縦ストライプ"
    case border  = "横ボーダー"
}

// MARK: - ユニフォーム全体（シャツ＋パンツ）

struct UniformView: View {
    let primaryColor: Color
    let secondaryColor: Color
    let pattern: JerseyPattern
    let pantsColor: Color
    var size: CGFloat = 130

    var body: some View {
        VStack(spacing: size * 0.015) {
            JerseyShirtView(
                primaryColor: primaryColor,
                secondaryColor: secondaryColor,
                pattern: pattern,
                size: size
            )
            JerseyShortsView(color: pantsColor, size: size)
        }
    }
}

// MARK: - シャツ

struct JerseyShirtView: View {
    let primaryColor: Color
    let secondaryColor: Color
    let pattern: JerseyPattern
    var size: CGFloat = 130

    var body: some View {
        Canvas { ctx, cs in
            let w = cs.width, h = cs.height

            // 1. 影（下にオフセット）
            let shadow = shirtPath(w: w, h: h)
            ctx.fill(shadow, with: .color(.black.opacity(0.10)))

            // 2. ジャージ本体（クリップ＆パターン）
            ctx.drawLayer { lc in
                lc.clip(to: shirtPath(w: w, h: h))

                // 下地（プライマリ）
                var bg = Path(); bg.addRect(CGRect(origin: .zero, size: cs))
                lc.fill(bg, with: .color(primaryColor))

                // パターン上書き
                switch pattern {
                case .solid: break
                case .stripes:
                    let n = 10
                    let sw = w / CGFloat(n)
                    for i in stride(from: 1, through: n, by: 2) {
                        var s = Path()
                        s.addRect(CGRect(x: CGFloat(i)*sw, y: 0, width: sw, height: h))
                        lc.fill(s, with: .color(secondaryColor))
                    }
                case .border:
                    let n = 8
                    let sh = h / CGFloat(n)
                    for i in stride(from: 1, through: n, by: 2) {
                        var s = Path()
                        s.addRect(CGRect(x: 0, y: CGFloat(i)*sh, width: w, height: sh))
                        lc.fill(s, with: .color(secondaryColor))
                    }
                }

                // 袖の上にプライマリの少し暗い面（立体感）
                let leftShade = leftSleevePath(w: w, h: h)
                lc.fill(leftShade, with: .color(.black.opacity(0.07)))
                let rightShade = rightSleevePath(w: w, h: h)
                lc.fill(rightShade, with: .color(.black.opacity(0.04)))
            }

            // 3. 白い衿の下地
            var collarBase = Path()
            collarBase.move(to: p(0.37, 0.00, w, h))
            collarBase.addLine(to: p(0.63, 0.00, w, h))
            collarBase.addLine(to: p(0.57, 0.00, w, h))
            collarBase.addLine(to: p(0.50, 0.17, w, h))
            collarBase.addLine(to: p(0.43, 0.00, w, h))
            collarBase.closeSubpath()
            ctx.fill(collarBase, with: .color(.white))

            // 4. 衿のVライン（白い縫い目風）
            var vLine = Path()
            vLine.move(to:    p(0.43, 0.00, w, h))
            vLine.addLine(to: p(0.50, 0.17, w, h))
            vLine.addLine(to: p(0.57, 0.00, w, h))
            ctx.stroke(vLine, with: .color(.white.opacity(0.9)), lineWidth: max(2, size*0.022))
            ctx.stroke(vLine, with: .color(.black.opacity(0.18)), lineWidth: max(3, size*0.030))

            // 5. アウトライン
            ctx.stroke(shirtPath(w: w, h: h),
                       with: .color(.black.opacity(0.18)), lineWidth: 1.2)
        }
        .frame(width: size, height: size * 0.92)
        .shadow(color: .black.opacity(0.10), radius: 3, x: 0, y: 2)
    }

    // ── シャツ輪郭 ──────────────────────────────────────────────
    // V ネックをパスの上辺に組み込む（三角の凹みとして表現）
    private func shirtPath(w: CGFloat, h: CGFloat) -> Path {
        var path = Path()
        // 左衿
        path.move(to: p(0.37, 0.00, w, h))
        // 左肩→左袖先（カーブ）
        path.addQuadCurve(
            to:      p(0.02, 0.18, w, h),
            control: p(0.15, 0.00, w, h))
        // 袖の下辺（左）
        path.addQuadCurve(
            to:      p(0.05, 0.47, w, h),
            control: p(-0.02, 0.34, w, h))
        // 脇へ
        path.addQuadCurve(
            to:      p(0.23, 0.41, w, h),
            control: p(0.10, 0.48, w, h))
        // 左サイド→左裾
        path.addLine(to: p(0.20, 1.00, w, h))
        // 裾
        path.addLine(to: p(0.80, 1.00, w, h))
        // 右裾→右サイド
        path.addLine(to: p(0.77, 0.41, w, h))
        // 右脇へ
        path.addQuadCurve(
            to:      p(0.95, 0.47, w, h),
            control: p(0.90, 0.48, w, h))
        // 右袖下辺
        path.addQuadCurve(
            to:      p(0.98, 0.18, w, h),
            control: p(1.02, 0.34, w, h))
        // 右袖先→右肩→右衿
        path.addQuadCurve(
            to:      p(0.63, 0.00, w, h),
            control: p(0.85, 0.00, w, h))
        // V ネック（右→中央→左）
        path.addLine(to: p(0.57, 0.00, w, h))
        path.addLine(to: p(0.50, 0.17, w, h))
        path.addLine(to: p(0.43, 0.00, w, h))
        path.closeSubpath()
        return path
    }

    private func leftSleevePath(w: CGFloat, h: CGFloat) -> Path {
        var p2 = Path()
        p2.move(to: p(0.37, 0.00, w, h))
        p2.addQuadCurve(to: p(0.02, 0.18, w, h), control: p(0.15, 0.00, w, h))
        p2.addQuadCurve(to: p(0.05, 0.47, w, h), control: p(-0.02, 0.34, w, h))
        p2.addQuadCurve(to: p(0.23, 0.41, w, h), control: p(0.10, 0.48, w, h))
        p2.addLine(to: p(0.23, 0.20, w, h))
        p2.closeSubpath()
        return p2
    }

    private func rightSleevePath(w: CGFloat, h: CGFloat) -> Path {
        var p2 = Path()
        p2.move(to: p(0.63, 0.00, w, h))
        p2.addQuadCurve(to: p(0.98, 0.18, w, h), control: p(0.85, 0.00, w, h))
        p2.addQuadCurve(to: p(0.95, 0.47, w, h), control: p(1.02, 0.34, w, h))
        p2.addQuadCurve(to: p(0.77, 0.41, w, h), control: p(0.90, 0.48, w, h))
        p2.addLine(to: p(0.77, 0.20, w, h))
        p2.closeSubpath()
        return p2
    }

    private func p(_ x: Double, _ y: Double, _ w: CGFloat, _ h: CGFloat) -> CGPoint {
        CGPoint(x: x * w, y: y * h)
    }
}

// MARK: - パンツ（ショーツ）

struct JerseyShortsView: View {
    let color: Color
    var size: CGFloat = 130

    var body: some View {
        Canvas { ctx, cs in
            let w = cs.width, h = cs.height

            // 全体シルエット（ウエストバンド含む）
            var full = Path()
            full.move(to:    CGPoint(x: w*0.18, y: 0))
            full.addLine(to: CGPoint(x: w*0.82, y: 0))
            // 右外
            full.addLine(to: CGPoint(x: w*0.88, y: h))
            // 右脚底
            full.addLine(to: CGPoint(x: w*0.54, y: h))
            // 股の間（右から左）
            full.addQuadCurve(
                to:      CGPoint(x: w*0.46, y: h),
                control: CGPoint(x: w*0.50, y: h*0.52))
            // 左脚底
            full.addLine(to: CGPoint(x: w*0.12, y: h))
            full.closeSubpath()
            ctx.fill(full, with: .color(color))

            // ウエストバンド（少し濃く）
            var waist = Path()
            waist.addRect(CGRect(x: w*0.18, y: 0, width: w*0.64, height: h*0.18))
            ctx.fill(waist, with: .color(color.opacity(0.75)))

            // 股下の影
            var crotch = Path()
            crotch.move(to:    CGPoint(x: w*0.50, y: h*0.55))
            crotch.addLine(to: CGPoint(x: w*0.46, y: h))
            crotch.addLine(to: CGPoint(x: w*0.54, y: h))
            crotch.closeSubpath()
            ctx.fill(crotch, with: .color(.black.opacity(0.08)))

            // アウトライン
            ctx.stroke(full, with: .color(.black.opacity(0.18)), lineWidth: 1.2)
            // ウエストバンド区切り線
            var wLine = Path()
            wLine.move(to:    CGPoint(x: w*0.18, y: h*0.18))
            wLine.addLine(to: CGPoint(x: w*0.82, y: h*0.18))
            ctx.stroke(wLine, with: .color(.black.opacity(0.10)), lineWidth: 0.8)
        }
        .frame(width: size * 0.84, height: size * 0.55)
        .shadow(color: .black.opacity(0.08), radius: 2, x: 0, y: 1)
    }
}

// MARK: - Color ↔ Hex

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r = Double((int >> 16) & 0xFF) / 255
        let g = Double((int >> 8)  & 0xFF) / 255
        let b = Double(int         & 0xFF) / 255
        self.init(red: r, green: g, blue: b)
    }

    func toHex() -> String {
        let ui = UIColor(self)
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        ui.getRed(&r, green: &g, blue: &b, alpha: &a)
        return String(format: "%02X%02X%02X",
                      Int((r*255).rounded()),
                      Int((g*255).rounded()),
                      Int((b*255).rounded()))
    }
}

// MARK: - カラープリセット（24色）

let jerseyColorPresets: [(hex: String, label: String)] = [
    ("FFFFFF", "白"),    ("F0F0F0", "オフホワイト"), ("000000", "黒"),   ("374151", "チャコール"),
    ("CC0000", "赤"),    ("FF4444", "明るい赤"),     ("FF8C00", "オレンジ"), ("FACC15", "黄"),
    ("16A34A", "緑"),    ("15803D", "深緑"),          ("2563EB", "青"),   ("1D4ED8", "ダーク青"),
    ("0E7490", "シアン"), ("7C3AED", "紫"),           ("DB2777", "ピンク"), ("BE185D", "深ピンク"),
    ("92400E", "茶"),    ("78350F", "こげ茶"),        ("6B7280", "グレー"), ("9CA3AF", "シルバー"),
    ("B91C1C", "バーガンディ"), ("1E40AF", "ネイビー"), ("065F46", "モスグリーン"), ("4C1D95", "インディゴ"),
]
