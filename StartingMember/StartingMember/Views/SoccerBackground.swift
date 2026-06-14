import SwiftUI

// MARK: - ユーザー設定の背景写真

struct BackgroundImageView: View {
    let image: UIImage
    var scale: Double   // 1.0 〜 2.0
    var opacity: Double // 0.0（透明）〜 1.0（不透明）

    var body: some View {
        GeometryReader { geo in
            Image(uiImage: image)
                .resizable()
                .scaledToFill()
                .frame(
                    width:  geo.size.width  * scale,
                    height: geo.size.height * scale
                )
                .position(x: geo.size.width / 2, y: geo.size.height / 2)
                .opacity(opacity)
                .clipped()
        }
        .ignoresSafeArea()
    }
}

// MARK: - ピッチの柄

enum PitchStyle: String, Codable, CaseIterable {
    case stripes = "ストライプ"
    case checker = "チェッカー"
    case diamond = "ダイヤモンド"
    case plain   = "シンプル"
}

// MARK: - フォーメーション画面のピッチ背景（柄選択対応）

struct PitchBackground: View {
    var style: PitchStyle = .stripes

    private let base1 = Color(red: 0.13, green: 0.45, blue: 0.18)
    private let base2 = Color(red: 0.15, green: 0.50, blue: 0.20)

    var body: some View {
        GeometryReader { geo in
            ZStack {
                // 芝パターン
                Canvas { ctx, size in
                    drawPattern(ctx: ctx, size: size)
                }

                // ピッチライン（共通）
                Canvas { ctx, size in
                    drawLines(ctx: ctx, size: size)
                }
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }

    private func drawPattern(ctx: GraphicsContext, size: CGSize) {
        let w = size.width, h = size.height

        // ベース塗り
        var bg = Path(); bg.addRect(CGRect(origin: .zero, size: size))
        ctx.fill(bg, with: .color(base1))

        switch style {
        case .stripes:
            let n = 8
            let sw = w / CGFloat(n)
            for i in 0..<n where i % 2 == 1 {
                var p = Path()
                p.addRect(CGRect(x: CGFloat(i) * sw, y: 0, width: sw, height: h))
                ctx.fill(p, with: .color(base2))
            }

        case .checker:
            let cols = 6, rows = 10
            let cw = w / CGFloat(cols), ch = h / CGFloat(rows)
            for r in 0..<rows {
                for c in 0..<cols where (r + c) % 2 == 1 {
                    var p = Path()
                    p.addRect(CGRect(x: CGFloat(c)*cw, y: CGFloat(r)*ch, width: cw, height: ch))
                    ctx.fill(p, with: .color(base2))
                }
            }

        case .diamond:
            let spacing: CGFloat = w / 5
            var p = Path()
            var y: CGFloat = -spacing
            while y < h + spacing {
                p.move(to: CGPoint(x: 0, y: y))
                p.addLine(to: CGPoint(x: w, y: y + spacing * 2))
                y += spacing * 2
            }
            ctx.stroke(p, with: .color(base2.opacity(0.6)), lineWidth: spacing * 0.9)

        case .plain:
            break
        }
    }

    private func drawLines(ctx: GraphicsContext, size: CGSize) {
        let w = size.width, h = size.height
        let lw: CGFloat = 1.5
        let c = Color.white.opacity(0.55)

        func line(_ x1: CGFloat, _ y1: CGFloat, _ x2: CGFloat, _ y2: CGFloat) {
            var p = Path()
            p.move(to: CGPoint(x: x1, y: y1))
            p.addLine(to: CGPoint(x: x2, y: y2))
            ctx.stroke(p, with: .color(c), lineWidth: lw)
        }
        func rect(_ x: CGFloat, _ y: CGFloat, _ rw: CGFloat, _ rh: CGFloat) {
            var p = Path()
            p.addRect(CGRect(x: x, y: y, width: rw, height: rh))
            ctx.stroke(p, with: .color(c), lineWidth: lw)
        }

        let pad: CGFloat = 4
        rect(pad, pad, w - pad*2, h - pad*2)
        line(pad, h/2, w - pad, h/2)

        let cx = w/2, cy = h/2, r = w * 0.13
        var circle = Path()
        circle.addEllipse(in: CGRect(x: cx-r, y: cy-r, width: r*2, height: r*2))
        ctx.stroke(circle, with: .color(c), lineWidth: lw)
        var dot = Path(); dot.addEllipse(in: CGRect(x: cx-2, y: cy-2, width: 4, height: 4))
        ctx.fill(dot, with: .color(c))

        let penW = w * 0.52, penH = h * 0.14
        rect((w - penW)/2, h - pad - penH, penW, penH)
        let goalW = w * 0.28, goalH = h * 0.055
        rect((w - goalW)/2, h - pad - goalH, goalW, goalH)
        rect((w - penW)/2, pad, penW, penH)
        rect((w - goalW)/2, pad, goalW, goalH)
    }
}

// MARK: - チーム一覧・選手一覧の背景

struct SoccerFieldBackground: View {
    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height

            ZStack {
                // ベースカラー
                Color(red: 0.07, green: 0.28, blue: 0.10)

                // 縦ストライプ（芝目）
                Canvas { ctx, size in
                    let n = 7
                    let sw = size.width / CGFloat(n)
                    for i in 0..<n where i % 2 == 1 {
                        var p = Path()
                        p.addRect(CGRect(x: CGFloat(i)*sw, y: 0, width: sw, height: size.height))
                        ctx.fill(p, with: .color(Color(red: 0.09, green: 0.33, blue: 0.12)))
                    }
                }

                // ピッチライン（装飾・全画面スケール）
                Canvas { ctx, size in
                    let lw: CGFloat = 1.2
                    let c = Color.white.opacity(0.18)
                    let sw = size.width, sh = size.height

                    func stroke(_ path: Path) {
                        ctx.stroke(path, with: .color(c), lineWidth: lw)
                    }

                    // 外枠
                    var border = Path()
                    border.addRect(CGRect(x: 20, y: 20, width: sw-40, height: sh-40))
                    stroke(border)

                    // センターライン
                    var cl = Path()
                    cl.move(to:    CGPoint(x: 20, y: sh/2))
                    cl.addLine(to: CGPoint(x: sw-20, y: sh/2))
                    stroke(cl)

                    // センターサークル
                    let r = sw * 0.18
                    var circle = Path()
                    circle.addEllipse(in: CGRect(x: sw/2-r, y: sh/2-r, width: r*2, height: r*2))
                    stroke(circle)

                    // ペナルティエリア（上下）
                    let penW = sw * 0.58, penH = sh * 0.13
                    var tp = Path()
                    tp.addRect(CGRect(x: (sw-penW)/2, y: 20, width: penW, height: penH))
                    stroke(tp)
                    var bp = Path()
                    bp.addRect(CGRect(x: (sw-penW)/2, y: sh-20-penH, width: penW, height: penH))
                    stroke(bp)

                    // コーナーアーク
                    let cr: CGFloat = 22
                    let corners: [(CGFloat, CGFloat, CGFloat, CGFloat)] = [
                        (20, 20, 0, .pi/2),
                        (sw-20, 20, .pi/2, .pi),
                        (20, sh-20, -.pi/2, 0),
                        (sw-20, sh-20, .pi, 3 * .pi/2)
                    ]
                    for (cx, cy, start, end) in corners {
                        var arc = Path()
                        arc.addArc(center: CGPoint(x: cx, y: cy),
                                   radius: cr, startAngle: .radians(start),
                                   endAngle: .radians(end), clockwise: false)
                        stroke(arc)
                    }
                }
                .frame(width: w, height: h)

                // 上部の暗いグラデーション（可読性のため）
                LinearGradient(
                    colors: [Color.black.opacity(0.45), Color.clear, Color.black.opacity(0.25)],
                    startPoint: .top, endPoint: .bottom
                )
            }
        }
        .ignoresSafeArea()
    }
}
