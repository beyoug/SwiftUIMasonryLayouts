//
// Copyright (c) Beyoug
//

import XCTest
@testable import SwiftUIMasonryLayouts

/// 测试分页功能
@available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *)
@MainActor
final class PaginationTests: XCTestCase {
    
    func testBasicPagination() async {
        // 创建一个pageSize为10的数据加载器
        let dataLoader = TestDataLoader(pageSize: 10)
        
        // 验证初始状态
        XCTAssertEqual(dataLoader.items.count, 0, "初始状态应该没有数据")
        XCTAssertEqual(dataLoader.currentPage, 0, "初始页面应该是0")
        XCTAssertFalse(dataLoader.isLoading, "初始状态不应该在加载")
        
        // 加载第一页
        dataLoader.loadInitialData()
        
        // 等待加载完成
        try? await Task.sleep(nanoseconds: 600_000_000) // 0.6秒
        
        // 验证第一页加载结果
        XCTAssertEqual(dataLoader.items.count, 10, "第一页应该有10个项目")
        XCTAssertEqual(dataLoader.currentPage, 0, "当前页面应该是0")
        XCTAssertTrue(dataLoader.hasNextPage, "应该有下一页")
        XCTAssertFalse(dataLoader.isLoading, "加载应该已完成")
        
        // 验证总页数计算
        let expectedTotalPages = (dataLoader.totalItems + 10 - 1) / 10
        XCTAssertEqual(dataLoader.totalPages, expectedTotalPages, "总页数计算应该正确")
        
        // 加载第二页
        dataLoader.loadNextPage()
        
        // 等待加载完成
        try? await Task.sleep(nanoseconds: 600_000_000) // 0.6秒
        
        // 验证第二页加载结果
        XCTAssertEqual(dataLoader.items.count, 20, "第二页加载后应该有20个项目")
        XCTAssertEqual(dataLoader.currentPage, 1, "当前页面应该是1")
        XCTAssertTrue(dataLoader.hasNextPage, "应该还有下一页")
        XCTAssertFalse(dataLoader.isLoading, "加载应该已完成")
    }
    
    func testPaginationUntilEnd() async {
        // 创建一个小的pageSize来快速测试
        let dataLoader = TestDataLoader(pageSize: 50)
        
        dataLoader.loadInitialData()
        try? await Task.sleep(nanoseconds: 600_000_000)
        
        var loadCount = 1
        let maxLoads = 20 // 防止无限循环
        
        // 持续加载直到没有下一页
        while dataLoader.hasNextPage && loadCount < maxLoads {
            dataLoader.loadNextPage()
            try? await Task.sleep(nanoseconds: 600_000_000)
            loadCount += 1
            
            // 测试中的日志输出保持 print，因为测试环境需要直接输出
            print("加载第 \(loadCount) 次 - 当前页: \(dataLoader.currentPage), 项目数: \(dataLoader.items.count), hasNextPage: \(dataLoader.hasNextPage)")
        }
        
        // 验证最终状态
        XCTAssertFalse(dataLoader.hasNextPage, "最后应该没有下一页")
        XCTAssertEqual(dataLoader.items.count, dataLoader.totalItems, "最终项目数应该等于总数据量")
        XCTAssertLessThan(loadCount, maxLoads, "不应该触发无限循环保护")
    }
    
    func testSingletonBehavior() {
        // 测试单例模式是否按pageSize正确工作
        let loader1 = TestDataLoader.getInstance(pageSize: 10)
        let loader2 = TestDataLoader.getInstance(pageSize: 10)
        let loader3 = TestDataLoader.getInstance(pageSize: 20)
        
        // 相同pageSize应该返回同一个实例
        XCTAssertTrue(loader1 === loader2, "相同pageSize应该返回同一个实例")
        
        // 不同pageSize应该返回不同实例
        XCTAssertFalse(loader1 === loader3, "不同pageSize应该返回不同实例")
    }
    
    func testPageSizeCalculation() {
        let testCases = [
            (totalItems: 100, pageSize: 10, expectedPages: 10),
            (totalItems: 101, pageSize: 10, expectedPages: 11),
            (totalItems: 99, pageSize: 10, expectedPages: 10),
            (totalItems: 500, pageSize: 20, expectedPages: 25),
            (totalItems: 500, pageSize: 50, expectedPages: 10),
        ]
        
        for (totalItems, pageSize, expectedPages) in testCases {
            let calculatedPages = (totalItems + pageSize - 1) / pageSize
            XCTAssertEqual(calculatedPages, expectedPages, 
                          "totalItems: \(totalItems), pageSize: \(pageSize) 应该得到 \(expectedPages) 页，实际得到 \(calculatedPages) 页")
        }
    }
    
    func testHasNextPageLogic() async {
        let dataLoader = TestDataLoader(pageSize: 10)
        dataLoader.loadInitialData()
        try? await Task.sleep(nanoseconds: 600_000_000)
        
        let totalPages = dataLoader.totalPages
        
        // 测试hasNextPage逻辑
        for page in 0..<totalPages {
            let expectedHasNext = page < totalPages - 1
            
            // 模拟设置当前页
            dataLoader.loadPage(page)
            try? await Task.sleep(nanoseconds: 600_000_000)
            
            XCTAssertEqual(dataLoader.hasNextPage, expectedHasNext, 
                          "页面 \(page)/\(totalPages-1) 的hasNextPage应该是 \(expectedHasNext)")
        }
    }
    
    func testLoadingState() async {
        let dataLoader = TestDataLoader(pageSize: 10)
        
        // 开始加载
        dataLoader.loadInitialData()
        
        // 立即检查加载状态（在延迟之前）
        XCTAssertTrue(dataLoader.isLoading, "开始加载时isLoading应该为true")
        
        // 等待加载完成
        try? await Task.sleep(nanoseconds: 600_000_000)
        
        // 检查加载完成状态
        XCTAssertFalse(dataLoader.isLoading, "加载完成后isLoading应该为false")
    }
    
    func testPreventDuplicateLoading() async {
        let dataLoader = TestDataLoader(pageSize: 10)
        
        dataLoader.loadInitialData()
        
        // 在加载过程中尝试再次加载
        dataLoader.loadNextPage()
        
        // 等待加载完成
        try? await Task.sleep(nanoseconds: 600_000_000)
        
        // 应该只有第一页的数据，因为第二次加载应该被阻止
        XCTAssertEqual(dataLoader.items.count, 10, "重复加载应该被阻止")
        XCTAssertEqual(dataLoader.currentPage, 0, "应该还在第一页")
    }
}
