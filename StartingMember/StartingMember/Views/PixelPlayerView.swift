import SwiftUI

// MARK: - ピクセルアートサッカー選手（カラー反映）

struct CartoonPlayerView: View {
    let primaryColor:   Color
    let secondaryColor: Color
    let pattern:        JerseyPattern
    let pantsColor:     Color
    let sockColor:      Color
    var size: CGFloat = 280

    private let hasBase    = UIImage(named: "soccer_player") != nil
    private let hasJersey  = UIImage(named: "jersey_mask")   != nil
    private let hasShorts  = UIImage(named: "shorts_mask")   != nil
    private let hasSocks   = UIImage(named: "socks_mask")    != nil

    var body: some View {
        ZStack {
            if hasBase {
                Image("soccer_player")
                    .resizable()
                    .interpolation(.none)
                    .scaledToFit()
                    .frame(maxWidth: size)
            }
            if hasJersey { jerseyLayer }
            if hasShorts {
                Image("shorts_mask")
                    .resizable().interpolation(.none)
                    .scaledToFit().frame(maxWidth: size)
                    .colorMultiply(pantsColor)
            }
            if hasSocks {
                Image("socks_mask")
                    .resizable().interpolation(.none)
                    .scaledToFit().frame(maxWidth: size)
                    .colorMultiply(sockColor)
            }
        }
    }

    @ViewBuilder
    private var jerseyLayer: some View {
        switch pattern {
        case .solid:
            Image("jersey_mask")
                .resizable().interpolation(.none)
                .scaledToFit().frame(height: size)
                .colorMultiply(primaryColor)

        case .stripes:
            ZStack {
                Image("jersey_mask")
                    .resizable().interpolation(.none).scaledToFit().frame(maxWidth: size)
                    .colorMultiply(primaryColor)
                Image("jersey_mask")
                    .resizable().interpolation(.none).scaledToFit().frame(maxWidth: size)
                    .colorMultiply(secondaryColor)
                    .mask(StripeMask(isVertical: true))
            }

        case .border:
            ZStack {
                Image("jersey_mask")
                    .resizable().interpolation(.none).scaledToFit().frame(maxWidth: size)
                    .colorMultiply(primaryColor)
                Image("jersey_mask")
                    .resizable().interpolation(.none).scaledToFit().frame(maxWidth: size)
                    .colorMultiply(secondaryColor)
                    .mask(StripeMask(isVertical: false))
            }
        }
    }
}

// MARK: - ストライプマスク（縦・横）

private struct StripeMask: View {
    let isVertical: Bool
    var stripes: Int = 8

    var body: some View {
        GeometryReader { geo in
            let total = isVertical ? geo.size.width : geo.size.height
            let w = total / CGFloat(stripes)
            ForEach(stride(from: 1, to: stripes, by: 2).map { $0 }, id: \.self) { i in
                if isVertical {
                    Rectangle().frame(width: w).offset(x: CGFloat(i) * w)
                } else {
                    Rectangle().frame(height: w).offset(y: CGFloat(i) * w)
                }
            }
        }
    }
}
