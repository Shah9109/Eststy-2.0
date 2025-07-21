import SwiftUI

struct HomeView: View {
    @EnvironmentObject var store: EstlyStore
    @State private var selectedProduct: Product?
    @State private var showingProductDetail = false
    @State private var showingNotifications = false
    @State private var showingSearch = false
    @State private var isRefreshing = false
    @State private var headerAnimation = false
    @State private var sectionsAnimation = false
    @State private var scrollOffset: CGFloat = 0
    @State private var lastRefreshTime = Date()
    
    private let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]
    
    var body: some View {
        NavigationView {
            RefreshableScrollView(onRefresh: refreshData) {
                LazyVStack(spacing: 24) {
                    // Enhanced Header with Notifications
                    enhancedHeaderSection
                    
                    // Promotional Banner
                    promotionalBannerSection
                    
                    // Quick Actions
                    quickActionsSection
                    
                    // Featured Categories
                    featuredCategoriesSection
                    
                    // New Arrivals
                    newArrivalsSection
                    
                    // Flash Sale / On Sale
                    flashSaleSection
                    
                    // Trending Products
                    trendingSection
                    
                    // Recommended for You
                    recommendedSection
                    
                    // Featured Sellers
                    featuredSellersSection
                    
                    // All Products Grid
                    allProductsSection
                }
                .padding(.horizontal, 16)
                .background(
                    GeometryReader { geometry in
                        Color.clear
                            .preference(key: ScrollOffsetPreferenceKey.self, value: geometry.frame(in: .named("scroll")).minY)
                    }
                )
            }
            .coordinateSpace(name: "scroll")
            .onPreferenceChange(ScrollOffsetPreferenceKey.self) { value in
                scrollOffset = value
            }
            .navigationBarHidden(true)
            .sheet(item: $selectedProduct) { product in
                ProductDetailView(product: product)
                    .environmentObject(store)
            }
            .sheet(isPresented: $showingNotifications) {
                NotificationsView()
                    .environmentObject(store)
            }
            .sheet(isPresented: $showingSearch) {
                SearchView()
                    .environmentObject(store)
            }
            .onAppear {
                withAnimation(.liquid(duration: 1.0)) {
                    headerAnimation = true
                }
                withAnimation(.liquid(duration: 1.2).delay(0.3)) {
                    sectionsAnimation = true
                }
            }
        }
    }
    
    // MARK: - Enhanced Header Section
    private var enhancedHeaderSection: some View {
        VStack(spacing: 16) {
            // Top Navigation Bar
            HStack {
                // App Logo with Animation
                HStack(spacing: 8) {
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [.purple, .blue],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 36, height: 36)
                            .scaleEffect(headerAnimation ? 1.0 : 0.8)
                        
                        Image(systemName: "sparkles")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.white)
                            .scaleEffect(headerAnimation ? 1.0 : 0.8)
                    }
                    
                    Text("Estly")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.purple, .blue],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .opacity(headerAnimation ? 1.0 : 0.0)
                        .offset(x: headerAnimation ? 0 : -20)
                }
                .animation(.liquid(duration: 0.8), value: headerAnimation)
                
                Spacer()
                
                // Action Buttons
                HStack(spacing: 12) {
                    // Search Button
                    Button(action: {
                        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                        impactFeedback.impactOccurred()
                        showingSearch = true
                    }) {
                        ZStack {
                            Circle()
                                .fill(.ultraThinMaterial)
                                .frame(width: 40, height: 40)
                                .liquidShadow()
                            
                            Image(systemName: "magnifyingglass")
                                .font(.system(size: 18, weight: .medium))
                                .foregroundColor(.primary)
                        }
                    }
                    
                    // Notifications Button
                    Button(action: {
                        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                        impactFeedback.impactOccurred()
                        showingNotifications = true
                    }) {
                        ZStack {
                            Circle()
                                .fill(.ultraThinMaterial)
                                .frame(width: 40, height: 40)
                                .liquidShadow()
                            
                            Image(systemName: "bell")
                                .font(.system(size: 18, weight: .medium))
                                .foregroundColor(.primary)
                            
                            // Notification Badge
                            if store.unreadNotificationCount > 0 {
                                LiquidCartBadgeView(count: store.unreadNotificationCount)
                                    .offset(x: 12, y: -12)
                            }
                        }
                    }
                    
                    // Cart Button
                    NavigationLink(destination: CartView().environmentObject(store)) {
                        ZStack {
                            Circle()
                                .fill(.ultraThinMaterial)
                                .frame(width: 40, height: 40)
                                .liquidShadow()
                            
                            Image(systemName: "bag")
                                .font(.system(size: 18, weight: .medium))
                                .foregroundColor(.primary)
                            
                            // Cart Badge
                            if store.cartItemCount > 0 {
                                LiquidCartBadgeView(count: store.cartItemCount)
                                    .offset(x: 12, y: -12)
                            }
                        }
                    }
                }
                .opacity(headerAnimation ? 1.0 : 0.0)
                .offset(x: headerAnimation ? 0 : 30)
                .animation(.liquid(duration: 0.8).delay(0.2), value: headerAnimation)
            }
            
            // Welcome Message
            if let user = store.currentUser {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Welcome back,")
                            .font(.system(size: 16, design: .rounded))
                            .foregroundColor(.secondary)
                        
                        Text(user.name)
                            .font(.system(size: 20, weight: .semibold, design: .rounded))
                            .foregroundColor(.primary)
                    }
                    
                    Spacer()
                    
                    // Membership Badge
                    HStack(spacing: 4) {
                        Image(systemName: "crown.fill")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(.yellow)
                        
                        Text(user.membershipTier.rawValue)
                            .font(.caption.weight(.semibold))
                            .foregroundColor(.primary)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(.yellow.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                }
                .opacity(headerAnimation ? 1.0 : 0.0)
                .offset(y: headerAnimation ? 0 : 20)
                .animation(.liquid(duration: 0.8).delay(0.4), value: headerAnimation)
            } else {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Discover Amazing")
                        .font(.system(size: 20, weight: .semibold, design: .rounded))
                        .foregroundColor(.primary)
                    
                    Text("Handcrafted treasures from talented artisans")
                        .font(.system(size: 16, design: .rounded))
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .opacity(headerAnimation ? 1.0 : 0.0)
                .offset(y: headerAnimation ? 0 : 20)
                .animation(.liquid(duration: 0.8).delay(0.4), value: headerAnimation)
            }
        }
    }
    
    // MARK: - Promotional Banner Section
    private var promotionalBannerSection: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 16) {
                // Flash Sale Banner
                LiquidPromoBanner(
                    title: "Flash Sale! ⚡",
                    subtitle: "Up to 50% off selected items",
                    colors: [.red, .orange],
                    action: {
                        // Navigate to sale items
                    }
                )
                
                // Free Shipping Banner
                LiquidPromoBanner(
                    title: "Free Shipping 📦",
                    subtitle: "On orders over $75",
                    colors: [.green, .mint],
                    action: {
                        // Show free shipping details
                    }
                )
                
                // New Artisans Banner
                LiquidPromoBanner(
                    title: "New Artisans 🎨",
                    subtitle: "Discover fresh talent",
                    colors: [.purple, .pink],
                    action: {
                        // Navigate to new sellers
                    }
                )
            }
            .padding(.horizontal, 16)
        }
        .padding(.horizontal, -16)
        .opacity(sectionsAnimation ? 1.0 : 0.0)
        .offset(x: sectionsAnimation ? 0 : -50)
        .animation(.liquid(duration: 0.8).delay(0.1), value: sectionsAnimation)
    }
    
    // MARK: - Quick Actions Section
    private var quickActionsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Quick Actions")
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(.primary)
            
            HStack(spacing: 12) {
                QuickActionButton(
                    icon: "heart.fill",
                    title: "Wishlist",
                    subtitle: "\(store.wishlistItems.count) items",
                    colors: [.red, .pink]
                ) {
                    // Navigate to wishlist
                }
                
                QuickActionButton(
                    icon: "clock.fill",
                    title: "Recent",
                    subtitle: "Last viewed",
                    colors: [.blue, .indigo]
                ) {
                    // Show recent items
                }
                
                QuickActionButton(
                    icon: "truck.box.fill",
                    title: "Orders",
                    subtitle: "\(store.orders.count) active",
                    colors: [.green, .mint]
                ) {
                    // Navigate to orders
                }
                
                QuickActionButton(
                    icon: "person.2.fill",
                    title: "Sellers",
                    subtitle: "Browse all",
                    colors: [.purple, .blue]
                ) {
                    // Navigate to sellers
                }
            }
        }
        .opacity(sectionsAnimation ? 1.0 : 0.0)
        .offset(y: sectionsAnimation ? 0 : 30)
        .animation(.liquid(duration: 0.8).delay(0.2), value: sectionsAnimation)
    }
    
    // MARK: - Featured Categories Section
    private var featuredCategoriesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeader(
                title: "Shop by Category",
                subtitle: "Explore handcrafted treasures",
                actionTitle: "View All"
            ) {
                // Navigate to all categories
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(ProductCategory.allCases.prefix(8)) { category in
                        EnhancedCategoryCard(category: category) {
                            store.filterByCategory(category)
                            showingSearch = true
                        }
                    }
                }
                .padding(.horizontal, 16)
            }
            .padding(.horizontal, -16)
        }
        .opacity(sectionsAnimation ? 1.0 : 0.0)
        .offset(y: sectionsAnimation ? 0 : 30)
        .animation(.liquid(duration: 0.8).delay(0.3), value: sectionsAnimation)
    }
    
    // MARK: - New Arrivals Section
    private var newArrivalsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeader(
                title: "New Arrivals",
                subtitle: "Fresh from the workshop",
                actionTitle: "See All"
            ) {
                // Navigate to new arrivals
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(store.getNewArrivals()) { product in
                        EnhancedProductCard(product: product) {
                            selectedProduct = product
                            showingProductDetail = true
                        }
                        .environmentObject(store)
                    }
                }
                .padding(.horizontal, 16)
            }
            .padding(.horizontal, -16)
        }
        .opacity(sectionsAnimation ? 1.0 : 0.0)
        .offset(y: sectionsAnimation ? 0 : 30)
        .animation(.liquid(duration: 0.8).delay(0.4), value: sectionsAnimation)
    }
    
    // MARK: - Flash Sale Section
    private var flashSaleSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeader(
                title: "Flash Sale! ⚡",
                subtitle: "Limited time offers",
                actionTitle: "Shop Now",
                titleColor: .red
            ) {
                // Navigate to sale items
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(store.getProductsOnSale()) { product in
                        EnhancedProductCard(product: product, showSaleBadge: true) {
                            selectedProduct = product
                            showingProductDetail = true
                        }
                        .environmentObject(store)
                    }
                }
                .padding(.horizontal, 16)
            }
            .padding(.horizontal, -16)
        }
        .opacity(sectionsAnimation ? 1.0 : 0.0)
        .offset(y: sectionsAnimation ? 0 : 30)
        .animation(.liquid(duration: 0.8).delay(0.5), value: sectionsAnimation)
    }
    
    // MARK: - Trending Section
    private var trendingSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeader(
                title: "Trending Now 🔥",
                subtitle: "What everyone's buying",
                actionTitle: "Explore"
            ) {
                // Navigate to trending
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(store.getRecommendations(for: .trending, limit: 6)) { product in
                        EnhancedProductCard(product: product, showTrendingBadge: true) {
                            selectedProduct = product
                            showingProductDetail = true
                        }
                        .environmentObject(store)
                    }
                }
                .padding(.horizontal, 16)
            }
            .padding(.horizontal, -16)
        }
        .opacity(sectionsAnimation ? 1.0 : 0.0)
        .offset(y: sectionsAnimation ? 0 : 30)
        .animation(.liquid(duration: 0.8).delay(0.6), value: sectionsAnimation)
    }
    
    // MARK: - Recommended Section
    private var recommendedSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeader(
                title: "Recommended for You",
                subtitle: "Based on your preferences",
                actionTitle: "View All"
            ) {
                // Navigate to recommendations
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(store.getRecommendations(for: .basedOnPurchases, limit: 8)) { product in
                        EnhancedProductCard(product: product) {
                            selectedProduct = product
                            showingProductDetail = true
                        }
                        .environmentObject(store)
                    }
                }
                .padding(.horizontal, 16)
            }
            .padding(.horizontal, -16)
        }
        .opacity(sectionsAnimation ? 1.0 : 0.0)
        .offset(y: sectionsAnimation ? 0 : 30)
        .animation(.liquid(duration: 0.8).delay(0.7), value: sectionsAnimation)
    }
    
    // MARK: - Featured Sellers Section
    private var featuredSellersSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeader(
                title: "Featured Artisans",
                subtitle: "Meet our talented creators",
                actionTitle: "Browse All"
            ) {
                // Navigate to sellers
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(store.sellers) { seller in
                        SellerCard(seller: seller) {
                            // Navigate to seller profile
                        }
                    }
                }
                .padding(.horizontal, 16)
            }
            .padding(.horizontal, -16)
        }
        .opacity(sectionsAnimation ? 1.0 : 0.0)
        .offset(y: sectionsAnimation ? 0 : 30)
        .animation(.liquid(duration: 0.8).delay(0.8), value: sectionsAnimation)
    }
    
    // MARK: - All Products Section
    private var allProductsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeader(
                title: "All Products",
                subtitle: "\(store.products.count) handcrafted items",
                actionTitle: "Filter"
            ) {
                showingSearch = true
            }
            
            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(store.products.prefix(20)) { product in
                    ProductCardView(product: product)
                        .environmentObject(store)
                        .onTapGesture {
                            selectedProduct = product
                            showingProductDetail = true
                        }
                        .liquidTransition()
                }
            }
        }
        .opacity(sectionsAnimation ? 1.0 : 0.0)
        .offset(y: sectionsAnimation ? 0 : 30)
        .animation(.liquid(duration: 0.8).delay(0.9), value: sectionsAnimation)
    }
    
    // MARK: - Refresh Function
    private func refreshData() async {
        isRefreshing = true
        lastRefreshTime = Date()
        
        // Simulate network delay
        try? await Task.sleep(nanoseconds: 1_500_000_000)
        
        // In a real app, refresh data from server
        await MainActor.run {
            withAnimation(.liquid(duration: 0.8)) {
                // Trigger data refresh animations
                store.generateRecommendations()
                isRefreshing = false
            }
        }
    }
}

// MARK: - Enhanced Components

// Promotional Banner Component
struct LiquidPromoBanner: View {
    let title: String
    let subtitle: String
    let colors: [Color]
    let action: () -> Void
    @State private var animateGradient = false
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 8) {
                Text(title)
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                
                Text(subtitle)
                    .font(.system(size: 14, design: .rounded))
                    .foregroundColor(.white.opacity(0.9))
            }
            .frame(width: 200, height: 100)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(16)
            .background(
                LinearGradient(
                    colors: colors,
                    startPoint: animateGradient ? .topLeading : .bottomTrailing,
                    endPoint: animateGradient ? .bottomTrailing : .topLeading
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .liquidShadow(color: colors.first ?? .clear, radius: 12)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 3.0).repeatForever(autoreverses: true)) {
                animateGradient = true
            }
        }
    }
}

// Quick Action Button Component
struct QuickActionButton: View {
    let icon: String
    let title: String
    let subtitle: String
    let colors: [Color]
    let action: () -> Void
    @State private var isPressed = false
    
    var body: some View {
        Button(action: {
            let impactFeedback = UIImpactFeedbackGenerator(style: .light)
            impactFeedback.impactOccurred()
            
            withAnimation(.liquid(duration: 0.3)) {
                isPressed = true
            }
            
            action()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.liquid(duration: 0.3)) {
                    isPressed = false
                }
            }
        }) {
            VStack(spacing: 8) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: colors,
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 40, height: 40)
                    
                    Image(systemName: icon)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                }
                
                VStack(spacing: 2) {
                    Text(title)
                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                        .foregroundColor(.primary)
                    
                    Text(subtitle)
                        .font(.system(size: 10, design: .rounded))
                        .foregroundColor(.secondary)
                }
                .lineLimit(1)
            }
            .frame(maxWidth: .infinity)
        }
        .scaleEffect(isPressed ? 0.95 : 1.0)
        .animation(.liquid(duration: 0.3), value: isPressed)
    }
}

// Section Header Component
struct SectionHeader: View {
    let title: String
    let subtitle: String
    let actionTitle: String
    var titleColor: Color = .primary
    let action: () -> Void
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(titleColor)
                
                Text(subtitle)
                    .font(.system(size: 14, design: .rounded))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Button(action: action) {
                HStack(spacing: 4) {
                    Text(actionTitle)
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                    
                    Image(systemName: "arrow.right")
                        .font(.system(size: 12, weight: .semibold))
                }
                .foregroundColor(.blue)
            }
        }
    }
}

// Enhanced Category Card Component
struct EnhancedCategoryCard: View {
    let category: ProductCategory
    let action: () -> Void
    @State private var isPressed = false
    @State private var hoverEffect = false
    
    var body: some View {
        Button(action: {
            let impactFeedback = UIImpactFeedbackGenerator(style: .light)
            impactFeedback.impactOccurred()
            
            withAnimation(.liquid(duration: 0.4)) {
                isPressed = true
            }
            
            action()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                withAnimation(.liquid(duration: 0.4)) {
                    isPressed = false
                }
            }
        }) {
            VStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(
                            LinearGradient(
                                colors: category.gradient,
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 80, height: 80)
                        .scaleEffect(hoverEffect ? 1.1 : 1.0)
                    
                    Image(systemName: category.systemImage)
                        .font(.system(size: 32, weight: .semibold))
                        .foregroundColor(.white)
                        .scaleEffect(hoverEffect ? 1.1 : 1.0)
                }
                
                Text(category.rawValue)
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundColor(.primary)
                    .lineLimit(1)
            }
            .frame(width: 100)
        }
        .scaleEffect(isPressed ? 0.95 : 1.0)
        .animation(.liquid(duration: 0.4), value: isPressed)
        .animation(.liquid(duration: 0.6), value: hoverEffect)
        .onAppear {
            withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true).delay(Double.random(in: 0...1))) {
                hoverEffect = true
            }
        }
    }
}

// Enhanced Product Card Component for Featured Sections
struct EnhancedProductCard: View {
    let product: Product
    var showSaleBadge: Bool = false
    var showTrendingBadge: Bool = false
    let action: () -> Void
    @EnvironmentObject var store: EstlyStore
    @State private var isPressed = false
    @State private var imageLoaded = false
    
    var body: some View {
        Button(action: {
            withAnimation(.liquid(duration: 0.3)) {
                isPressed = true
            }
            
            action()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.liquid(duration: 0.3)) {
                    isPressed = false
                }
            }
        }) {
            VStack(alignment: .leading, spacing: 12) {
                // Product Image with Badges
                ZStack(alignment: .topTrailing) {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(
                            LinearGradient(
                                colors: [Color.gray.opacity(0.1), Color.gray.opacity(0.05)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 180, height: 200)
                        .overlay {
                            AsyncImage(url: URL(string: product.primaryImageURL)) { image in
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .clipped()
                                    .onAppear {
                                        withAnimation(.liquid(duration: 0.6)) {
                                            imageLoaded = true
                                        }
                                    }
                            } placeholder: {
                                LiquidLoadingView()
                            }
                        }
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                    
                    // Badges
                    VStack(alignment: .trailing, spacing: 8) {
                        if showSaleBadge, let discount = product.discount, discount.isActive {
                            Text("-\(Int(discount.percentage))%")
                                .font(.caption.weight(.bold))
                                .foregroundColor(.white)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(.red.gradient)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                        }
                        
                        if showTrendingBadge {
                            Text("🔥 Trending")
                                .font(.caption.weight(.bold))
                                .foregroundColor(.white)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(.orange.gradient)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                        }
                        
                        // Wishlist Button
                        Button(action: {
                            store.toggleWishlist(product)
                        }) {
                            ZStack {
                                Circle()
                                    .fill(.ultraThinMaterial)
                                    .frame(width: 32, height: 32)
                                
                                Image(systemName: store.isInWishlist(product) ? "heart.fill" : "heart")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(store.isInWishlist(product) ? .red : .gray)
                            }
                        }
                    }
                    .padding(12)
                }
                
                // Product Info
                VStack(alignment: .leading, spacing: 8) {
                    Text(product.name)
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundColor(.primary)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                    
                    HStack(spacing: 6) {
                        EnhancedRatingStarsView(rating: product.rating, size: 12)
                        Text("(\(product.reviewCount))")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    LiquidPriceTagView(product: product)
                    
                    if let seller = store.getSellerForProduct(product) {
                        Text("by \(seller.name)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .frame(width: 180, alignment: .leading)
            }
        }
        .scaleEffect(isPressed ? 0.95 : 1.0)
        .rotation3DEffect(
            .degrees(isPressed ? 3 : 0),
            axis: (x: 1, y: 0, z: 0)
        )
        .animation(.liquid(duration: 0.3), value: isPressed)
    }
}

// Seller Card Component
struct SellerCard: View {
    let seller: Seller
    let action: () -> Void
    @State private var isPressed = false
    
    var body: some View {
        Button(action: {
            withAnimation(.liquid(duration: 0.3)) {
                isPressed = true
            }
            
            action()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.liquid(duration: 0.3)) {
                    isPressed = false
                }
            }
        }) {
            VStack(spacing: 12) {
                // Seller Image
                AsyncImage(url: URL(string: seller.profileImageURL)) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 80, height: 80)
                        .clipShape(Circle())
                } placeholder: {
                    Circle()
                        .fill(.gray.opacity(0.2))
                        .frame(width: 80, height: 80)
                        .overlay {
                            Image(systemName: "person.fill")
                                .font(.system(size: 32))
                                .foregroundColor(.gray.opacity(0.6))
                        }
                }
                
                VStack(spacing: 4) {
                    Text(seller.name)
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundColor(.primary)
                        .lineLimit(1)
                    
                    HStack(spacing: 4) {
                        Image(systemName: seller.isVerified ? "checkmark.seal.fill" : "star.fill")
                            .font(.system(size: 10))
                            .foregroundColor(seller.isVerified ? .blue : .orange)
                        
                        Text("\(seller.averageRating)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Text("\(seller.totalSales) sales")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .frame(width: 120)
            .padding(16)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .liquidShadow()
        }
        .scaleEffect(isPressed ? 0.95 : 1.0)
        .animation(.liquid(duration: 0.3), value: isPressed)
    }
}

// Refreshable Scroll View
struct RefreshableScrollView<Content: View>: View {
    let onRefresh: () async -> Void
    let content: Content
    
    init(onRefresh: @escaping () async -> Void, @ViewBuilder content: () -> Content) {
        self.onRefresh = onRefresh
        self.content = content()
    }
    
    var body: some View {
        ScrollView {
            content
        }
        .refreshable {
            await onRefresh()
        }
    }
}

// MARK: - Scroll Offset Preference Key
struct ScrollOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

// MARK: - Preview
#Preview {
    HomeView()
        .environmentObject(EstlyStore())
} 