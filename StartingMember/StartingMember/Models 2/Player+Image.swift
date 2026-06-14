import SwiftUI

extension Player {
    // 保存された写真データをUIImageに変換
    var photoUIImage: UIImage? {
        guard let data = photoData else { return nil }
        return UIImage(data: data)
    }

    // 写真がない時に表示するイニシャル（名前の先頭1文字）
    var initial: String {
        String(name.prefix(1))
    }
}
