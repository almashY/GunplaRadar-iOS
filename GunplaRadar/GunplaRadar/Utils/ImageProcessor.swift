//
//  ImageProcessor.swift
//  GunplaRadar
//
//  Created by almashY on 2026/04/21.
//

import UIKit

struct ImageProcessor {

    /// 画像データを指定サイズ内にリサイズして返す
    /// - Parameters:
    ///   - data: 元の画像データ
    ///   - maxDimension: 長辺の最大ピクセル数（デフォルト 1024）
    ///   - compressionQuality: JPEG圧縮品質 0.0〜1.0（デフォルト 0.8）
    /// - Returns: 処理後のデータ。変換失敗時は nil
    static func compress(
        _ data: Data,
        maxDimension: CGFloat = 1024,
        compressionQuality: CGFloat = 0.8
    ) -> Data? {
        guard let image = UIImage(data: data) else { return nil }
        let resized = resized(image, maxDimension: maxDimension)
        return resized.jpegData(compressionQuality: compressionQuality)
    }

    /// 画像を maxDimension 内に収まるようリサイズする（アスペクト比維持）
    static func resized(_ image: UIImage, maxDimension: CGFloat) -> UIImage {
        let size = image.size
        let longSide = max(size.width, size.height)
        guard longSide > maxDimension else { return image }

        let scale = maxDimension / longSide
        let newSize = CGSize(width: size.width * scale, height: size.height * scale)

        let renderer = UIGraphicsImageRenderer(size: newSize)
        return renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: newSize))
        }
    }
}
