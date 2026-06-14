import SwiftUI

enum CropShape {
    case circle
    case roundedRect(cornerRadius: CGFloat)
}

struct PhotoCropView: View {
    let image: UIImage
    var cropShape: CropShape = .circle
    var onDone: (UIImage) -> Void

    @Environment(\.dismiss) var dismiss

    @State private var scale: CGFloat = 1
    @State private var lastScale: CGFloat = 1
    @State private var offset: CGSize = .zero
    @State private var lastOffset: CGSize = .zero

    private let cropSize: CGFloat = 280

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Text("ドラッグで位置、ピンチで拡大・縮小")
                    .font(.footnote)
                    .foregroundColor(.secondary)

                ZStack {
                    Color(.systemGray5)
                    transformedImage
                }
                .frame(width: cropSize, height: cropSize)
                .clipShape(clipShapeView)
                .overlay(overlayBorder)
                .gesture(dragGesture.simultaneously(with: magnifyGesture))

                Button("リセット") {
                    withAnimation { scale = 1; lastScale = 1; offset = .zero; lastOffset = .zero }
                }
                .font(.subheadline)

                Spacer()
            }
            .padding()
            .navigationTitle("写真の位置を調整")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("キャンセル") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("決定") { render() }
                }
            }
        }
    }

    private var transformedImage: some View {
        Image(uiImage: image)
            .resizable()
            .scaledToFill()
            .frame(width: cropSize, height: cropSize)
            .scaleEffect(scale)
            .offset(offset)
    }

    private var clipShapeView: AnyShape {
        switch cropShape {
        case .circle:              return AnyShape(Circle())
        case .roundedRect(let r): return AnyShape(RoundedRectangle(cornerRadius: r))
        }
    }

    @ViewBuilder
    private var overlayBorder: some View {
        switch cropShape {
        case .circle:
            Circle().stroke(Color.accentColor, lineWidth: 3)
        case .roundedRect(let r):
            RoundedRectangle(cornerRadius: r).stroke(Color.accentColor, lineWidth: 3)
        }
    }

    private var dragGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                offset = CGSize(
                    width: lastOffset.width + value.translation.width,
                    height: lastOffset.height + value.translation.height
                )
            }
            .onEnded { _ in lastOffset = offset }
    }

    private var magnifyGesture: some Gesture {
        MagnificationGesture()
            .onChanged { value in scale = min(max(lastScale * value, 1), 5) }
            .onEnded { _ in lastScale = scale }
    }

    @MainActor
    private func render() {
        let content = ZStack {
            Color.clear
            transformedImage
        }
        .frame(width: cropSize, height: cropSize)
        .clipShape(clipShapeView)

        let renderer = ImageRenderer(content: content)
        renderer.scale = 3
        if let ui = renderer.uiImage {
            onDone(ui)
        }
        dismiss()
    }
}

// SwiftUI の Shape を型消去するラッパー
struct AnyShape: Shape {
    private let pathBuilder: (CGRect) -> Path
    init<S: Shape>(_ shape: S) { pathBuilder = { shape.path(in: $0) } }
    func path(in rect: CGRect) -> Path { pathBuilder(rect) }
}
