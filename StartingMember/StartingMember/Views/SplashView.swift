import SwiftUI

struct SplashView: View {
    @State private var jerseyScale: CGFloat = 0.4
    @State private var jerseyOpacity: Double = 0
    @State private var titleOpacity: Double = 0
    @State private var titleOffset: CGFloat = 12
    @State private var isFinished = false

    var body: some View {
        ZStack {
            // メイン画面（スプラッシュ終了後に表示）
            TeamListView()
                .opacity(isFinished ? 1 : 0)
                .animation(.easeIn(duration: 0.3), value: isFinished)

            // スプラッシュ
            if !isFinished {
                ZStack {
                    Color(red: 0.06, green: 0.12, blue: 0.22)
                        .ignoresSafeArea()

                    VStack(spacing: 24) {
                        // キャラクター画像（Assets に SplashCharacter を追加）
                        Image("soccer_player")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 360, height: 360)
                            .scaleEffect(jerseyScale)
                            .opacity(jerseyOpacity)

                        // アプリ名
                        VStack(spacing: 6) {
                            Text("StartingMember")
                                .font(.system(size: 26, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                            Text("スタメンを、共有しよう。")
                                .font(.system(size: 13, weight: .regular))
                                .foregroundColor(.white.opacity(0.5))
                        }
                        .opacity(titleOpacity)
                        .offset(y: titleOffset)
                    }
                }
                .transition(.opacity)
            }
        }
        .onAppear {
            // ジャージ：スプリングでポンと出る
            withAnimation(.spring(response: 0.55, dampingFraction: 0.62).delay(0.15)) {
                jerseyScale   = 1.0
                jerseyOpacity = 1.0
            }
            // タイトル：少し遅れてフェードアップ
            withAnimation(.easeOut(duration: 0.45).delay(0.5)) {
                titleOpacity = 1.0
                titleOffset  = 0
            }
            // 終了：スプラッシュをフェードアウト
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.9) {
                withAnimation(.easeInOut(duration: 0.4)) {
                    isFinished = true
                }
            }
        }
    }
}
