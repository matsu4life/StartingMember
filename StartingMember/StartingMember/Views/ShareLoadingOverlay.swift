import SwiftUI

struct ShareLoadingOverlay: View {
    let team: Team

    @State private var animating = false

    var body: some View {
        ZStack {
            Color.black.opacity(0.55)
                .ignoresSafeArea()

            VStack(spacing: 20) {
                // リフティングアニメ
                ZStack {
                    // ボール（足元 → 頭上へ弧を描く）
                    Text("⚽")
                        .font(.system(size: 26))
                        .offset(y: animating ? -148 : 58)
                        .scaleEffect(animating ? 0.85 : 1.05)
                        .animation(
                            .easeInOut(duration: 0.62)
                            .repeatForever(autoreverses: true),
                            value: animating
                        )

                    // ジャージ（ボールに合わせて微妙にキック感）
                    UniformView(
                        primaryColor:   Color(hex: team.jerseyPrimaryHex),
                        secondaryColor: Color(hex: team.jerseySecondaryHex),
                        pattern:        team.jerseyPattern,
                        pantsColor:     Color(hex: team.jerseyPantsHex),
                        size:           100
                    )
                    .offset(y: animating ? -4 : 4)
                    .animation(
                        .easeInOut(duration: 0.62)
                        .repeatForever(autoreverses: true),
                        value: animating
                    )
                }
                .frame(width: 120, height: 240)

                Text("画像を生成中…")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.75))
            }
        }
        .onAppear {
            animating = true
        }
    }
}
