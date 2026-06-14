import SwiftUI

// ピッチ上・一覧で使う丸型の選手アイコン
struct PlayerAvatar: View {
    let player: Player
    var size: CGFloat = 48
    var showCaptainBadge: Bool = false

    var body: some View {
        ZStack(alignment: .topTrailing) {
            Circle()
                .fill(Color(red: 0.05, green: 0.13, blue: 0.27))
                .overlay(
                    Group {
                        if let img = player.photoUIImage {
                            Image(uiImage: img)
                                .resizable()
                                .scaledToFill()
                        } else {
                            Text("\(player.number)")
                                .font(.system(size: size * 0.4, weight: .medium))
                                .foregroundColor(.white)
                        }
                    }
                )
                .clipShape(Circle())
                .overlay(
                    Circle().stroke(
                        player.isCaptain ? Color(red: 0.98, green: 0.78, blue: 0.25)
                                         : Color.white.opacity(0.6),
                        lineWidth: player.isCaptain ? 2.5 : 1.5
                    )
                )
                .frame(width: size, height: size)

            if showCaptainBadge && player.isCaptain {
                Text("C")
                    .font(.system(size: size * 0.28, weight: .bold))
                    .foregroundColor(Color(red: 0.1, green: 0.04, blue: 0.37))
                    .frame(width: size * 0.36, height: size * 0.36)
                    .background(Circle().fill(Color(red: 0.98, green: 0.78, blue: 0.25)))
                    .offset(x: 2, y: -2)
            }
        }
    }
}
