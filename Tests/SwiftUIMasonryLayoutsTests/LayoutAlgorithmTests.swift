//
// Copyright (c) Beyoug
//

@testable import SwiftUIMasonryLayouts
import XCTest
import SwiftUI

@available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *)
final class LayoutAlgorithmTests: XCTestCase {
    
    func testBasicLayoutCalculation() {
        // 测试基本的布局计算逻辑
        let containerSize = CGSize(width: 300, height: 1000)
        let parameters = LayoutParameters(
            containerSize: containerSize,
            axis: .vertical,
            lines: .fixed(2),
            hSpacing: 8,
            vSpacing: 8,
            placement: .fill,
            simpleSizing: nil
        )
        
        // 模拟项目尺寸
        let itemSizes = [
            CGSize(width: 146, height: 80),   // 第一个项目
            CGSize(width: 146, height: 120),  // 第二个项目
            CGSize(width: 146, height: 160),  // 第三个项目
            CGSize(width: 146, height: 100),  // 第四个项目
        ]
        
        // 手动计算预期的布局
        let lineCount = parameters.calculateLineCount()
        let lineSize = parameters.calculateLineSize(lineCount: lineCount)
        
        XCTAssertEqual(lineCount, 2)
        XCTAssertEqual(lineSize, 146, accuracy: 1.0) // (300 - 8) / 2 = 146
        
        // 模拟布局计算过程
        var lineOffsets: [CGFloat] = Array(repeating: 0, count: lineCount)
        var frames: [CGRect] = []
        
        for (index, itemSize) in itemSizes.enumerated() {
            let lineIndex = parameters.selectLineIndex(lineOffsets: lineOffsets, index: index)
            
            let frame = CGRect(
                x: CGFloat(lineIndex) * lineSize + CGFloat(lineIndex) * parameters.hSpacing,
                y: lineOffsets[lineIndex],
                width: lineSize,
                height: itemSize.height
            )
            
            frames.append(frame)
            
            // 更新行偏移
            lineOffsets[lineIndex] += itemSize.height + parameters.vSpacing
            
            print("项目 \(index): 列 \(lineIndex), 框架 \(frame), 列偏移 \(lineOffsets)")
        }
        
        // 验证没有重叠
        for i in 0..<frames.count {
            for j in (i+1)..<frames.count {
                let frame1 = frames[i]
                let frame2 = frames[j]
                
                // 检查是否重叠
                let intersects = frame1.intersects(frame2)
                if intersects {
                    XCTFail("项目 \(i) 和项目 \(j) 重叠: \(frame1) 与 \(frame2)")
                }
            }
        }
        
        // 验证预期位置
        XCTAssertEqual(frames[0].origin.x, 0)      // 第一列
        XCTAssertEqual(frames[0].origin.y, 0)      // 第一行
        
        XCTAssertEqual(frames[1].origin.x, 154)    // 第二列 (146 + 8)
        XCTAssertEqual(frames[1].origin.y, 0)      // 第一行
        
        // 第三个项目应该放在第一列（因为第一列偏移较小）
        XCTAssertEqual(frames[2].origin.x, 0)      // 第一列
        XCTAssertEqual(frames[2].origin.y, 88)     // 80 + 8
        
        // 第四个项目应该放在第二列
        XCTAssertEqual(frames[3].origin.x, 154)    // 第二列
        XCTAssertEqual(frames[3].origin.y, 128)    // 120 + 8
    }
    
    func testSelectLineIndexLogic() {
        // 测试列选择逻辑
        let parameters = LayoutParameters(
            containerSize: CGSize(width: 300, height: 1000),
            axis: .vertical,
            lines: .fixed(2),
            hSpacing: 8,
            vSpacing: 8,
            placement: .fill
        )
        
        // 初始状态：两列都是0
        var lineOffsets: [CGFloat] = [0, 0]
        
        // 第一个项目应该选择第一列（索引0）
        let index0 = parameters.selectLineIndex(lineOffsets: lineOffsets, index: 0)
        XCTAssertEqual(index0, 0)
        
        // 第二个项目应该选择第二列（索引1），但由于都是0，会选择第一个找到的最小值（索引0）
        let index1 = parameters.selectLineIndex(lineOffsets: lineOffsets, index: 1)
        XCTAssertEqual(index1, 0) // 修正：当两列偏移相同时，选择第一列
        
        // 更新偏移后测试
        lineOffsets[0] = 88  // 第一列有一个80高度的项目 + 8间距
        lineOffsets[1] = 128 // 第二列有一个120高度的项目 + 8间距
        
        // 第三个项目应该选择第一列（偏移较小）
        let index2 = parameters.selectLineIndex(lineOffsets: lineOffsets, index: 2)
        XCTAssertEqual(index2, 0)
        
        // 更新第一列偏移
        lineOffsets[0] = 248 // 88 + 160 + 8
        
        // 第四个项目应该选择第二列（现在偏移较小）
        let index3 = parameters.selectLineIndex(lineOffsets: lineOffsets, index: 3)
        XCTAssertEqual(index3, 1)
    }
    
    func testLayoutEngineIntegration() {
        // 测试布局引擎的集成
        let containerSize = CGSize(width: 300, height: 1000)
        let configuration = MasonryConfiguration(
            axis: .vertical,
            lines: .fixed(2),
            hSpacing: 8,
            vSpacing: 8,
            placement: .fill
        )
        
        var cache = LazyLayoutCache()
        
        // 模拟项目尺寸计算器
        let itemSizeCalculator: (Int, CGFloat) -> CGSize = { index, lineSize in
            let heights: [CGFloat] = [80, 120, 160, 100, 200, 70]
            let height = heights[index % heights.count]
            return CGSize(width: lineSize, height: height)
        }
        
        let result = MasonryLayoutEngine.calculateIndexBasedLazyLayout(
            containerSize: containerSize,
            itemCount: 6,
            configuration: configuration,
            itemSizeCalculator: itemSizeCalculator,
            cache: &cache
        )
        
        // 验证结果
        XCTAssertEqual(result.itemFrames.count, 6)
        XCTAssertEqual(result.lineCount, 2)
        
        // 验证没有重叠
        for i in 0..<result.itemFrames.count {
            for j in (i+1)..<result.itemFrames.count {
                let frame1 = result.itemFrames[i]
                let frame2 = result.itemFrames[j]
                
                let intersects = frame1.intersects(frame2)
                if intersects {
                    print("重叠检测:")
                    print("项目 \(i): \(frame1)")
                    print("项目 \(j): \(frame2)")
                    XCTFail("项目 \(i) 和项目 \(j) 重叠")
                }
            }
        }
        
        // 打印布局结果用于调试
        print("布局结果:")
        for (index, frame) in result.itemFrames.enumerated() {
            print("项目 \(index): \(frame)")
        }
    }
    
    func testRealWorldScenario() {
        // 测试真实世界的场景，模拟演示数据
        let containerSize = CGSize(width: 300, height: 1000)
        let configuration = MasonryConfiguration(
            axis: .vertical,
            lines: .fixed(2),
            hSpacing: 8,
            vSpacing: 8,
            placement: .fill
        )
        
        var cache = LazyLayoutCache()
        
        // 模拟演示数据的高度
        let demoHeights: [CGFloat] = [80, 120, 160, 90, 200, 70, 140, 110, 180]
        
        let itemSizeCalculator: (Int, CGFloat) -> CGSize = { index, lineSize in
            let itemHeight = demoHeights[index % demoHeights.count]
            let cardHeight = itemHeight + 30 // 加上标题区域
            return CGSize(width: lineSize, height: cardHeight)
        }
        
        let result = MasonryLayoutEngine.calculateIndexBasedLazyLayout(
            containerSize: containerSize,
            itemCount: demoHeights.count,
            configuration: configuration,
            itemSizeCalculator: itemSizeCalculator,
            cache: &cache
        )
        
        // 详细验证每个项目的位置
        print("真实场景布局结果:")
        var columnOffsets: [CGFloat] = [0, 0]
        
        for (index, frame) in result.itemFrames.enumerated() {
            let expectedHeight = demoHeights[index % demoHeights.count] + 30
            
            print("项目 \(index): 框架=\(frame), 预期高度=\(expectedHeight)")
            
            // 验证高度
            XCTAssertEqual(frame.height, expectedHeight, accuracy: 1.0)
            
            // 验证宽度
            XCTAssertEqual(frame.width, 146, accuracy: 1.0) // (300-8)/2
            
            // 验证X位置（应该是0或154）
            XCTAssertTrue(frame.origin.x == 0 || frame.origin.x == 154, "X位置不正确: \(frame.origin.x)")
        }
        
        // 验证没有重叠
        for i in 0..<result.itemFrames.count {
            for j in (i+1)..<result.itemFrames.count {
                let frame1 = result.itemFrames[i]
                let frame2 = result.itemFrames[j]
                
                if frame1.intersects(frame2) {
                    print("重叠详情:")
                    print("项目 \(i): \(frame1)")
                    print("项目 \(j): \(frame2)")
                    print("交集: \(frame1.intersection(frame2))")
                    XCTFail("项目 \(i) 和项目 \(j) 重叠")
                }
            }
        }
    }
}
