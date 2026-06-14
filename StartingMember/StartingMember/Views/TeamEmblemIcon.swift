import SwiftUI

/// チームエンブレム表示。エンブレム画像 → 国旗絵文字 → デフォルトシールドの優先順で表示。
struct TeamEmblemIcon: View {
    let team: Team
    let size: CGFloat

    var body: some View {
        Group {
            if let data = team.emblemData, let uiImage = UIImage(data: data) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: size, height: size)
                    .clipShape(RoundedRectangle(cornerRadius: size * 0.2))
            } else if let flag = team.flagEmoji {
                Text(flag)
                    .font(.system(size: size * 0.75))
                    .frame(width: size, height: size)
            } else {
                Image(systemName: "shield.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: size * 0.7, height: size * 0.7)
                    .foregroundColor(.accentColor)
                    .frame(width: size, height: size)
            }
        }
    }
}
