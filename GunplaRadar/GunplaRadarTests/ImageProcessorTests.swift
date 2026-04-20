//
//  ImageProcessorTests.swift
//  GunplaRadarTests
//
//  Created by almashY on 2026/04/21.
//

import XCTest
@testable import GunplaRadar

final class ImageProcessorTests: XCTestCase {

    // MARK: - compress

    // 有効なJPEGデータを渡すと、圧縮済みDataが返る
    func testCompressReturnsDataForValidInput() throws {
        let data = makeImageData(size: CGSize(width: 200, height: 200))
        let result = ImageProcessor.compress(data)
        XCTAssertNotNil(result)
    }

    // 画像として解釈できない無効なDataを渡すと nil が返る
    func testCompressReturnsNilForInvalidData() {
        let invalidData = Data([0x00, 0x01, 0x02])
        let result = ImageProcessor.compress(invalidData)
        XCTAssertNil(result)
    }

    // 長辺が maxDimension を超える画像は、指定サイズ内に縮小される
    func testCompressResizesImageExceedingMaxDimension() throws {
        let original = makeImageData(size: CGSize(width: 2000, height: 1000))
        let result = try XCTUnwrap(ImageProcessor.compress(original, maxDimension: 512))
        let image = try XCTUnwrap(UIImage(data: result))
        XCTAssertLessThanOrEqual(max(image.size.width, image.size.height), 512)
    }

    // 長辺が maxDimension 以下の画像は、元のサイズのまま返る
    func testCompressKeepsSizeWhenBelowMaxDimension() throws {
        let original = makeImageData(size: CGSize(width: 300, height: 200))
        let result = try XCTUnwrap(ImageProcessor.compress(original, maxDimension: 1024))
        let image = try XCTUnwrap(UIImage(data: result))
        XCTAssertEqual(image.size.width, 300, accuracy: 1)
        XCTAssertEqual(image.size.height, 200, accuracy: 1)
    }

    // MARK: - resized

    // リサイズ後もアスペクト比（幅:高さ）が維持される
    func testResizedPreservesAspectRatio() {
        let image = makeImage(size: CGSize(width: 800, height: 400))
        let resized = ImageProcessor.resized(image, maxDimension: 400)
        XCTAssertEqual(resized.size.width / resized.size.height, 2.0, accuracy: 0.01)
    }

    // 縦長画像の長辺が maxDimension 以内に収まる
    func testResizedPortraitImageFitsWithinMaxDimension() {
        let image = makeImage(size: CGSize(width: 500, height: 1000))
        let resized = ImageProcessor.resized(image, maxDimension: 512)
        XCTAssertLessThanOrEqual(resized.size.height, 512)
    }

    // maxDimension 以下の小さい画像はリサイズせずそのまま返る
    func testResizedReturnsOriginalWhenBelowMaxDimension() {
        let image = makeImage(size: CGSize(width: 100, height: 80))
        let resized = ImageProcessor.resized(image, maxDimension: 1024)
        XCTAssertEqual(resized.size.width, 100)
        XCTAssertEqual(resized.size.height, 80)
    }

    // MARK: - Helpers

    private func makeImage(size: CGSize) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { ctx in
            UIColor.systemBlue.setFill()
            ctx.fill(CGRect(origin: .zero, size: size))
        }
    }

    private func makeImageData(size: CGSize, quality: CGFloat = 0.9) -> Data {
        makeImage(size: size).jpegData(compressionQuality: quality)!
    }
}
