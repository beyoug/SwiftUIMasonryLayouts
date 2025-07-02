//
// Copyright (c) Beyoug
//

import SwiftUI
import Foundation

/// 测试数据项模型
struct TestDataItem: Identifiable, Hashable, Codable {
    let id: Int
    let title: String
    let description: String
    let category: String
    let height: Int
    let color: String
    let tags: [String]
    
    /// 转换为SwiftUI颜色
    var swiftUIColor: Color {
        switch color.lowercased() {
        case "red": return .red
        case "blue": return .blue
        case "green": return .green
        case "yellow": return .yellow
        case "orange": return .orange
        case "purple": return .purple
        case "pink": return .pink
        case "brown": return .brown
        case "gray": return .gray
        case "white": return .white
        case "black": return .black
        case "cyan": return .cyan
        case "magenta": return Color(red: 1, green: 0, blue: 1)
        case "lime": return Color(red: 0, green: 1, blue: 0)
        case "navy": return Color(red: 0, green: 0, blue: 0.5)
        default: return .gray
        }
    }
    
    /// 获取CGFloat高度
    var cgHeight: CGFloat {
        return CGFloat(height)
    }
}

/// 分页响应模型
struct PaginatedResponse<T: Codable>: Codable {
    let data: [T]
    let currentPage: Int
    let totalPages: Int
    let totalItems: Int
    let pageSize: Int
    let hasNextPage: Bool
    let hasPreviousPage: Bool
}

/// 测试数据加载器
@available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *)
@MainActor
class TestDataLoader: ObservableObject {

    // 🎯 单例模式，防止重复创建
    static let shared = TestDataLoader(pageSize: 10)

    private static var _instances: [Int: TestDataLoader] = [:]

    static func getInstance(pageSize: Int = 10) -> TestDataLoader {
        // 使用pageSize作为key，确保不同pageSize有不同的实例
        if let existing = _instances[pageSize] {
            print("🔄 复用现有 TestDataLoader 实例 (pageSize: \(pageSize)): \(ObjectIdentifier(existing)), 当前项目数: \(existing.items.count)")
            return existing
        } else {
            let newInstance = TestDataLoader(pageSize: pageSize)
            _instances[pageSize] = newInstance
            print("🆕 创建新的 TestDataLoader 实例 (pageSize: \(pageSize)): \(ObjectIdentifier(newInstance))")
            return newInstance
        }
    }

    /// 重置所有实例（用于调试）
    static func resetAllInstances() {
        print("🗑️ 重置所有 TestDataLoader 实例")
        _instances.removeAll()
    }
    
    // MARK: - 属性
    
    @Published var items: [TestDataItem] = []
    @Published var isLoading = false
    @Published var currentPage = 0
    @Published var totalPages = 0
    @Published var totalItems = 0
    @Published var hasNextPage = false
    @Published var error: String?
    
    private let pageSize: Int
    private var allData: [TestDataItem] = []
    
    // MARK: - 初始化
    
    init(pageSize: Int = 20) {
        self.pageSize = pageSize
        print("🏗️ TestDataLoader 初始化 - pageSize: \(pageSize), 实例ID: \(ObjectIdentifier(self))")
        loadAllData()
    }
    
    // MARK: - 数据加载
    
    /// 加载所有测试数据
    private func loadAllData() {
        // 尝试从Bundle中加载测试数据文件
        if let url = Bundle.module.url(forResource: "TestData500", withExtension: "json") {
            do {
                let data = try Data(contentsOf: url)
                allData = try JSONDecoder().decode([TestDataItem].self, from: data)
                totalItems = allData.count
                totalPages = (totalItems + pageSize - 1) / pageSize
                print("📁 从JSON加载数据成功 - totalItems: \(totalItems), pageSize: \(pageSize), totalPages: \(totalPages)")
                return
            } catch {
                print("加载JSON文件失败: \(error)")
            }
        }

        // 如果无法加载文件，生成一些示例数据
        generateSampleData()
    }

    /// 生成示例数据（当无法加载JSON文件时使用）
    private func generateSampleData() {
        let categories = ["风景", "建筑", "动物", "美食", "户外", "植物", "艺术", "科技"]
        let colors = ["red", "blue", "green", "yellow", "orange", "purple", "pink", "brown"]

        allData = (1...500).map { id in
            let category = categories[id % categories.count]
            let color = colors[id % colors.count]
            let seed = abs(id.hashValue)
            let height = 80 + (seed % 171)

            return TestDataItem(
                id: id,
                title: "\(category)项目 \(id)",
                description: "这是第\(id)个\(category)项目的描述",
                category: category,
                height: height,
                color: color,
                tags: ["标签1", "标签2", "标签3"]
            )
        }

        totalItems = allData.count
        totalPages = (totalItems + pageSize - 1) / pageSize
        print("🔧 生成示例数据完成 - totalItems: \(totalItems), pageSize: \(pageSize), totalPages: \(totalPages)")
    }
    
    /// 加载第一页数据
    func loadInitialData() {
        currentPage = 0
        items.removeAll()
        loadPage(0)
    }
    
    /// 加载下一页数据
    func loadNextPage() {
        guard hasNextPage && !isLoading else { return }
        loadPage(currentPage + 1)
    }
    
    /// 加载指定页数据
    func loadPage(_ page: Int) {
        guard page >= 0 && page < totalPages else { return }

        isLoading = true
        error = nil

        // 模拟网络延迟
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            let startIndex = page * self.pageSize
            let endIndex = min(startIndex + self.pageSize, self.allData.count)

            let pageData = Array(self.allData[startIndex..<endIndex])

            if page == 0 {
                // 第一页：替换所有数据
                self.items = pageData
            } else {
                // 后续页：追加数据
                self.items.append(contentsOf: pageData)
            }

            self.currentPage = page
            self.hasNextPage = page < self.totalPages - 1
            self.isLoading = false

            print("📊 数据加载完成 - 页面: \(page + 1)/\(self.totalPages), 项目数: \(self.items.count)/\(self.totalItems)")
        }
    }
    
    /// 刷新数据（重新加载第一页）
    func refresh() {
        loadInitialData()
    }
    
    /// 搜索数据
    func search(query: String) {
        guard !query.isEmpty else {
            loadInitialData()
            return
        }
        
        isLoading = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            let filteredData = self.allData.filter { item in
                item.title.localizedCaseInsensitiveContains(query) ||
                item.description.localizedCaseInsensitiveContains(query) ||
                item.category.localizedCaseInsensitiveContains(query) ||
                item.tags.contains { $0.localizedCaseInsensitiveContains(query) }
            }
            
            self.items = Array(filteredData.prefix(self.pageSize))
            self.currentPage = 0
            self.totalItems = filteredData.count
            self.totalPages = (self.totalItems + self.pageSize - 1) / self.pageSize
            self.hasNextPage = self.totalPages > 1
            self.isLoading = false
        }
    }
    
    /// 按分类筛选
    func filterByCategory(_ category: String?) {
        guard let category = category, !category.isEmpty else {
            loadInitialData()
            return
        }
        
        isLoading = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            let filteredData = self.allData.filter { $0.category == category }
            
            self.items = Array(filteredData.prefix(self.pageSize))
            self.currentPage = 0
            self.totalItems = filteredData.count
            self.totalPages = (self.totalItems + self.pageSize - 1) / self.pageSize
            self.hasNextPage = self.totalPages > 1
            self.isLoading = false
        }
    }
    
    /// 获取所有分类
    func getAllCategories() -> [String] {
        return Array(Set(allData.map { $0.category })).sorted()
    }
}




