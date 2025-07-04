//
// Copyright (c) Beyoug
//

import SwiftUI
import Foundation

/// 示例数据项模型 - 用于演示瀑布流布局
public struct SampleDataItem: Identifiable, Hashable, Codable, Sendable {
    public let id: Int
    public let title: String
    public let subtitle: String
    public let type: String
    public let imageUrl: String
    public let metadata: [String]

    /// 动态计算卡片高度（基于内容长度）
    public var dynamicHeight: CGFloat {
        let baseHeight: CGFloat = 200
        let titleLength = CGFloat(title.count)
        let subtitleLength = CGFloat(subtitle.count)
        let metadataHeight = CGFloat(metadata.count * 25)

        // 根据内容长度动态调整高度
        let contentHeight = titleLength * 2 + subtitleLength * 0.8 + metadataHeight
        return baseHeight + min(contentHeight, 150) // 限制最大额外高度
    }

    /// 根据类型获取主题色
    public var themeColor: Color {
        switch type {
        case "风景": return Color.green
        case "建筑": return Color.blue
        case "美食": return Color.orange
        case "动物": return Color.brown
        case "户外": return Color.teal
        case "植物": return Color.mint
        case "艺术": return Color.purple
        case "科技": return Color.indigo
        default: return Color.gray
        }
    }

    /// 获取类型图标
    public var typeIcon: String {
        switch type {
        case "风景": return "mountain.2.fill"
        case "建筑": return "building.2.fill"
        case "美食": return "fork.knife"
        case "动物": return "pawprint.fill"
        case "户外": return "figure.hiking"
        case "植物": return "leaf.fill"
        case "艺术": return "paintbrush.fill"
        case "科技": return "laptopcomputer"
        default: return "square.fill"
        }
    }

    /// 公共初始化方法
    public init(id: Int, title: String, subtitle: String, type: String, imageUrl: String, metadata: [String]) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
        self.type = type
        self.imageUrl = imageUrl
        self.metadata = metadata
    }
}

/// 分页响应模型 - 通用分页数据结构
public struct PaginatedResponse<T: Codable>: Codable {
    public let data: [T]
    public let currentPage: Int
    public let totalPages: Int
    public let totalItems: Int
    public let pageSize: Int
    public let hasNextPage: Bool
    public let hasPreviousPage: Bool

    public init(data: [T], currentPage: Int, totalPages: Int, totalItems: Int, pageSize: Int, hasNextPage: Bool, hasPreviousPage: Bool) {
        self.data = data
        self.currentPage = currentPage
        self.totalPages = totalPages
        self.totalItems = totalItems
        self.pageSize = pageSize
        self.hasNextPage = hasNextPage
        self.hasPreviousPage = hasPreviousPage
    }
}

/// 示例数据加载器 - 用于演示分页加载功能
@available(iOS 18.0, *)
@MainActor
public class SampleDataLoader: ObservableObject {

    // 🎯 单例模式，防止重复创建
    public static let shared = SampleDataLoader(pageSize: 10)

    private static var _instances: [Int: SampleDataLoader] = [:]

    /// 获取指定页面大小的实例
    public static func getInstance(pageSize: Int = 10) -> SampleDataLoader {
        // 使用pageSize作为key，确保不同pageSize有不同的实例
        if let existing = _instances[pageSize] {
            MasonryLogger.debug("复用现有 SampleDataLoader 实例 (pageSize: \(pageSize)): \(ObjectIdentifier(existing)), 当前项目数: \(existing.items.count)")
            return existing
        } else {
            let newInstance = SampleDataLoader(pageSize: pageSize)
            _instances[pageSize] = newInstance
            MasonryLogger.debug("创建新的 SampleDataLoader 实例 (pageSize: \(pageSize)): \(ObjectIdentifier(newInstance))")
            return newInstance
        }
    }

    /// 重置所有实例（用于调试）
    public static func resetAllInstances() {
        MasonryLogger.debug("重置所有 SampleDataLoader 实例")
        _instances.removeAll()
    }
    
    // MARK: - 属性
    
    @Published public var items: [SampleDataItem] = []
    @Published public var isLoading = false
    @Published public var currentPage = 0
    @Published public var totalPages = 0
    @Published public var totalItems = 0
    @Published public var hasNextPage = false
    @Published public var error: String?

    private let pageSize: Int
    private var allData: [SampleDataItem] = []
    
    // MARK: - 初始化
    
    public init(pageSize: Int = 20) {
        self.pageSize = pageSize
        MasonryLogger.debug("SampleDataLoader 初始化 - pageSize: \(pageSize), 实例ID: \(ObjectIdentifier(self))")
        loadAllData()
    }
    
    // MARK: - 数据加载
    
    /// 加载所有示例数据
    private func loadAllData() {
        // 使用静态测试数据
        allData = SampleTestData.getAllTestData()
        if !allData.isEmpty {
            totalItems = allData.count
            totalPages = (totalItems + pageSize - 1) / pageSize
            MasonryLogger.info("从静态测试数据加载成功 - totalItems: \(totalItems), pageSize: \(pageSize), totalPages: \(totalPages)")
            return
        }

        // 如果静态数据不可用，生成一些示例数据
        MasonryLogger.warning("静态测试数据不可用，使用生成的示例数据")
        generateSampleData()
    }

    /// 生成示例数据（当无法加载JSON文件时使用）
    private func generateSampleData() {
        let types = ["风景", "建筑", "美食", "动物", "户外", "植物", "艺术", "科技"]

        allData = (1...200).map { id in
            let type = types[id % types.count]

            return SampleDataItem(
                id: id,
                title: "示例项目 \(id)",
                subtitle: "这是第\(id)个示例项目的描述内容，用于演示瀑布流布局效果。",
                type: type,
                imageUrl: "https://picsum.photos/300/\(180 + (id % 120))?random=\(id)",
                metadata: ["标签1", "标签2", "标签3"]
            )
        }

        totalItems = allData.count
        totalPages = (totalItems + pageSize - 1) / pageSize
        MasonryLogger.info("生成示例数据完成 - totalItems: \(totalItems), pageSize: \(pageSize), totalPages: \(totalPages)")
    }
    
    /// 加载第一页数据
    public func loadInitialData() {
        currentPage = 0
        items.removeAll()
        loadPage(0)
    }

    /// 加载下一页数据
    public func loadNextPage() {
        guard hasNextPage && !isLoading else { return }
        loadPage(currentPage + 1)
    }
    
    /// 加载指定页数据
    func loadPage(_ page: Int) {
        guard page >= 0 && page < totalPages else { return }

        isLoading = true
        error = nil

        // 🚀 优化：使用Task处理异步数据，避免并发问题
        Task { @MainActor in
            // 模拟网络延迟
            try? await Task.sleep(nanoseconds: 500_000_000) // 0.5秒

            let startIndex = page * self.pageSize
            let endIndex = min(startIndex + self.pageSize, self.allData.count)
            let pageData = Array(self.allData[startIndex..<endIndex])

            // 🚀 优化：使用动画来平滑数据更新
            withAnimation(.easeInOut(duration: 0.2)) {
                if page == 0 {
                    // 第一页：替换所有数据
                    self.items = pageData
                } else {
                    // 后续页：追加数据
                    self.items.append(contentsOf: pageData)
                }
            }

            // 🚀 优化：延迟更新状态，避免与动画冲突
            try? await Task.sleep(nanoseconds: 100_000_000) // 0.1秒

            self.currentPage = page
            self.hasNextPage = page < self.totalPages - 1
            self.isLoading = false

            MasonryLogger.debug("数据加载完成 - 页面: \(page + 1)/\(self.totalPages), 项目数: \(self.items.count)/\(self.totalItems)")
        }
    }
    
    /// 刷新数据（重新加载第一页）
    public func refresh() {
        loadInitialData()
    }

    /// 搜索数据
    public func search(query: String) {
        guard !query.isEmpty else {
            loadInitialData()
            return
        }
        
        isLoading = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            let filteredData = self.allData.filter { item in
                item.title.localizedCaseInsensitiveContains(query) ||
                item.subtitle.localizedCaseInsensitiveContains(query) ||
                item.type.localizedCaseInsensitiveContains(query) ||
                item.metadata.contains { $0.localizedCaseInsensitiveContains(query) }
            }
            
            self.items = Array(filteredData.prefix(self.pageSize))
            self.currentPage = 0
            self.totalItems = filteredData.count
            self.totalPages = (self.totalItems + self.pageSize - 1) / self.pageSize
            self.hasNextPage = self.totalPages > 1
            self.isLoading = false
        }
    }
    
    /// 按类型筛选
    public func filterByType(_ type: String?) {
        guard let type = type, !type.isEmpty else {
            loadInitialData()
            return
        }

        isLoading = true

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            let filteredData = self.allData.filter { $0.type == type }
            
            self.items = Array(filteredData.prefix(self.pageSize))
            self.currentPage = 0
            self.totalItems = filteredData.count
            self.totalPages = (self.totalItems + self.pageSize - 1) / self.pageSize
            self.hasNextPage = self.totalPages > 1
            self.isLoading = false
        }
    }
    
    /// 获取所有类型
    public func getAllTypes() -> [String] {
        return Array(Set(allData.map { $0.type })).sorted()
    }

    /// 使用边界测试数据（不同长度的subtitle）
    public func loadBoundaryTestData() {
        allData = SampleTestData.getAllTestData()
        totalItems = allData.count
        totalPages = (totalItems + pageSize - 1) / pageSize
        loadInitialData()
        MasonryLogger.info("加载边界测试数据 - totalItems: \(totalItems)")
    }

    /// 使用短文本测试数据
    public func loadShortTextTestData() {
        let testData = SampleTestData.getTestDataBySubtitleLength()
        allData = testData.short
        totalItems = allData.count
        totalPages = (totalItems + pageSize - 1) / pageSize
        loadInitialData()
        MasonryLogger.info("加载短文本测试数据 - totalItems: \(totalItems)")
    }

    /// 使用长文本测试数据
    public func loadLongTextTestData() {
        let testData = SampleTestData.getTestDataBySubtitleLength()
        allData = testData.long
        totalItems = allData.count
        totalPages = (totalItems + pageSize - 1) / pageSize
        loadInitialData()
        MasonryLogger.info("加载长文本测试数据 - totalItems: \(totalItems)")
    }

    /// 使用随机测试数据
    public func loadRandomTestData(count: Int = 50) {
        allData = SampleTestData.getRandomTestData(count: count)
        totalItems = allData.count
        totalPages = (totalItems + pageSize - 1) / pageSize
        loadInitialData()
        MasonryLogger.info("加载随机测试数据 - totalItems: \(totalItems)")
    }
}




