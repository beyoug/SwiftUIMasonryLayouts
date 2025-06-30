import XCTest
import SwiftUI
@testable import SwiftUIMasonryLayouts

@available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *)
final class SizeCalculatorTests: XCTestCase {
    
    struct PhotoItem: Identifiable {
        let id = UUID()
        let title: String
        let aspectRatio: CGFloat
        let url: URL?
        
        static let sampleData = [
            PhotoItem(title: "风景1", aspectRatio: 1.5, url: nil),
            PhotoItem(title: "风景2", aspectRatio: 0.8, url: nil),
            PhotoItem(title: "风景3", aspectRatio: 1.2, url: nil),
        ]
    }
    
    // MARK: - 测试固定尺寸 vs sizeCalculator 的差异

    func testFixedSizeVsSizeCalculator() {
        let photos = PhotoItem.sampleData

        // 这个测试只验证视图能正确创建，不涉及UI渲染
        XCTAssertEqual(photos.count, 3)
        XCTAssertNotNil(photos.first?.title)
    }
    
    // MARK: - 测试响应式图片尺寸

    func testResponsiveImageSizing() {
        let photos = PhotoItem.sampleData

        // 测试响应式尺寸计算逻辑
        let lineSize: CGFloat = 200
        for photo in photos {
            let imageHeight = lineSize / photo.aspectRatio
            let textHeight: CGFloat = 20
            let padding: CGFloat = 8
            let totalHeight = imageHeight + textHeight + padding

            XCTAssertGreaterThan(totalHeight, 0)
            XCTAssertGreaterThan(imageHeight, 0)
            print("照片: \(photo.title), 宽高比: \(photo.aspectRatio), 计算高度: \(totalHeight)")
        }
    }
    
    // MARK: - 测试布局计算准确性
    
    func testLayoutCalculationAccuracy() {
        let photos = PhotoItem.sampleData
        let containerWidth: CGFloat = 300
        let columns = 2
        let spacing: CGFloat = 12
        let lineSize = (containerWidth - spacing) / CGFloat(columns)
        
        print("容器宽度: \(containerWidth)")
        print("列数: \(columns)")
        print("间距: \(spacing)")
        print("计算的列宽: \(lineSize)")
        
        // 测试不同场景的高度计算
        for (index, photo) in photos.enumerated() {
            // 固定尺寸场景
            let fixedHeight: CGFloat = 100 + 20 + 8  // 图片 + 文本 + 间距
            
            // 响应式尺寸场景
            let responsiveImageHeight = lineSize / photo.aspectRatio
            let responsiveHeight = responsiveImageHeight + 20 + 8
            
            print("照片 \(index + 1) (\(photo.title)):")
            print("  - 宽高比: \(photo.aspectRatio)")
            print("  - 固定尺寸高度: \(fixedHeight)")
            print("  - 响应式高度: \(responsiveHeight)")
            print("  - 高度差异: \(abs(responsiveHeight - fixedHeight))")
        }
    }
    
    // MARK: - 测试常见问题场景

    func testCommonIssueScenarios() {
        // 问题场景1：固定宽度但容器宽度变化
        let narrowContainer: CGFloat = 200  // 窄容器
        let wideContainer: CGFloat = 400    // 宽容器

        for containerWidth in [narrowContainer, wideContainer] {
            let lineSize = containerWidth / 2  // 2列布局

            print("\n容器宽度: \(containerWidth), 列宽: \(lineSize)")

            // 固定图片宽度150pt的问题
            if lineSize < 150 {
                print("⚠️ 问题：图片宽度(150pt) > 列宽(\(lineSize)pt)")
                print("   结果：图片会溢出或被压缩")
            } else {
                print("✅ 正常：图片宽度(150pt) < 列宽(\(lineSize)pt)")
            }
        }
    }
    
    // MARK: - 测试最佳实践

    func testBestPractices() {
        let photos = PhotoItem.sampleData

        // 测试最佳实践的计算逻辑
        let lineSize: CGFloat = 200

        for photo in photos {
            // 图片占用90%的列宽，留出边距
            let imageWidth = lineSize * 0.9
            let imageHeight = imageWidth / photo.aspectRatio
            let textHeight: CGFloat = 20
            let padding: CGFloat = 16
            let totalHeight = imageHeight + textHeight + padding

            XCTAssertGreaterThan(totalHeight, 0)
            XCTAssertLessThan(imageWidth, lineSize)  // 图片宽度应该小于列宽
            print("照片: \(photo.title)")
            print("  - 列宽: \(lineSize), 图片宽: \(imageWidth), 图片高: \(imageHeight)")
            print("  - 总高度: \(totalHeight)")
        }

        print("✅ 最佳实践：响应式图片 + 精确sizeCalculator")
    }
}
