//
// Copyright (c) Beyoug
//

@testable import SwiftUIMasonryLayouts
import XCTest
import SwiftUI

@available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *)
final class CardListDemoTests: XCTestCase {
    
    func testCardItemGeneration() {
        // 测试卡片数据生成
        let cards = (1...30).map { CardListDemo.CardItem(id: $0) }
        
        XCTAssertEqual(cards.count, 30)
        
        // 验证第一个卡片
        let firstCard = cards[0]
        XCTAssertEqual(firstCard.id, 1)
        XCTAssertEqual(firstCard.title, "卡片 1")
        XCTAssertEqual(firstCard.subtitle, "这是卡片 1 的描述内容")
        XCTAssertFalse(firstCard.hasImage) // 1 % 3 != 0
        
        // 验证有图片的卡片
        let cardWithImage = cards[2] // id = 3, 3 % 3 == 0
        XCTAssertEqual(cardWithImage.id, 3)
        XCTAssertTrue(cardWithImage.hasImage)
        
        // 验证没有图片的卡片
        let cardWithoutImage = cards[3] // id = 4, 4 % 3 != 0
        XCTAssertEqual(cardWithoutImage.id, 4)
        XCTAssertFalse(cardWithoutImage.hasImage)
    }
    
    func testCardSizeCalculation() {
        // 测试卡片尺寸计算逻辑
        let containerSize = CGSize(width: 300, height: 1000)
        let configuration = MasonryConfiguration(lines: .fixed(2), hSpacing: 12, vSpacing: 12)
        
        var cache = LazyLayoutCache()
        
        // 模拟CardListDemo的尺寸计算器
        let cardSizeCalculator: (CardListDemo.CardItem, CGFloat) -> CGSize = { card, lineSize in
            let baseHeight: CGFloat = 80 // 标题和描述的基础高度
            let imageHeight: CGFloat = card.hasImage ? 100 + 8 : 0 // 图片高度 + 间距
            let totalHeight = baseHeight + imageHeight
            return CGSize(width: lineSize, height: totalHeight)
        }
        
        // 创建测试卡片
        let cards = (1...10).map { CardListDemo.CardItem(id: $0) }
        
        // 计算布局
        let result = MasonryLayoutEngine.calculateIndexBasedLazyLayout(
            containerSize: containerSize,
            itemCount: cards.count,
            configuration: configuration,
            itemSizeCalculator: { index, lineSize in
                let card = cards[index]
                return cardSizeCalculator(card, lineSize)
            },
            cache: &cache
        )
        
        // 验证结果
        XCTAssertEqual(result.itemFrames.count, cards.count)
        XCTAssertEqual(result.lineCount, 2)
        
        // 验证卡片尺寸
        for (index, frame) in result.itemFrames.enumerated() {
            let card = cards[index]
            let expectedHeight: CGFloat = card.hasImage ? 188 : 80 // 80 + (100 + 8) 或 80
            
            XCTAssertEqual(frame.height, expectedHeight, accuracy: 1.0, "卡片 \(card.id) 高度不正确")
            XCTAssertEqual(frame.width, 144, accuracy: 1.0) // (300 - 12) / 2 = 144
        }
        
        // 验证没有重叠
        for i in 0..<result.itemFrames.count {
            for j in (i+1)..<result.itemFrames.count {
                let frame1 = result.itemFrames[i]
                let frame2 = result.itemFrames[j]
                
                if frame1.intersects(frame2) {
                    XCTFail("卡片 \(i+1) 和卡片 \(j+1) 重叠: \(frame1) 与 \(frame2)")
                }
            }
        }
    }
    
    func testCardLayoutDistribution() {
        // 测试卡片在两列中的分布
        let containerSize = CGSize(width: 300, height: 1000)
        let configuration = MasonryConfiguration(lines: .fixed(2), hSpacing: 12, vSpacing: 12)
        
        var cache = LazyLayoutCache()
        
        // 创建测试卡片（包含有图片和无图片的）
        let cards = (1...12).map { CardListDemo.CardItem(id: $0) }
        
        let result = MasonryLayoutEngine.calculateIndexBasedLazyLayout(
            containerSize: containerSize,
            itemCount: cards.count,
            configuration: configuration,
            itemSizeCalculator: { index, lineSize in
                let card = cards[index]
                let baseHeight: CGFloat = 80
                let imageHeight: CGFloat = card.hasImage ? 100 + 8 : 0
                let totalHeight = baseHeight + imageHeight
                return CGSize(width: lineSize, height: totalHeight)
            },
            cache: &cache
        )
        
        // 统计每列的卡片数量
        var leftColumnCount = 0
        var rightColumnCount = 0
        
        for frame in result.itemFrames {
            if frame.origin.x < 150 { // 左列
                leftColumnCount += 1
            } else { // 右列
                rightColumnCount += 1
            }
        }
        
        // 验证分布相对均匀（差异不超过2）
        let difference = abs(leftColumnCount - rightColumnCount)
        XCTAssertLessThanOrEqual(difference, 2, "列分布不均匀：左列 \(leftColumnCount)，右列 \(rightColumnCount)")
        
        print("卡片分布：左列 \(leftColumnCount)，右列 \(rightColumnCount)")
    }
    
    func testCardWithAndWithoutImages() {
        // 专门测试有图片和无图片卡片的混合布局
        let cards = [
            CardListDemo.CardItem(id: 1), // 无图片
            CardListDemo.CardItem(id: 2), // 无图片
            CardListDemo.CardItem(id: 3), // 有图片
            CardListDemo.CardItem(id: 4), // 无图片
            CardListDemo.CardItem(id: 5), // 无图片
            CardListDemo.CardItem(id: 6), // 有图片
        ]
        
        // 验证图片逻辑
        XCTAssertFalse(cards[0].hasImage) // id=1, 1%3!=0
        XCTAssertFalse(cards[1].hasImage) // id=2, 2%3!=0
        XCTAssertTrue(cards[2].hasImage)  // id=3, 3%3==0
        XCTAssertFalse(cards[3].hasImage) // id=4, 4%3!=0
        XCTAssertFalse(cards[4].hasImage) // id=5, 5%3!=0
        XCTAssertTrue(cards[5].hasImage)  // id=6, 6%3==0
        
        let containerSize = CGSize(width: 300, height: 1000)
        let configuration = MasonryConfiguration(lines: .fixed(2), hSpacing: 12, vSpacing: 12)
        
        var cache = LazyLayoutCache()
        
        let result = MasonryLayoutEngine.calculateIndexBasedLazyLayout(
            containerSize: containerSize,
            itemCount: cards.count,
            configuration: configuration,
            itemSizeCalculator: { index, lineSize in
                let card = cards[index]
                let baseHeight: CGFloat = 80
                let imageHeight: CGFloat = card.hasImage ? 100 + 8 : 0
                let totalHeight = baseHeight + imageHeight
                return CGSize(width: lineSize, height: totalHeight)
            },
            cache: &cache
        )
        
        // 验证高度计算
        for (index, frame) in result.itemFrames.enumerated() {
            let card = cards[index]
            let expectedHeight: CGFloat = card.hasImage ? 188 : 80
            
            XCTAssertEqual(frame.height, expectedHeight, accuracy: 1.0, 
                          "卡片 \(card.id) 高度不正确，期望 \(expectedHeight)，实际 \(frame.height)")
        }
        
        // 打印布局结果用于调试
        print("混合卡片布局结果：")
        for (index, frame) in result.itemFrames.enumerated() {
            let card = cards[index]
            print("卡片 \(card.id) (图片: \(card.hasImage)): \(frame)")
        }
    }
    
    func testCardListDemoPerformance() {
        // 性能测试
        measure {
            let cards = (1...100).map { CardListDemo.CardItem(id: $0) }
            let containerSize = CGSize(width: 300, height: 2000)
            let configuration = MasonryConfiguration(lines: .fixed(2), hSpacing: 12, vSpacing: 12)
            
            var cache = LazyLayoutCache()
            
            let _ = MasonryLayoutEngine.calculateIndexBasedLazyLayout(
                containerSize: containerSize,
                itemCount: cards.count,
                configuration: configuration,
                itemSizeCalculator: { index, lineSize in
                    let card = cards[index]
                    let baseHeight: CGFloat = 80
                    let imageHeight: CGFloat = card.hasImage ? 100 + 8 : 0
                    let totalHeight = baseHeight + imageHeight
                    return CGSize(width: lineSize, height: totalHeight)
                },
                cache: &cache
            )
        }
    }
}
