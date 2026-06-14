import UIKit
import Vision
import CoreImage.CIFilterBuiltins

// 端末内で人物を切り抜く（外部送信なし）
// iOS 17以降のVision人物セグメンテーションを使用
enum BackgroundRemover {

    static func removeBackground(from image: UIImage) -> UIImage? {
        guard let cgImage = image.cgImage else { return image }

        let request = VNGenerateForegroundInstanceMaskRequest()
        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])

        do {
            try handler.perform([request])
            guard let result = request.results?.first else { return image }

            let maskPixelBuffer = try result.generateScaledMaskForImage(
                forInstances: result.allInstances,
                from: handler
            )
            return applyMask(maskPixelBuffer, to: cgImage, orientation: image.imageOrientation)
        } catch {
            // 人物が検出できなかった場合は元画像をそのまま返す
            return image
        }
    }

    private static func applyMask(_ mask: CVPixelBuffer,
                                  to cgImage: CGImage,
                                  orientation: UIImage.Orientation) -> UIImage? {
        let original = CIImage(cgImage: cgImage)
        let maskImage = CIImage(cvPixelBuffer: mask)

        let filter = CIFilter.blendWithMask()
        filter.inputImage = original
        filter.maskImage = maskImage
        filter.backgroundImage = CIImage.empty()

        guard let output = filter.outputImage else { return nil }

        let context = CIContext()
        guard let cg = context.createCGImage(output, from: output.extent) else { return nil }
        return UIImage(cgImage: cg, scale: 1.0, orientation: orientation)
    }
}
