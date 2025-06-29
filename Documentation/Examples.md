# 示例集合

## 目录

- [基础示例](#基础示例)
- [懒加载示例](#懒加载示例)
- [响应式布局](#响应式布局)
- [业务集成](#业务集成)
- [高级用法](#高级用法)
- [实际应用案例](#实际应用案例)

---

## 基础示例

### 1. 最简单的瀑布流

```swift
struct BasicExample: View {
    let items = Array(1...20)

    var body: some View {
        ScrollView {
            MasonryView(
                axis: .vertical,
                lines: .fixed(2),
                horizontalSpacing: 8,
                verticalSpacing: 8
            ) {
                ForEach(items, id: \.self) { item in
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.blue.opacity(0.7))
                        .frame(height: CGFloat.random(in: 100...300))
                        .overlay(
                            Text("\(item)")
                                .foregroundColor(.white)
                                .font(.headline)
                        )
                }
            }
            .padding()
        }
        .navigationTitle("基础示例")
    }
}
```

### 2. 水平瀑布流

```swift
struct HorizontalExample: View {
    let items = Array(1...30)

    var body: some View {
        ScrollView(.horizontal) {
            MasonryView(
                axis: .horizontal,
                lines: .fixed(3),
                horizontalSpacing: 8,
                verticalSpacing: 8
            ) {
                ForEach(items, id: \.self) { item in
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.green.opacity(0.7))
                        .frame(width: CGFloat.random(in: 80...200))
                        .overlay(
                            Text("\(item)")
                                .foregroundColor(.white)
                                .font(.caption)
                        )
                }
            }
            .padding()
        }
        .navigationTitle("水平布局")
    }
}
```

### 3. 自适应列数

```swift
struct AdaptiveExample: View {
    let items = Array(1...50)

    var body: some View {
        ScrollView {
            MasonryView(
                axis: .vertical,
                lines: .adaptive(minSize: 120),
                horizontalSpacing: 8,
                verticalSpacing: 8,
                placementMode: .fill
            ) {
                ForEach(items, id: \.self) { item in
                    VStack {
                        Circle()
                            .fill(Color.orange.opacity(0.7))
                            .frame(height: 60)

                        Text("Item \(item)")
                            .font(.caption)
                            .padding(.bottom, 8)
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(12)
                    .shadow(radius: 2)
                }
            }
            .padding()
        }
        .background(Color.gray.opacity(0.1))
        .navigationTitle("自适应列数")
    }
}
```

---

## 懒加载示例

### 1. 基础懒加载

```swift
struct LazyBasicExample: View {
    @State private var photos = PhotoItem.sampleData

    var body: some View {
        LazyMasonryView(
            photos,
            configuration: .columns(2)
        ) { photo in
            AsyncImage(url: photo.imageURL) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .overlay(
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle())
                    )
            }
            .frame(height: photo.estimatedHeight)
            .clipped()
            .cornerRadius(8)
        }
        .padding()
        .navigationTitle("懒加载基础")
    }
}
```

### 2. 带性能优化的懒加载

```swift
struct OptimizedLazyExample: View {
    @State private var photos = PhotoItem.sampleData

    var body: some View {
        LazyMasonryView(
            photos,
            configuration: .columns(2),
            itemSizeCalculator: { photo, lineSize in
                let aspectRatio = photo.width / photo.height
                return CGSize(width: lineSize, height: lineSize / aspectRatio)
            }
        ) { photo in
            PhotoCardView(photo: photo)
        }
        .padding()
        .navigationTitle("性能优化")
    }
}

struct PhotoCardView: View {
    let photo: PhotoItem

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            AsyncImage(url: photo.imageURL) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .overlay(
                        Image(systemName: "photo")
                            .foregroundColor(.gray)
                    )
            }
            .clipped()
            .cornerRadius(8)

            VStack(alignment: .leading, spacing: 4) {
                Text(photo.title)
                    .font(.caption)
                    .fontWeight(.medium)
                    .lineLimit(2)

                Text(photo.author)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 4)
        }
        .background(Color.white)
        .cornerRadius(12)
        .shadow(radius: 1)
    }
}
```

---

## 响应式布局

### 1. 断点响应式

```swift
struct ResponsiveExample: View {
    @State private var items = Array(1...100)

    private let breakpoints: [CGFloat: MasonryConfiguration] = [
        0: MasonryConfiguration(lines: .fixed(1)),      // 小屏：1列
        400: MasonryConfiguration(lines: .fixed(2)),    // 中屏：2列
        600: MasonryConfiguration(lines: .fixed(3)),    // 大屏：3列
        800: MasonryConfiguration(lines: .fixed(4))     // 超大屏：4列
    ]

    var body: some View {
        ScrollView {
            MasonryView(breakpoints: breakpoints) {
                ForEach(items, id: \.self) { item in
                    ResponsiveCard(item: item)
                }
            }
            .padding()
        }
        .navigationTitle("响应式布局")
    }
}

struct ResponsiveCard: View {
    let item: Int

    var body: some View {
        VStack {
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.purple.opacity(0.7))
                .frame(height: CGFloat.random(in: 80...200))
                .overlay(
                    Text("\(item)")
                        .foregroundColor(.white)
                        .font(.title2)
                        .fontWeight(.bold)
                )

            Text("响应式卡片 \(item)")
                .font(.caption)
                .padding(.bottom, 8)
        }
        .background(Color.white)
        .cornerRadius(12)
        .shadow(radius: 2)
    }
}
```

### 2. 自适应响应式

```swift
struct AdaptiveResponsiveExample: View {
    @State private var items = Array(1...80)

    private let adaptiveBreakpoints: [CGFloat: MasonryConfiguration] = [
        0: MasonryConfiguration(lines: .adaptive(minSize: 120)),
        600: MasonryConfiguration(lines: .adaptive(minSize: 150)),
        1000: MasonryConfiguration(lines: .adaptive(minSize: 180))
    ]

    var body: some View {
        ScrollView {
            MasonryView(breakpoints: adaptiveBreakpoints) {
                ForEach(items, id: \.self) { item in
                    AdaptiveCard(item: item)
                }
            }
            .padding()
        }
        .navigationTitle("自适应响应式")
    }
}

struct AdaptiveCard: View {
    let item: Int

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: "star.fill")
                .font(.title)
                .foregroundColor(.yellow)

            Text("项目 \(item)")
                .font(.headline)

            Text("这是一个自适应响应式卡片的示例内容。")
                .font(.caption)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 8)
        }
        .padding()
        .background(Color.blue.opacity(0.1))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.blue.opacity(0.3), lineWidth: 1)
        )
    }
}
```

---

## 业务集成

### 1. 分页加载示例

```swift
struct PaginationExample: View {
    @StateObject private var viewModel = PaginationViewModel()

    var body: some View {
        VStack {
            LazyMasonryView(
                viewModel.items,
                configuration: .columns(2)
            ) { item in
                BusinessCard(item: item)
            }
            .onReachBottom {
                Task {
                    await viewModel.loadMore()
                }
            }
            .padding()

            if viewModel.isLoading {
                HStack {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                    Text("加载更多...")
                        .font(.caption)
                        .foregroundColor(.secondary)
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

@MainActor
class PaginationViewModel: ObservableObject {
    @Published var items: [BusinessItem] = []
    @Published var isLoading = false

    private var currentPage = 0
    private let pageSize = 20

    func loadInitialData() async {
        isLoading = true
        items = generateItems(page: 0)
        currentPage = 0
        isLoading = false
    }

    func loadMore() async {
        guard !isLoading else { return }

        isLoading = true

        // 模拟网络延迟
        try? await Task.sleep(nanoseconds: 1_000_000_000)

        currentPage += 1
        let newItems = generateItems(page: currentPage)
        items.append(contentsOf: newItems)

        isLoading = false
    }

    private func generateItems(page: Int) -> [BusinessItem] {
        let startId = page * pageSize
        return (0..<pageSize).map { index in
            BusinessItem(
                id: startId + index,
                title: "业务项目 \(startId + index)",
                description: "这是第 \(page + 1) 页的第 \(index + 1) 个项目",
                category: BusinessCategory.allCases.randomElement()!
            )
        }
    }
}
```

### 2. 下拉刷新示例

```swift
struct RefreshExample: View {
    @StateObject private var viewModel = RefreshViewModel()

    var body: some View {
        LazyMasonryView(
            viewModel.items,
            configuration: .columns(3)
        ) { item in
            RefreshCard(item: item)
                .transition(.scale.combined(with: .opacity))
        }
        .padding()
        .refreshable {
            await viewModel.refresh()
        }
        .onReachTop {
            // 可选：自定义顶部触发逻辑
            print("到达顶部")
        }
        .navigationTitle("下拉刷新")
        .task {
            await viewModel.loadData()
        }
    }
}

@MainActor
class RefreshViewModel: ObservableObject {
    @Published var items: [RefreshItem] = []

    func loadData() async {
        items = generateItems()
    }

    func refresh() async {
        // 模拟刷新延迟
        try? await Task.sleep(nanoseconds: 1_500_000_000)

        withAnimation(.easeInOut(duration: 0.5)) {
            items = generateItems()
        }
    }

    private func generateItems() -> [RefreshItem] {
        return (1...30).map { index in
            RefreshItem(
                id: index,
                title: "刷新项目 \(index)",
                timestamp: Date(),
                color: Color.random
            )
        }
    }
}
```

### 3. 搜索过滤示例

```swift
struct SearchExample: View {
    @StateObject private var viewModel = SearchViewModel()
    @State private var searchText = ""

    var body: some View {
        VStack {
            SearchBar(text: $searchText)
                .onChange(of: searchText) { _, newValue in
                    viewModel.search(query: newValue)
                }

            if viewModel.filteredItems.isEmpty && !searchText.isEmpty {
                ContentUnavailableView(
                    "无搜索结果",
                    systemImage: "magnifyingglass",
                    description: Text("尝试使用其他关键词搜索")
                )
            } else {
                LazyMasonryView(
                    viewModel.filteredItems,
                    configuration: .adaptive(minSize: 140)
                ) { item in
                    SearchCard(item: item, searchText: searchText)
                }
                .padding()
                .animation(.easeInOut(duration: 0.3), value: viewModel.filteredItems)
            }
        }
        .navigationTitle("搜索过滤")
        .task {
            await viewModel.loadData()
        }
    }
}

struct SearchBar: View {
    @Binding var text: String

    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)

            TextField("搜索...", text: $text)
                .textFieldStyle(RoundedBorderTextFieldStyle())
        }
        .padding()
    }
}
```

---

## 高级用法

### 1. 混合内容类型

```swift
struct MixedContentExample: View {
    @State private var contentItems: [ContentItem] = []

    var body: some View {
        LazyMasonryView(
            contentItems,
            configuration: .columns(2)
        ) { item in
            switch item.type {
            case .text:
                TextContentView(item: item)
            case .image:
                ImageContentView(item: item)
            case .video:
                VideoContentView(item: item)
            case .quote:
                QuoteContentView(item: item)
            }
        }
        .padding()
        .navigationTitle("混合内容")
        .onAppear {
            loadMixedContent()
        }
    }

    private func loadMixedContent() {
        contentItems = ContentItem.mixedSampleData
    }
}

enum ContentType: CaseIterable {
    case text, image, video, quote
}

struct ContentItem: Identifiable {
    let id = UUID()
    let type: ContentType
    let title: String
    let content: String
    let metadata: [String: Any]

    static var mixedSampleData: [ContentItem] {
        return (1...50).map { index in
            let type = ContentType.allCases.randomElement()!
            return ContentItem(
                type: type,
                title: "\(type) 内容 \(index)",
                content: "这是 \(type) 类型的示例内容...",
                metadata: [:]
            )
        }
    }
}
```

### 2. 动态配置切换

```swift
struct DynamicConfigExample: View {
    @State private var items = Array(1...60)
    @State private var currentConfig: MasonryConfiguration = .columns(2)
    @State private var showingConfigSheet = false

    var body: some View {
        VStack {
            LazyMasonryView(
                items,
                configuration: currentConfig
            ) { item in
                DynamicCard(item: item)
            }
            .padding()
            .animation(.easeInOut(duration: 0.5), value: currentConfig)
        }
        .navigationTitle("动态配置")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("配置") {
                    showingConfigSheet = true
                }
            }
        }
        .sheet(isPresented: $showingConfigSheet) {
            ConfigurationSheet(currentConfig: $currentConfig)
        }
    }
}

struct ConfigurationSheet: View {
    @Binding var currentConfig: MasonryConfiguration
    @Environment(\.dismiss) private var dismiss

    private let presetConfigs: [(String, MasonryConfiguration)] = [
        ("单列", .columns(1)),
        ("双列", .columns(2)),
        ("三列", .columns(3)),
        ("四列", .columns(4)),
        ("自适应", .adaptiveColumns)
    ]

    var body: some View {
        NavigationView {
            List {
                ForEach(presetConfigs, id: \.0) { name, config in
                    Button(action: {
                        currentConfig = config
                        dismiss()
                    }) {
                        HStack {
                            Text(name)
                            Spacer()
                            if configsEqual(currentConfig, config) {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                    .foregroundColor(.primary)
                }
            }
            .navigationTitle("选择配置")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("完成") {
                        dismiss()
                    }
                }
            }
        }
    }

    private func configsEqual(_ config1: MasonryConfiguration, _ config2: MasonryConfiguration) -> Bool {
        // 简化的配置比较
        return config1.lines == config2.lines && config1.axis == config2.axis
    }
}
```

---

## 实际应用案例

### 1. 图片画廊应用

```swift
struct PhotoGalleryApp: View {
    @StateObject private var galleryManager = PhotoGalleryManager()
    @State private var selectedPhoto: PhotoItem?

    var body: some View {
        NavigationView {
            LazyMasonryView(
                galleryManager.photos,
                configuration: .adaptive(minSize: 120),
                itemSizeCalculator: { photo, lineSize in
                    let aspectRatio = photo.width / photo.height
                    return CGSize(width: lineSize, height: lineSize / aspectRatio)
                }
            ) { photo in
                PhotoThumbnail(photo: photo) {
                    selectedPhoto = photo
                }
            }
            .padding(8)
            .navigationTitle("照片")
            .onReachBottom {
                Task {
                    await galleryManager.loadMorePhotos()
                }
            }
            .refreshable {
                await galleryManager.refreshPhotos()
            }
            .sheet(item: $selectedPhoto) { photo in
                PhotoDetailView(photo: photo)
            }
        }
    }
}

struct PhotoThumbnail: View {
    let photo: PhotoItem
    let onTap: () -> Void

    var body: some View {
        AsyncImage(url: photo.thumbnailURL) { image in
            image
                .resizable()
                .aspectRatio(contentMode: .fill)
        } placeholder: {
            Rectangle()
                .fill(Color.gray.opacity(0.3))
                .overlay(
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                )
        }
        .clipped()
        .cornerRadius(8)
        .onTapGesture {
            onTap()
        }
    }
}
```

### 2. 商品展示应用

```swift
struct ProductCatalogApp: View {
    @StateObject private var catalogManager = ProductCatalogManager()
    @State private var selectedCategory: ProductCategory = .all

    var body: some View {
        VStack(spacing: 0) {
            CategorySelector(
                selectedCategory: $selectedCategory,
                categories: ProductCategory.allCases
            )
            .onChange(of: selectedCategory) { _, newCategory in
                catalogManager.filterBy(category: newCategory)
            }

            LazyMasonryView(
                catalogManager.filteredProducts,
                configuration: .columns(2)
            ) { product in
                ProductCard(product: product)
            }
            .padding()
        }
        .navigationTitle("商品目录")
        .task {
            await catalogManager.loadProducts()
        }
    }
}

struct ProductCard: View {
    let product: Product

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            AsyncImage(url: product.imageURL) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                Rectangle()
                    .fill(Color.gray.opacity(0.2))
                    .overlay(
                        Image(systemName: "photo")
                            .foregroundColor(.gray)
                    )
            }
            .frame(height: 120)
            .clipped()
            .cornerRadius(8)

            VStack(alignment: .leading, spacing: 4) {
                Text(product.name)
                    .font(.headline)
                    .lineLimit(2)

                Text(product.price, format: .currency(code: "CNY"))
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.green)

                HStack {
                    ForEach(0..<5) { index in
                        Image(systemName: index < product.rating ? "star.fill" : "star")
                            .foregroundColor(.yellow)
                            .font(.caption)
                    }

                    Text("(\(product.reviewCount))")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding(.horizontal, 8)
            .padding(.bottom, 8)
        }
        .background(Color.white)
        .cornerRadius(12)
        .shadow(radius: 2)
    }
}
```

这些示例展示了SwiftUIMasonryLayouts在各种实际场景中的应用，从基础用法到复杂的业务集成，帮助开发者快速上手并应用到实际项目中。