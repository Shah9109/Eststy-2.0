import SwiftUI

struct SearchView: View {
    @EnvironmentObject var store: EstlyStore
    @State private var selectedProduct: Product?
    @State private var showingProductDetail = false
    @State private var searchText = ""
    @State private var showingFilters = false
    
    private let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Search Header
                searchHeader
                
                // Category Filters
                categoryFilters
                
                // Search Results
                searchResults
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Text("Search")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingFilters = true
                    }) {
                        Image(systemName: "slider.horizontal.3")
                            .font(.system(size: 18, weight: .medium))
                    }
                }
            }
        }
        .sheet(isPresented: $showingProductDetail) {
            if let product = selectedProduct {
                ProductDetailView(product: product)
                    .environmentObject(store)
            }
        }
        .sheet(isPresented: $showingFilters) {
            FilterView()
                .environmentObject(store)
        }
        .onAppear {
            searchText = store.searchText
        }
        .onChange(of: searchText) { newValue in
            store.searchProducts(newValue)
        }
    }
    
    // MARK: - Search Header
    private var searchHeader: some View {
        VStack(spacing: 16) {
            LiquidSearchBarView(searchText: $searchText)
            
            if !searchText.isEmpty || store.selectedCategory != nil {
                HStack {
                    if !searchText.isEmpty {
                        Text("Results for \"\(searchText)\"")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.primary)
                    }
                    
                    if let category = store.selectedCategory {
                        Text("in \(category.rawValue)")
                            .font(.system(size: 16))
                            .foregroundColor(.gray)
                    }
                    
                    Spacer()
                    
                    Button("Clear") {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            searchText = ""
                            store.clearFilters()
                        }
                    }
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.blue)
                }
                .transition(.opacity.combined(with: .scale))
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
    
    // MARK: - Category Filters
    private var categoryFilters: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                // All Categories Chip
                LiquidCategoryChipView(
                    category: ProductCategory.jewelry, // Dummy category for "All"
                    isSelected: store.selectedCategory == nil
                ) {
                    store.filterByCategory(nil)
                }
                .overlay(
                    Text("All")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(store.selectedCategory == nil ? .white : .primary)
                )
                
                ForEach(ProductCategory.allCases) { category in
                    LiquidCategoryChipView(
                        category: category,
                        isSelected: store.selectedCategory == category
                    ) {
                        if store.selectedCategory == category {
                            store.filterByCategory(nil)
                        } else {
                            store.filterByCategory(category)
                        }
                    }
                }
            }
            .padding(.horizontal, 16)
        }
        .padding(.bottom, 16)
    }
    
    // MARK: - Search Results
    private var searchResults: some View {
        ScrollView {
            LazyVStack(spacing: 20) {
                if store.filteredProducts.isEmpty {
                    // Empty State
                    LiquidEmptyStateView(
                        title: searchText.isEmpty ? "Start Searching" : "No Results Found",
                        message: searchText.isEmpty ? "Search for handcrafted items you love" : "Try adjusting your search or filters",
                        systemImage: searchText.isEmpty ? "magnifyingglass" : "exclamationmark.magnifyingglass",
                        actionTitle: searchText.isEmpty ? nil : "Clear Filters",
                        action: searchText.isEmpty ? nil : {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                searchText = ""
                                store.clearFilters()
                            }
                        }
                    )
                    .padding(.top, 60)
                } else {
                    // Results Header
                    HStack {
                        Text("\(store.filteredProducts.count) \(store.filteredProducts.count == 1 ? "item" : "items") found")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        Button("Sort") {
                            // Implement sorting
                        }
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.blue)
                    }
                    .padding(.horizontal, 16)
                    
                    // Products Grid
                    LazyVGrid(columns: columns, spacing: 16) {
                        ForEach(store.filteredProducts) { product in
                            ProductCardView(product: product)
                                .environmentObject(store)
                                .onTapGesture {
                                    selectedProduct = product
                                    showingProductDetail = true
                                }
                                .transition(.opacity.combined(with: .scale))
                        }
                    }
                    .padding(.horizontal, 16)
                    .animation(.easeInOut(duration: 0.3), value: store.filteredProducts.count)
                }
            }
        }
    }
}

// MARK: - Filter View
struct FilterView: View {
    @EnvironmentObject var store: EstlyStore
    @Environment(\.dismiss) private var dismiss
    @State private var tempPriceRange = 0.0...1000.0
    @State private var tempSelectedCategory: ProductCategory?
    @State private var tempSortOption = SortOption.relevance
    
    enum SortOption: String, CaseIterable {
        case relevance = "Relevance"
        case priceLowToHigh = "Price: Low to High"
        case priceHighToLow = "Price: High to Low"
        case rating = "Customer Rating"
        case newest = "Newest"
    }
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 24) {
                // Price Range
                VStack(alignment: .leading, spacing: 12) {
                    Text("Price Range")
                        .font(.system(size: 18, weight: .semibold))
                    
                    VStack(spacing: 8) {
                        HStack {
                            Text("$\(Int(tempPriceRange.lowerBound))")
                                .font(.system(size: 14, weight: .medium))
                            
                            Spacer()
                            
                            Text("$\(Int(tempPriceRange.upperBound))")
                                .font(.system(size: 14, weight: .medium))
                        }
                        
                        RangeSlider(range: $tempPriceRange, bounds: 0...1000)
                    }
                }
                
                // Category
                VStack(alignment: .leading, spacing: 12) {
                    Text("Category")
                        .font(.system(size: 18, weight: .semibold))
                    
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 12) {
                        ForEach(ProductCategory.allCases) { category in
                            LiquidCategoryChipView(
                                category: category,
                                isSelected: tempSelectedCategory == category
                            ) {
                                tempSelectedCategory = tempSelectedCategory == category ? nil : category
                            }
                        }
                    }
                }
                
                // Sort By
                VStack(alignment: .leading, spacing: 12) {
                    Text("Sort By")
                        .font(.system(size: 18, weight: .semibold))
                    
                    VStack(spacing: 8) {
                        ForEach(SortOption.allCases, id: \.self) { option in
                            HStack {
                                Text(option.rawValue)
                                    .font(.system(size: 16))
                                
                                Spacer()
                                
                                Image(systemName: tempSortOption == option ? "checkmark.circle.fill" : "circle")
                                    .foregroundColor(tempSortOption == option ? .blue : .gray)
                            }
                            .contentShape(Rectangle())
                            .onTapGesture {
                                tempSortOption = option
                            }
                        }
                    }
                }
                
                Spacer()
                
                // Apply Filters Button
                VStack(spacing: 12) {
                    // RoundedButton(
                    //     title: "Apply Filters",
                    //     action: {
                    //         applyFilters()
                    //         dismiss()
                    //     },
                    //     style: .primary,
                    //     size: .large
                    // )
                    
                    // RoundedButton(
                    //     title: "Clear All",
                    //     action: {
                    //         clearFilters()
                    //     },
                    //     style: .secondary,
                    //     size: .medium
                    // )
                }
            }
            .padding(.horizontal, 20)
            .navigationTitle("Filters")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
        .onAppear {
            tempSelectedCategory = store.selectedCategory
        }
    }
    
    private func applyFilters() {
        store.filterByCategory(tempSelectedCategory)
        // Apply other filters here
    }
    
    private func clearFilters() {
        tempPriceRange = 0.0...1000.0
        tempSelectedCategory = nil
        tempSortOption = .relevance
        store.clearFilters()
    }
}

// MARK: - Range Slider (Simplified)
struct RangeSlider: View {
    @Binding var range: ClosedRange<Double>
    let bounds: ClosedRange<Double>
    
    var body: some View {
        // Simplified range slider - in production, use a proper range slider component
        HStack {
            Slider(value: Binding(
                get: { range.lowerBound },
                set: { range = $0...range.upperBound }
            ), in: bounds)
            
            Slider(value: Binding(
                get: { range.upperBound },
                set: { range = range.lowerBound...$0 }
            ), in: bounds)
        }
    }
}

// MARK: - Preview
#Preview {
    SearchView()
        .environmentObject(EstlyStore())
} 