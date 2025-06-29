//
// Copyright (c) Beyoug
//

import SwiftUI
import SwiftUIMasonryLayouts

// MARK: - 业务集成示例：展示如何在业务层实现复杂功能

/// 展示如何使用纯粹的布局组件实现业务功能
@available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *)
public struct BusinessIntegrationExamples: View {
    
    public init() {}
    
    public var body: some View {
        NavigationView {
            List {
                NavigationLink("分页加载示例") {
                    PaginationBusinessExample()
                }
                
                NavigationLink("下拉刷新示例") {
                    RefreshBusinessExample()
                }
                
                NavigationLink("搜索过滤示例") {
                    SearchBusinessExample()
                }
                
                NavigationLink("状态管理示例") {
                    StateManagementExample()
                }
                
                NavigationLink("性能监控示例") {
                    PerformanceMonitoringExample()
                }

                NavigationLink("水平布局滚动示例") {
                    HorizontalScrollExample()
                }
            }
            .navigationTitle("业务层示例")
        }
    }
}

// MARK: - 分页加载业务示例

@available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *)
private struct PaginationBusinessExample: View {
    @StateObject private var viewModel = PaginationViewModel()
    
    var body: some View {
        VStack {
            // 使用纯粹的布局组件
            LazyMasonryView(
                viewModel.items,
                columns: 2,
                spacing: 8
            ) { item in
                PhotoCard(item: item)
            }
            .onReachBottom {
                // 业务层处理分页逻辑
                Task {
                    await viewModel.loadMoreItems()
                }
            }
            .onVisibleRangeChanged { range in
                // 业务层可以监控可见范围，用于分析等
                viewModel.updateVisibleRange(range)
            }
            
            // 业务层的加载指示器
            if viewModel.isLoading {
                HStack {
                    ProgressView()
                    Text("加载更多...")
                }
                .padding()
            }
        }
        .navigationTitle("分页加载")
        .task {
            await viewModel.loadInitialData()
        }
    }
}

// MARK: - 下拉刷新业务示例

@available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *)
private struct RefreshBusinessExample: View {
    @StateObject private var viewModel = RefreshViewModel()
    
    var body: some View {
        LazyMasonryView(
            viewModel.items,
            columns: 2,
            spacing: 8
        ) { item in
            PhotoCard(item: item)
        }
        .onReachTop {
            // 业务层处理刷新逻辑
            Task {
                await viewModel.refreshData()
            }
        }
        .refreshable {
            // 使用SwiftUI原生的下拉刷新
            await viewModel.refreshData()
        }
        .navigationTitle("下拉刷新")
        .task {
            await viewModel.loadInitialData()
        }
    }
}

// MARK: - 搜索过滤业务示例

@available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *)
private struct SearchBusinessExample: View {
    @StateObject private var viewModel = SearchViewModel()
    
    var body: some View {
        VStack {
            // 业务层的搜索栏
            SearchBar(text: $viewModel.searchText)
            
            // 纯粹的布局组件
            LazyMasonryView(
                viewModel.filteredItems,
                columns: 2,
                spacing: 8
            ) { item in
                PhotoCard(item: item)
                    .transition(.scale.combined(with: .opacity))
            }
            .animation(.easeInOut(duration: 0.3), value: viewModel.filteredItems.count)
        }
        .navigationTitle("搜索过滤")
        .task {
            await viewModel.loadData()
        }
    }
}

// MARK: - 状态管理业务示例

@available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *)
private struct StateManagementExample: View {
    @StateObject private var viewModel = StateManagementViewModel()
    
    var body: some View {
        Group {
            switch viewModel.state {
            case .loading:
                ProgressView("加载中...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                
            case .loaded(let items):
                LazyMasonryView(
                    items,
                    columns: 2,
                    spacing: 8
                ) { item in
                    PhotoCard(item: item)
                }
                
            case .error(let message):
                VStack(spacing: 16) {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.largeTitle)
                        .foregroundColor(.orange)
                    
                    Text(message)
                        .multilineTextAlignment(.center)
                    
                    Button("重试") {
                        Task {
                            await viewModel.loadData()
                        }
                    }
                    .buttonStyle(.bordered)
                }
                .padding()
                
            case .empty:
                VStack(spacing: 16) {
                    Image(systemName: "photo.on.rectangle")
                        .font(.largeTitle)
                        .foregroundColor(.gray)
                    
                    Text("暂无内容")
                    
                    Button("刷新") {
                        Task {
                            await viewModel.loadData()
                        }
                    }
                    .buttonStyle(.bordered)
                }
                .padding()
            }
        }
        .navigationTitle("状态管理")
        .task {
            await viewModel.loadData()
        }
    }
}

// MARK: - 性能监控业务示例

@available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *)
private struct PerformanceMonitoringExample: View {
    @StateObject private var viewModel = PerformanceViewModel()
    @State private var showMetrics = false
    
    var body: some View {
        VStack {
            LazyMasonryView(
                viewModel.items,
                columns: 2,
                spacing: 8
            ) { item in
                PhotoCard(item: item)
            }
            .onVisibleRangeChanged { range in
                viewModel.trackVisibleRange(range)
            }
            
            // 性能指标显示
            if showMetrics {
                VStack(alignment: .leading, spacing: 4) {
                    Text("性能指标")
                        .font(.headline)
                    Text("可见项目: \(viewModel.visibleItemCount)")
                    Text("渲染时间: \(viewModel.renderTime, specifier: "%.2f")ms")
                    Text("内存使用: \(viewModel.memoryUsage, specifier: "%.1f")MB")
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(8)
                .padding()
            }
        }
        .navigationTitle("性能监控")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button(showMetrics ? "隐藏指标" : "显示指标") {
                    showMetrics.toggle()
                }
            }
        }
        .task {
            await viewModel.loadData()
        }
    }
}

// MARK: - 业务层ViewModels

@available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *)
@MainActor
private class PaginationViewModel: ObservableObject {
    @Published var items: [PhotoItem] = []
    @Published var isLoading = false
    
    private var currentPage = 1
    private var hasMoreData = true
    
    func loadInitialData() async {
        items = PhotoItem.generateItems(count: 20)
    }
    
    func loadMoreItems() async {
        guard !isLoading && hasMoreData else { return }
        
        isLoading = true
        
        // 模拟网络延迟
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        
        let newItems = PhotoItem.generateItems(count: 10)
        items.append(contentsOf: newItems)
        currentPage += 1
        
        // 模拟数据耗尽
        if currentPage > 5 {
            hasMoreData = false
        }
        
        isLoading = false
    }
    
    func updateVisibleRange<T>(_ range: Range<T>) where T: Strideable, T.Stride: SignedInteger {
        // 业务层可以在这里进行分析统计
        print("可见范围更新: \(range)")
    }
}

@available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *)
@MainActor
private class RefreshViewModel: ObservableObject {
    @Published var items: [PhotoItem] = []
    
    func loadInitialData() async {
        items = PhotoItem.generateItems(count: 15)
    }
    
    func refreshData() async {
        // 模拟刷新延迟
        try? await Task.sleep(nanoseconds: 1_500_000_000)
        
        items = PhotoItem.generateItems(count: Int.random(in: 10...25))
    }
}

@available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *)
@MainActor
private class SearchViewModel: ObservableObject {
    @Published var searchText = ""
    @Published private var allItems: [PhotoItem] = []

    var filteredItems: [PhotoItem] {
        if searchText.isEmpty {
            return allItems
        } else {
            return allItems.filter { $0.title.localizedCaseInsensitiveContains(searchText) }
        }
    }

    func loadData() async {
        allItems = PhotoItem.generateItems(count: 50)
    }
}

@available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *)
@MainActor
private class StateManagementViewModel: ObservableObject {
    @Published var state: LoadingState = .loading

    enum LoadingState {
        case loading
        case loaded([PhotoItem])
        case error(String)
        case empty
    }

    func loadData() async {
        state = .loading

        // 模拟网络请求
        try? await Task.sleep(nanoseconds: 2_000_000_000)

        // 模拟不同的结果
        let random = Int.random(in: 1...10)
        switch random {
        case 1...2:
            state = .error("网络连接失败")
        case 3:
            state = .empty
        default:
            let items = PhotoItem.generateItems(count: Int.random(in: 15...30))
            state = .loaded(items)
        }
    }
}

@available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *)
@MainActor
private class PerformanceViewModel: ObservableObject {
    @Published var items: [PhotoItem] = []
    @Published var visibleItemCount = 0
    @Published var renderTime: Double = 0
    @Published var memoryUsage: Double = 0

    func loadData() async {
        let startTime = CFAbsoluteTimeGetCurrent()
        items = PhotoItem.generateItems(count: 100)
        let endTime = CFAbsoluteTimeGetCurrent()
        renderTime = (endTime - startTime) * 1000
        updateMemoryUsage()
    }

    func trackVisibleRange<T>(_ range: Range<T>) where T: Strideable, T.Stride: SignedInteger {
        visibleItemCount = range.count
    }

    private func updateMemoryUsage() {
        var info = mach_task_basic_info()
        var count = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info>.size)/4

        let kerr: kern_return_t = withUnsafeMutablePointer(to: &info) {
            $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                task_info(mach_task_self_,
                         task_flavor_t(MACH_TASK_BASIC_INFO),
                         $0,
                         &count)
            }
        }

        if kerr == KERN_SUCCESS {
            memoryUsage = Double(info.resident_size) / 1024 / 1024
        }
    }
}

// MARK: - 辅助组件

@available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *)
private struct SearchBar: View {
    @Binding var text: String

    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)

            TextField("搜索...", text: $text)
                .textFieldStyle(RoundedBorderTextFieldStyle())
        }
        .padding(.horizontal)
    }
}

// MARK: - 示例数据模型

@available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *)
private struct PhotoItem: Identifiable {
    let id = UUID()
    let title: String
    let height: CGFloat
    let color: Color

    static func generateItems(count: Int) -> [PhotoItem] {
        (0..<count).map { index in
            PhotoItem(
                title: "照片 \(index + 1)",
                height: CGFloat.random(in: 120...280),
                color: Color.randomColor
            )
        }
    }
}

@available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *)
private struct PhotoCard: View {
    let item: PhotoItem

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Rectangle()
                .fill(item.color.gradient)
                .frame(height: item.height)
                .cornerRadius(8)

            Text(item.title)
                .font(.caption)
                .fontWeight(.medium)
                .padding(.horizontal, 8)
                .padding(.bottom, 8)
        }
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
}

private extension Color {
    static var randomColor: Color {
        Color(
            red: .random(in: 0.3...0.9),
            green: .random(in: 0.3...0.9),
            blue: .random(in: 0.3...0.9)
        )
    }
}

// MARK: - 水平布局滚动示例

@available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *)
private struct HorizontalScrollExample: View {
    @StateObject private var viewModel = HorizontalScrollViewModel()

    var body: some View {
        VStack(spacing: 16) {
            // 状态指示器
            HStack {
                Text("状态: \(viewModel.statusMessage)")
                    .foregroundColor(.secondary)
                Spacer()
                Text("项目数: \(viewModel.items.count)")
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal)

            // 水平瀑布流
            LazyMasonryView(
                viewModel.items,
                configuration: .twoRows // 水平布局，2行
            ) { item in
                RoundedRectangle(cornerRadius: 8)
                    .fill(item.color.gradient)
                    .frame(width: item.width, height: 80)
                    .overlay(
                        Text("\(item.id)")
                            .font(.caption)
                            .foregroundColor(.white)
                    )
            }
            .onReachStart {
                viewModel.handleReachStart()
            }
            .onReachEnd {
                viewModel.handleReachEnd()
            }
            .onVisibleRangeChanged { range in
                viewModel.updateVisibleRange(range)
            }
        }
        .navigationTitle("水平布局滚动")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            viewModel.loadInitialData()
        }
    }
}

@available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *)
private class HorizontalScrollViewModel: ObservableObject {
    @Published var items: [ColorItem] = []
    @Published var statusMessage: String = "准备就绪"
    @Published var isLoading: Bool = false

    private var currentPage = 0
    private let itemsPerPage = 10

    func loadInitialData() {
        items = generateItems(page: 0)
        currentPage = 0
        statusMessage = "已加载初始数据"
    }

    func handleReachStart() {
        statusMessage = "到达起始位置（左边）"
        // 在水平布局中，这对应到达最左边
        // 可以在这里实现刷新逻辑
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.statusMessage = "准备就绪"
        }
    }

    func handleReachEnd() {
        guard !isLoading else { return }

        statusMessage = "到达结束位置（右边），加载更多..."
        isLoading = true

        // 模拟网络请求
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.currentPage += 1
            let newItems = self.generateItems(page: self.currentPage)
            self.items.append(contentsOf: newItems)
            self.isLoading = false
            self.statusMessage = "已加载第 \(self.currentPage + 1) 页"

            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                self.statusMessage = "准备就绪"
            }
        }
    }

    func updateVisibleRange(_ range: Range<Array<ColorItem>.Index>) {
        // 可以在这里实现可见范围变化的逻辑
        print("可见范围: \(range)")
    }

    private func generateItems(page: Int) -> [ColorItem] {
        let colors: [Color] = [.red, .blue, .green, .orange, .purple, .pink, .yellow, .cyan]
        let startId = page * itemsPerPage

        return (0..<itemsPerPage).map { index in
            ColorItem(
                id: startId + index,
                color: colors.randomElement() ?? .gray,
                width: CGFloat.random(in: 60...120) // 水平布局中宽度是变化的
            )
        }
    }
}
