import Foundation
import SwiftUI

// MARK: - Main Store (ObservableObject)
class EstlyStore: ObservableObject {
    // MARK: - Core Data
    @Published var products: [Product] = []
    @Published var sellers: [Seller] = []
    @Published var cartItems: [CartItem] = []
    @Published var currentUser: User?
    @Published var authUser: AuthUser?
    @Published var orders: [Order] = []
    @Published var wishlistItems: [WishlistItem] = []
    @Published var notifications: [AppNotification] = []
    @Published var searchHistory: [SearchHistory] = []
    @Published var recommendations: [Recommendation] = []
    @Published var reviews: [Review] = []
    @Published var transactions: [Transaction] = []
    @Published var paymentMethods: [PaymentMethod] = []
    @Published var addresses: [Address] = []
    
    // MARK: - UI State
    @Published var favoriteProductIds: Set<UUID> = []
    @Published var searchText: String = ""
    @Published var selectedCategory: ProductCategory? = nil
    @Published var isLoading: Bool = false
    @Published var showingCart: Bool = false
    @Published var isAuthenticated: Bool = false
    @Published var showingNotifications: Bool = false
    @Published var unreadNotificationCount: Int = 0
    @Published var currentTheme: User.UserPreferences.ThemePreference = .system
    @Published var selectedCurrency: String = "USD"
    @Published var isOffline: Bool = false
    @Published var lastSyncDate: Date = Date()
    
    // MARK: - Search and Filter
    @Published var sortOption: SortOption = .featured
    @Published var priceRange: ClosedRange<Double> = 0...1000
    @Published var minRating: Double = 0
    @Published var showOnlyInStock: Bool = false
    @Published var showOnlyWithDiscount: Bool = false
    
    enum SortOption: String, CaseIterable {
        case featured = "Featured"
        case priceLowToHigh = "Price: Low to High"
        case priceHighToLow = "Price: High to Low"
        case rating = "Customer Rating"
        case newest = "Newest"
        case bestSelling = "Best Selling"
        
        var systemImage: String {
            switch self {
            case .featured: return "star.fill"
            case .priceLowToHigh: return "arrow.up"
            case .priceHighToLow: return "arrow.down"
            case .rating: return "star.circle"
            case .newest: return "clock"
            case .bestSelling: return "chart.line.uptrend.xyaxis"
            }
        }
    }
    
    // MARK: - Computed Properties
    var filteredProducts: [Product] {
        var filtered = products
        
        // Search filter
        if !searchText.isEmpty {
            filtered = filtered.filter { product in
                product.name.localizedCaseInsensitiveContains(searchText) ||
                product.description.localizedCaseInsensitiveContains(searchText) ||
                product.detailedDescription.localizedCaseInsensitiveContains(searchText) ||
                product.tags.contains { $0.localizedCaseInsensitiveContains(searchText) } ||
                product.materials.contains { $0.localizedCaseInsensitiveContains(searchText) }
            }
            
            // Save search to history
            saveSearchToHistory(searchText, resultCount: filtered.count)
        }
        
        // Category filter
        if let category = selectedCategory {
            filtered = filtered.filter { $0.category == category }
        }
        
        // Price range filter
        filtered = filtered.filter { 
            let price = $0.discountedPrice ?? $0.price
            return priceRange.contains(price)
        }
        
        // Rating filter
        filtered = filtered.filter { $0.rating >= minRating }
        
        // Stock filter
        if showOnlyInStock {
            filtered = filtered.filter { $0.inventory.isInStock }
        }
        
        // Discount filter
        if showOnlyWithDiscount {
            filtered = filtered.filter { $0.discountedPrice != nil }
        }
        
        // Sort
        return sortProducts(filtered)
    }
    
    private func sortProducts(_ products: [Product]) -> [Product] {
        switch sortOption {
        case .featured:
            return products.sorted { $0.rating * Double($0.reviewCount) > $1.rating * Double($1.reviewCount) }
        case .priceLowToHigh:
            return products.sorted { ($0.discountedPrice ?? $0.price) < ($1.discountedPrice ?? $1.price) }
        case .priceHighToLow:
            return products.sorted { ($0.discountedPrice ?? $0.price) > ($1.discountedPrice ?? $1.price) }
        case .rating:
            return products.sorted { $0.rating > $1.rating }
        case .newest:
            return products.sorted { $0.createdDate > $1.createdDate }
        case .bestSelling:
            return products.sorted { $0.reviewCount > $1.reviewCount }
        }
    }
    
    // Cart properties
    var cartItemCount: Int {
        cartItems.reduce(0) { $0 + $1.quantity }
    }
    
    var cartSubtotal: Double {
        cartItems.reduce(0) { $0 + $1.totalPrice }
    }
    
    var cartShipping: Double {
        // Free shipping over $75
        return cartSubtotal >= 75 ? 0 : 8.99
    }
    
    var cartTax: Double {
        (cartSubtotal + cartShipping) * 0.08875 // NY tax rate
    }
    
    var cartTotal: Double {
        cartSubtotal + cartShipping + cartTax
    }
    
    var formattedCartSubtotal: String {
        String(format: "$%.2f", cartSubtotal)
    }
    
    var formattedCartShipping: String {
        cartShipping == 0 ? "Free" : String(format: "$%.2f", cartShipping)
    }
    
    var formattedCartTax: String {
        String(format: "$%.2f", cartTax)
    }
    
    var formattedCartTotal: String {
        String(format: "$%.2f", cartTotal)
    }
    
    // Wishlist properties
    var wishlistProductIds: Set<UUID> {
        Set(wishlistItems.map { $0.productId })
    }
    
    var wishlistProducts: [Product] {
        products.filter { product in
            wishlistProductIds.contains(product.id)
        }.sorted { wishlistItem1, wishlistItem2 in
            let item1 = wishlistItems.first { $0.productId == wishlistItem1.id }
            let item2 = wishlistItems.first { $0.productId == wishlistItem2.id }
            return (item1?.addedDate ?? Date()) > (item2?.addedDate ?? Date())
        }
    }
    
    init() {
        loadDummyData()
        generateRecommendations()
        createDummyNotifications()
        updateUnreadNotificationCount()
    }
    
    // MARK: - Authentication
    func signIn(email: String, password: String) async -> Bool {
        isLoading = true
        
        // Simulate API call
        try? await Task.sleep(nanoseconds: 1_500_000_000) // 1.5 seconds
        
        // Create dummy auth user
        let authUser = AuthUser(
            email: email,
            username: email.components(separatedBy: "@").first ?? "user",
            displayName: "Demo User",
            profileImageURL: "https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=150&h=150&fit=crop&crop=face",
            isEmailVerified: true,
            provider: .email,
            lastLoginDate: Date(),
            createdDate: Calendar.current.date(byAdding: .month, value: -6, to: Date()) ?? Date(),
            isActive: true
        )
        
        await MainActor.run {
            self.authUser = authUser
            self.isAuthenticated = true
            self.isLoading = false
            self.createDummyUser()
        }
        
        return true
    }
    
    func signOut() {
        withAnimation(.spring()) {
            authUser = nil
            currentUser = nil
            isAuthenticated = false
            cartItems.removeAll()
            favoriteProductIds.removeAll()
            wishlistItems.removeAll()
        }
    }
    
    func register(credentials: RegisterCredentials) async -> Bool {
        isLoading = true
        
        // Simulate API call
        try? await Task.sleep(nanoseconds: 2_000_000_000) // 2 seconds
        
        let authUser = AuthUser(
            email: credentials.email,
            username: credentials.username,
            displayName: credentials.displayName,
            profileImageURL: nil,
            isEmailVerified: false,
            provider: .email,
            lastLoginDate: Date(),
            createdDate: Date(),
            isActive: true
        )
        
        await MainActor.run {
            self.authUser = authUser
            self.isAuthenticated = true
            self.isLoading = false
            self.createDummyUser()
            
            // Send welcome notification
            self.addNotification(
                title: "Welcome to Estly! 🎉",
                message: "Discover amazing handcrafted treasures from talented artisans worldwide.",
                type: .system
            )
        }
        
        return true
    }
    
    // MARK: - Cart Management
    func addToCart(_ product: Product, quantity: Int = 1, customizations: [String: String] = [:], giftWrap: Bool = false) {
        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
            if let existingItemIndex = cartItems.firstIndex(where: { 
                $0.product.id == product.id && $0.customizations == customizations 
            }) {
                cartItems[existingItemIndex].quantity += quantity
            } else {
                let cartItem = CartItem(
                    product: product,
                    quantity: quantity,
                    addedDate: Date(),
                    customizations: customizations,
                    personalMessage: nil,
                    giftWrap: giftWrap,
                    estimatedDelivery: Calendar.current.date(byAdding: .day, value: Int.random(in: 3...10), to: Date())
                )
                cartItems.append(cartItem)
                
                // Generate haptic feedback
                let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                impactFeedback.impactOccurred()
            }
        }
    }
    
    func removeFromCart(_ cartItem: CartItem) {
        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
            cartItems.removeAll { $0.id == cartItem.id }
        }
    }
    
    func updateCartItemQuantity(_ cartItem: CartItem, quantity: Int) {
        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
            if let index = cartItems.firstIndex(where: { $0.id == cartItem.id }) {
                if quantity <= 0 {
                    cartItems.remove(at: index)
                } else {
                    cartItems[index].quantity = min(quantity, cartItems[index].product.inventory.maxOrderQuantity)
                }
            }
        }
    }
    
    func clearCart() {
        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
            cartItems.removeAll()
        }
    }
    
    // MARK: - Wishlist Management
    func toggleWishlist(_ product: Product) {
        withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
            if let existingIndex = wishlistItems.firstIndex(where: { $0.productId == product.id }) {
                wishlistItems.remove(at: existingIndex)
                favoriteProductIds.remove(product.id)
            } else {
                let wishlistItem = WishlistItem(
                    productId: product.id,
                    addedDate: Date(),
                    notes: nil,
                    priority: .medium
                )
                wishlistItems.append(wishlistItem)
                favoriteProductIds.insert(product.id)
                
                // Add notification
                addNotification(
                    title: "Added to Wishlist ❤️",
                    message: "\"\(product.name)\" has been added to your wishlist.",
                    type: .system
                )
            }
        }
    }
    
    func isInWishlist(_ product: Product) -> Bool {
        wishlistProductIds.contains(product.id)
    }
    
    func removeFromWishlist(_ product: Product) {
        withAnimation(.spring()) {
            wishlistItems.removeAll { $0.productId == product.id }
            favoriteProductIds.remove(product.id)
        }
    }
    
    func moveWishlistItemToCart(_ product: Product) {
        withAnimation(.spring()) {
            addToCart(product)
            removeFromWishlist(product)
        }
    }
    
    // MARK: - Search and Filter
    func searchProducts(_ text: String) {
        searchText = text
    }
    
    func filterByCategory(_ category: ProductCategory?) {
        withAnimation(.easeInOut(duration: 0.3)) {
            selectedCategory = category
        }
    }
    
    func setSortOption(_ option: SortOption) {
        withAnimation(.easeInOut(duration: 0.3)) {
            sortOption = option
        }
    }
    
    func clearFilters() {
        withAnimation(.easeInOut(duration: 0.3)) {
            searchText = ""
            selectedCategory = nil
            sortOption = .featured
            priceRange = 0...1000
            minRating = 0
            showOnlyInStock = false
            showOnlyWithDiscount = false
        }
    }
    
    private func saveSearchToHistory(_ query: String, resultCount: Int) {
        // Don't save if query is too short or already recent
        guard query.count >= 2 else { return }
        
        if let existingIndex = searchHistory.firstIndex(where: { $0.query.lowercased() == query.lowercased() }) {
            searchHistory.remove(at: existingIndex)
        }
        
        let searchItem = SearchHistory(
            query: query,
            date: Date(),
            resultCount: resultCount,
            category: selectedCategory,
            filters: nil
        )
        
        searchHistory.insert(searchItem, at: 0)
        
        // Keep only last 50 searches
        if searchHistory.count > 50 {
            searchHistory = Array(searchHistory.prefix(50))
        }
    }
    
    // MARK: - Orders
    func createOrder(shippingAddress: Address, paymentMethod: PaymentMethod) async -> Order? {
        guard !cartItems.isEmpty else { return nil }
        
        isLoading = true
        
        // Simulate payment processing
        try? await Task.sleep(nanoseconds: 2_000_000_000)
        
        let orderNumber = "EST-\(Int.random(in: 100000...999999))"
        let order = Order(
            orderNumber: orderNumber,
            items: cartItems,
            subtotal: cartSubtotal,
            shippingCost: cartShipping,
            tax: cartTax,
            discount: 0,
            totalAmount: cartTotal,
            orderDate: Date(),
            status: .confirmed,
            shippingAddress: shippingAddress,
            billingAddress: shippingAddress,
            paymentMethod: paymentMethod,
            estimatedDelivery: Calendar.current.date(byAdding: .day, value: Int.random(in: 5...14), to: Date()) ?? Date(),
            actualDelivery: nil,
            trackingNumber: nil,
            carrier: nil,
            orderNotes: nil,
            statusHistory: [
                Order.OrderStatusUpdate(
                    status: .pending,
                    date: Date().addingTimeInterval(-120),
                    notes: "Order received",
                    location: nil
                ),
                Order.OrderStatusUpdate(
                    status: .confirmed,
                    date: Date(),
                    notes: "Payment confirmed",
                    location: nil
                )
            ]
        )
        
        await MainActor.run {
            self.orders.insert(order, at: 0)
            self.clearCart()
            self.isLoading = false
            
            // Add transaction
            let transaction = Transaction(
                orderId: order.id,
                paymentMethodId: paymentMethod.id,
                amount: order.totalAmount,
                currency: "USD",
                status: .completed,
                transactionDate: Date(),
                transactionId: "txn_\(UUID().uuidString.prefix(8))",
                paymentGateway: "Stripe",
                refundAmount: nil,
                refundDate: nil
            )
            self.transactions.append(transaction)
            
            // Add order confirmation notification
            self.addNotification(
                title: "Order Confirmed! 📦",
                message: "Your order \(orderNumber) has been confirmed and is being processed.",
                type: .orderUpdate
            )
        }
        
        return order
    }
    
    func updateOrderStatus(_ order: Order, newStatus: Order.OrderStatus) {
        if let index = orders.firstIndex(where: { $0.id == order.id }) {
            orders[index].status = newStatus
            
            let statusUpdate = Order.OrderStatusUpdate(
                status: newStatus,
                date: Date(),
                notes: getStatusUpdateMessage(for: newStatus),
                location: newStatus == .shipped ? "Distribution Center" : nil
            )
            
            orders[index].statusHistory.append(statusUpdate)
            
            // Add tracking number when shipped
            if newStatus == .shipped {
                orders[index].trackingNumber = "1Z\(String(Int.random(in: 100000000...999999999)))"
                orders[index].carrier = .fedex
            }
            
            // Add notification
            addNotification(
                title: "Order Update 📱",
                message: "Your order \(order.orderNumber) is now \(newStatus.rawValue.lowercased()).",
                type: .orderUpdate
            )
        }
    }
    
    private func getStatusUpdateMessage(for status: Order.OrderStatus) -> String {
        switch status {
        case .pending: return "Order received"
        case .confirmed: return "Payment confirmed"
        case .processing: return "Order is being prepared"
        case .shipped: return "Order has been shipped"
        case .outForDelivery: return "Out for delivery"
        case .delivered: return "Package delivered"
        case .cancelled: return "Order cancelled"
        case .refunded: return "Order refunded"
        case .returned: return "Order returned"
        }
    }
    
    // MARK: - Notifications
    func addNotification(title: String, message: String, type: AppNotification.NotificationType, actionURL: String? = nil, imageURL: String? = nil) {
        let notification = AppNotification(
            title: title,
            message: message,
            type: type,
            date: Date(),
            isRead: false,
            actionURL: actionURL,
            imageURL: imageURL,
            metadata: nil
        )
        
        withAnimation(.spring()) {
            notifications.insert(notification, at: 0)
            updateUnreadNotificationCount()
        }
    }
    
    func markNotificationAsRead(_ notification: AppNotification) {
        if let index = notifications.firstIndex(where: { $0.id == notification.id }) {
            notifications[index].isRead = true
            updateUnreadNotificationCount()
        }
    }
    
    func markAllNotificationsAsRead() {
        withAnimation(.spring()) {
            for index in notifications.indices {
                notifications[index].isRead = true
            }
            updateUnreadNotificationCount()
        }
    }
    
    private func updateUnreadNotificationCount() {
        unreadNotificationCount = notifications.filter { !$0.isRead }.count
    }
    
    // MARK: - Recommendations
    func generateRecommendations() {
        // Generate recommendations based on user behavior
        let allProductIds = products.map { $0.id }
        
        // Trending products
        let trendingProducts = allProductIds.shuffled().prefix(5)
        for productId in trendingProducts {
            recommendations.append(Recommendation(
                productId: productId,
                reason: .trending,
                score: Double.random(in: 0.7...1.0),
                createdDate: Date()
            ))
        }
        
        // Based on wishlist
        for wishlistItem in wishlistItems.prefix(3) {
            if let product = products.first(where: { $0.id == wishlistItem.productId }) {
                let similarProducts = products.filter { 
                    $0.category == product.category && $0.id != product.id 
                }.shuffled().prefix(2)
                
                for similarProduct in similarProducts {
                    recommendations.append(Recommendation(
                        productId: similarProduct.id,
                        reason: .viewedSimilar,
                        score: Double.random(in: 0.6...0.9),
                        createdDate: Date()
                    ))
                }
            }
        }
    }
    
    func getRecommendations(for reason: Recommendation.RecommendationReason, limit: Int = 10) -> [Product] {
        let recommendedIds = recommendations
            .filter { $0.reason == reason }
            .sorted { $0.score > $1.score }
            .prefix(limit)
            .map { $0.productId }
        
        return products.filter { product in
            recommendedIds.contains(product.id)
        }
    }
    
    // MARK: - Helper Functions
    func getProduct(by id: UUID) -> Product? {
        products.first { $0.id == id }
    }
    
    func getSeller(by id: UUID) -> Seller? {
        sellers.first { $0.id == id }
    }
    
    func getProductsBySeller(_ sellerId: UUID) -> [Product] {
        products.filter { $0.sellerId == sellerId }
    }
    
    func getSellerForProduct(_ product: Product) -> Seller? {
        getSeller(by: product.sellerId)
    }
    
    func getOrderHistory() -> [Order] {
        orders.sorted { $0.orderDate > $1.orderDate }
    }
    
    func getFeaturedProducts() -> [Product] {
        products.filter { $0.rating >= 4.5 && $0.reviewCount >= 50 }.shuffled().prefix(10).map { $0 }
    }
    
    func getNewArrivals() -> [Product] {
        products.sorted { $0.createdDate > $1.createdDate }.prefix(8).map { $0 }
    }
    
    func getProductsOnSale() -> [Product] {
        products.filter { $0.discountedPrice != nil }.shuffled().prefix(12).map { $0 }
    }
}

// MARK: - Dummy Data Loading
extension EstlyStore {
    private func loadDummyData() {
        createDummySellers()
        createDummyProducts()
        createDummyPaymentMethods()
        createDummyAddresses()
        
        // Generate some dummy orders for demo
        if isAuthenticated {
            createDummyOrders()
        }
    }
    
    private func createDummySellers() {
        sellers = [
            Seller(
                name: "Emma Rodriguez",
                shopName: "Emma's Handcrafted Treasures",
                profileImageURL: "https://images.unsplash.com/photo-1494790108755-2616b612b47c?w=150&h=150&fit=crop&crop=face",
                coverImageURL: "https://images.unsplash.com/photo-1441986300917-64674bd600d8?w=800&h=300&fit=crop",
                bio: "Artisan specializing in sustainable jewelry",
                detailedBio: "Emma has been creating beautiful, sustainable jewelry for over 8 years. Her pieces are inspired by nature and crafted using ethically sourced materials. Each piece tells a story and is made with love and attention to detail.",
                rating: 4.8,
                totalSales: 1250,
                totalReviews: 987,
                joinedDate: Calendar.current.date(byAdding: .year, value: -3, to: Date()) ?? Date(),
                location: Address(
                    title: "Business",
                    firstName: "Emma",
                    lastName: "Rodriguez",
                    company: "Emma's Handcrafted Treasures",
                    street: "123 Artisan Way",
                    apartment: nil,
                    city: "Portland",
                    state: "OR",
                    zipCode: "97201",
                    country: "USA",
                    phoneNumber: nil,
                    isDefault: true,
                    isPrimary: true,
                    addressType: .work,
                    deliveryInstructions: nil
                ),
                specialties: ["Jewelry", "Eco-friendly", "Custom Design"],
                isVerified: true,
                isActive: true,
                socialMediaLinks: Seller.SocialMediaLinks(
                    website: "www.emmascrafts.com",
                    instagram: "@emmascrafts",
                    facebook: "EmmasHandcraftedTreasures",
                    twitter: "@emmascrafts",
                    pinterest: "emmascrafts",
                    etsy: "EmmasHandcraftedTreasures"
                ),
                policies: Seller.SellerPolicies(
                    returnPolicy: "30-day return policy for unworn items",
                    exchangePolicy: "Exchanges available within 14 days",
                    privacyPolicy: "We protect your personal information",
                    shippingPolicy: "Ships within 2-3 business days",
                    customOrderPolicy: "Custom orders welcome, 2-3 week turnaround"
                ),
                certifications: ["Certified Artisan", "Eco-Friendly Business"],
                awards: ["Best Jewelry Artisan 2023", "Sustainable Business Award"],
                responseTime: "Usually responds within 2 hours",
                languages: ["English", "Spanish"]
            ),
            
            Seller(
                name: "Marcus Chen",
                shopName: "Urban Woodworks Studio",
                profileImageURL: "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150&h=150&fit=crop&crop=face",
                coverImageURL: "https://images.unsplash.com/photo-1586023492125-27b2c045efd7?w=800&h=300&fit=crop",
                bio: "Master woodworker creating modern furniture",
                detailedBio: "Marcus is a master craftsman with over 15 years of experience in woodworking. He specializes in creating modern, functional furniture pieces using sustainable wood sources. His workshop combines traditional techniques with contemporary design.",
                rating: 4.9,
                totalSales: 856,
                totalReviews: 642,
                joinedDate: Calendar.current.date(byAdding: .year, value: -5, to: Date()) ?? Date(),
                location: Address(
                    title: "Workshop",
                    firstName: "Marcus",
                    lastName: "Chen",
                    company: "Urban Woodworks Studio",
                    street: "456 Maker Street",
                    apartment: "Unit B",
                    city: "Austin",
                    state: "TX",
                    zipCode: "78701",
                    country: "USA",
                    phoneNumber: "+1-512-555-0123",
                    isDefault: true,
                    isPrimary: true,
                    addressType: .work,
                    deliveryInstructions: "Loading dock in rear"
                ),
                specialties: ["Woodworking", "Furniture", "Custom Design"],
                isVerified: true,
                isActive: true,
                socialMediaLinks: Seller.SocialMediaLinks(
                    website: "www.urbanwoodworks.com",
                    instagram: "@urbanwoodworks",
                    facebook: "UrbanWoodworksStudio",
                    twitter: nil,
                    pinterest: "urbanwoodworks",
                    etsy: nil
                ),
                policies: Seller.SellerPolicies(
                    returnPolicy: "Returns accepted within 30 days for defects only",
                    exchangePolicy: "No exchanges on custom pieces",
                    privacyPolicy: "Standard privacy protection",
                    shippingPolicy: "White glove delivery available",
                    customOrderPolicy: "Custom furniture orders require 50% deposit"
                ),
                certifications: ["Master Craftsman", "Sustainable Wood Certified"],
                awards: ["Furniture Design Excellence 2022"],
                responseTime: "Usually responds within 4 hours",
                languages: ["English", "Mandarin"]
            ),
            
            Seller(
                name: "Isabella Thompson",
                shopName: "Bella's Vintage Collection",
                profileImageURL: "https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=150&h=150&fit=crop&crop=face",
                coverImageURL: "https://images.unsplash.com/photo-1441984904996-e0b6ba687e04?w=800&h=300&fit=crop",
                bio: "Curator of authentic vintage treasures",
                detailedBio: "Isabella has spent over a decade traveling the world to source authentic vintage items. Her collection features carefully selected pieces from the 1920s through the 1980s, each with its own unique history and character.",
                rating: 4.7,
                totalSales: 2103,
                totalReviews: 1567,
                joinedDate: Calendar.current.date(byAdding: .year, value: -6, to: Date()) ?? Date(),
                location: Address(
                    title: "Store",
                    firstName: "Isabella",
                    lastName: "Thompson",
                    company: "Bella's Vintage Collection",
                    street: "789 Vintage Boulevard",
                    apartment: nil,
                    city: "Brooklyn",
                    state: "NY",
                    zipCode: "11201",
                    country: "USA",
                    phoneNumber: "+1-718-555-0456",
                    isDefault: true,
                    isPrimary: true,
                    addressType: .work,
                    deliveryInstructions: nil
                ),
                specialties: ["Vintage", "Antiques", "Rare Finds"],
                isVerified: true,
                isActive: true,
                socialMediaLinks: Seller.SocialMediaLinks(
                    website: "www.bellasvintage.com",
                    instagram: "@bellasvintage",
                    facebook: "BellasVintageCollection",
                    twitter: "@bellasvintage",
                    pinterest: "bellasvintage",
                    etsy: "BellasVintageCollection"
                ),
                policies: Seller.SellerPolicies(
                    returnPolicy: "Returns accepted within 14 days if not as described",
                    exchangePolicy: "Exchanges considered case by case",
                    privacyPolicy: "We respect your privacy",
                    shippingPolicy: "Careful packaging for all vintage items",
                    customOrderPolicy: "Special sourcing requests welcome"
                ),
                certifications: ["Certified Vintage Dealer", "Antique Appraisal Certified"],
                awards: ["Best Vintage Curator 2021"],
                responseTime: "Usually responds within 1 hour",
                languages: ["English", "French", "Italian"]
            )
        ]
    }
    
    private func createDummyProducts() {
        // Real Google Images URLs for products
        let productData: [(String, Double, [String], String, String, ProductCategory, [String], [String], String, Bool, Bool)] = [
            // Jewelry
            ("Handwoven Bohemian Necklace", 45.99, 
             ["https://images.unsplash.com/photo-1515562141207-7a88fb7ce338?w=400&h=400&fit=crop",
              "https://images.unsplash.com/photo-1506630448388-4e683c67ddb0?w=400&h=400&fit=crop"],
             "Beautiful handwoven necklace with natural stones", 
             "This stunning bohemian necklace features hand-selected natural stones woven together with sustainable cotton cord. Each piece is unique, showcasing the natural variations in the stones. Perfect for layering or wearing alone for a statement look.",
             .jewelry, ["boho", "natural", "handmade", "sustainable"], ["Silver", "Natural stones", "Cotton cord"], "Ships in 2-3 business days", true, false),
            
            ("Silver Moon Phases Earrings", 32.99,
             ["https://images.unsplash.com/photo-1596944924591-3833ed3e2607?w=400&h=400&fit=crop",
              "https://images.unsplash.com/photo-1594736797933-d0d34b9e0665?w=400&h=400&fit=crop"],
             "Delicate sterling silver moon phase earrings",
             "These elegant sterling silver earrings showcase the beauty of lunar phases. Hypoallergenic and lightweight, they're perfect for everyday wear or special occasions. Each earring features detailed engravings of moon phases.",
             .jewelry, ["silver", "moon", "delicate", "celestial"], ["Sterling Silver"], "Ships in 1-2 business days", true, false),
            
            ("Vintage Crystal Ring", 89.99,
             ["https://images.unsplash.com/photo-1605100804763-247f67b3557e?w=400&h=400&fit=crop",
              "https://images.unsplash.com/photo-1617038260897-41a1f14a8ca0?w=400&h=400&fit=crop"],
             "Authentic vintage crystal ring from the 1940s",
             "A stunning piece from our vintage collection, this crystal ring dates back to the 1940s. The center stone is a natural crystal with beautiful clarity and the setting shows the craftsmanship of a bygone era.",
             .jewelry, ["vintage", "crystal", "antique", "rare"], ["Gold-plated", "Natural crystal"], "Ships in 1-2 business days", false, true),
            
            // Home Decor
            ("Rustic Wooden Coffee Table", 299.99,
             ["https://images.unsplash.com/photo-1586023492125-27b2c045efd7?w=400&h=400&fit=crop",
              "https://images.unsplash.com/photo-1555041469-a586c61ea9bc?w=400&h=400&fit=crop"],
             "Handcrafted coffee table made from reclaimed oak",
             "This beautiful coffee table is crafted from reclaimed oak wood, showcasing natural grain patterns and character marks that tell the wood's story. Each piece is unique with a rich history, finished with eco-friendly sealants.",
             .homeDecor, ["rustic", "wooden", "furniture", "reclaimed"], ["Reclaimed Oak", "Natural finish"], "Ships in 1-2 weeks", true, false),
            
            ("Macrame Wall Hanging", 54.99,
             ["https://images.unsplash.com/photo-1578662996442-48f60103fc96?w=400&h=400&fit=crop",
              "https://images.unsplash.com/photo-1578662996442-48f60103fc96?w=400&h=400&fit=crop"],
             "Large macrame wall hanging for boho decor",
             "This stunning large macrame wall hanging adds texture and warmth to any space. Hand-knotted with natural cotton rope and finished with a smooth wooden dowel, it's perfect for creating a bohemian atmosphere in your home.",
             .homeDecor, ["macrame", "wall art", "boho", "handknotted"], ["Cotton rope", "Wooden dowel"], "Ships in 2-3 business days", true, false),
            
            ("Ceramic Planter Set", 67.50,
             ["https://images.unsplash.com/photo-1485955900006-10f4d324d411?w=400&h=400&fit=crop",
              "https://images.unsplash.com/photo-1485955900006-10f4d324d411?w=400&h=400&fit=crop"],
             "Set of 3 handmade ceramic planters",
             "Beautiful set of three handthrown ceramic planters in graduated sizes. Each piece features a unique reactive glaze that creates one-of-a-kind patterns. Perfect for succulents, herbs, or small houseplants.",
             .homeDecor, ["ceramic", "planters", "handmade", "pottery"], ["Ceramic", "Reactive glaze"], "Ships in 3-5 business days", true, false),
            
            // Art
            ("Abstract Canvas Painting", 189.50,
             ["https://images.unsplash.com/photo-1578662996442-48f60103fc96?w=400&h=400&fit=crop",
              "https://images.unsplash.com/photo-1578662996442-48f60103fc96?w=400&h=400&fit=crop"],
             "Original abstract painting on canvas",
             "This vibrant original abstract painting brings energy and color to any room. Created with high-quality acrylic paints on professional-grade canvas, each brushstroke tells part of the artist's emotional journey.",
             .art, ["abstract", "original", "canvas", "vibrant"], ["Acrylic paint", "Canvas"], "Ships in 5-7 business days", true, false),
            
            ("Watercolor Botanical Print", 24.99,
             ["https://images.unsplash.com/photo-1578662996442-48f60103fc96?w=400&h=400&fit=crop",
              "https://images.unsplash.com/photo-1578662996442-48f60103fc96?w=400&h=400&fit=crop"],
             "Beautiful watercolor botanical illustration",
             "This delicate watercolor botanical print captures the intricate beauty of nature. Printed on high-quality archival paper with fade-resistant inks, it's available in multiple sizes and framing options.",
             .art, ["watercolor", "botanical", "print", "nature"], ["High-quality paper", "Archival ink"], "Ships in 2-3 business days", true, false),
            
            // Clothing
            ("Handknit Merino Sweater", 89.99,
             ["https://images.unsplash.com/photo-1434389677669-e08b4cac3105?w=400&h=400&fit=crop",
              "https://images.unsplash.com/photo-1434389677669-e08b4cac3105?w=400&h=400&fit=crop"],
             "Cozy handknit sweater made from premium merino wool",
             "This incredibly soft and warm sweater is hand-knitted from premium merino wool. The cable-knit pattern adds texture and visual interest, while the natural wool provides excellent temperature regulation.",
             .clothing, ["handknit", "wool", "cozy", "merino"], ["Merino Wool"], "Ships in 1 week", true, false),
            
            ("Tie-Dye Summer Dress", 56.99,
             ["https://images.unsplash.com/photo-1434389677669-e08b4cac3105?w=400&h=400&fit=crop",
              "https://images.unsplash.com/photo-1434389677669-e08b4cac3105?w=400&h=400&fit=crop"],
             "Flowing tie-dye cotton dress perfect for summer",
             "This beautiful flowing dress features a unique tie-dye pattern created using natural dyes. Made from 100% organic cotton, it's comfortable, breathable, and perfect for warm weather. Each dress is unique due to the hand-dye process.",
             .clothing, ["tie-dye", "cotton", "summer", "organic"], ["100% Organic Cotton"], "Ships in 3-5 business days", true, false),
            
            // Accessories
            ("Hand-painted Leather Tote", 145.00,
             ["https://images.unsplash.com/photo-1553062407-98eeb64c6a62?w=400&h=400&fit=crop",
              "https://images.unsplash.com/photo-1553062407-98eeb64c6a62?w=400&h=400&fit=crop"],
             "Unique hand-painted leather tote bag",
             "This stunning leather tote bag features original hand-painted artwork that makes each piece truly one-of-a-kind. Crafted from genuine full-grain leather, it's both beautiful and functional with plenty of space for daily essentials.",
             .accessories, ["leather", "hand-painted", "unique", "tote"], ["Genuine Leather", "Acrylic paint"], "Ships in 1-2 weeks", true, false),
            
            ("Wooden Sunglasses", 78.99,
             ["https://images.unsplash.com/photo-1553062407-98eeb64c6a62?w=400&h=400&fit=crop",
              "https://images.unsplash.com/photo-1553062407-98eeb64c6a62?w=400&h=400&fit=crop"],
             "Eco-friendly wooden frame sunglasses",
             "These stylish sunglasses feature frames crafted from sustainable bamboo wood. The polarized lenses provide excellent UV protection while the lightweight wood frame ensures all-day comfort.",
             .accessories, ["wooden", "eco-friendly", "bamboo", "polarized"], ["Bamboo Wood", "Polarized lenses"], "Ships in 2-3 business days", true, false),
            
            // Handmade
            ("Handmade Soap Collection", 29.99,
             ["https://images.unsplash.com/photo-1571781926291-c477ebfd024b?w=400&h=400&fit=crop",
              "https://images.unsplash.com/photo-1571781926291-c477ebfd024b?w=400&h=400&fit=crop"],
             "Set of 6 handmade soaps with natural ingredients",
             "This delightful collection includes six handmade soaps, each crafted with natural ingredients and essential oils. Free from harsh chemicals and made using traditional cold-process methods for a gentle, moisturizing cleanse.",
             .handmade, ["soap", "natural", "collection", "essential oils"], ["Natural oils", "Essential oils", "Shea butter"], "Ships in 1-2 business days", true, false),
            
            ("Hand-carved Wooden Bowl", 42.00,
             ["https://images.unsplash.com/photo-1571781926291-c477ebfd024b?w=400&h=400&fit=crop",
              "https://images.unsplash.com/photo-1571781926291-c477ebfd024b?w=400&h=400&fit=crop"],
             "Beautiful hand-carved wooden serving bowl",
             "This gorgeous serving bowl is hand-carved from a single piece of sustainable hardwood. The smooth finish and natural grain patterns make each bowl unique. Perfect for salads, fruit, or as a decorative centerpiece.",
             .handmade, ["carved", "wooden", "bowl", "sustainable"], ["Hardwood", "Food-safe finish"], "Ships in 1 week", true, false),
            
            // Vintage
            ("Vintage Brass Compass", 42.00,
             ["https://images.unsplash.com/photo-1441984904996-e0b6ba687e04?w=400&h=400&fit=crop",
              "https://images.unsplash.com/photo-1441984904996-e0b6ba687e04?w=400&h=400&fit=crop"],
             "Authentic vintage brass compass from the 1950s",
             "This authentic brass compass dates from the 1950s and is in excellent working condition. The patina adds character while the precision mechanism still functions perfectly. A perfect piece for collectors or nautical enthusiasts.",
             .vintage, ["vintage", "brass", "compass", "collectible"], ["Solid Brass"], "Ships in 1-2 business days", false, true),
            
            ("Retro Vinyl Record Collection", 128.99,
             ["https://images.unsplash.com/photo-1441984904996-e0b6ba687e04?w=400&h=400&fit=crop",
              "https://images.unsplash.com/photo-1441984904996-e0b6ba687e04?w=400&h=400&fit=crop"],
             "Collection of classic vinyl records from the 70s",
             "This curated collection includes 12 classic vinyl records from the 1970s, featuring iconic artists and albums. All records are in excellent condition with minimal wear. Perfect for music lovers and collectors.",
             .vintage, ["vinyl", "records", "70s", "music"], ["Vinyl"], "Ships in 2-3 business days", false, true),
            
            // Crafts
            ("Handwoven Basket Set", 63.25,
             ["https://images.unsplash.com/photo-1553062407-98eeb64c6a62?w=400&h=400&fit=crop",
              "https://images.unsplash.com/photo-1553062407-98eeb64c6a62?w=400&h=400&fit=crop"],
             "Set of 3 handwoven baskets for storage",
             "These beautiful handwoven baskets are crafted from natural fibers using traditional techniques. The set includes three different sizes, perfect for organizing and adding natural texture to your home decor.",
             .crafts, ["woven", "baskets", "storage", "natural"], ["Natural fiber", "Handwoven"], "Ships in 3-5 business days", true, false),
            
            ("Embroidered Throw Pillows", 48.50,
             ["https://images.unsplash.com/photo-1553062407-98eeb64c6a62?w=400&h=400&fit=crop",
              "https://images.unsplash.com/photo-1553062407-98eeb64c6a62?w=400&h=400&fit=crop"],
             "Set of 2 hand-embroidered throw pillows",
             "These gorgeous throw pillows feature intricate hand-embroidered designs inspired by traditional folk art. Made with soft cotton fabric and filled with hypoallergenic polyester, they're both beautiful and comfortable.",
             .crafts, ["embroidered", "pillows", "folk art", "cotton"], ["Cotton", "Polyester fill"], "Ships in 1 week", true, false)
        ]
        
        products = productData.enumerated().map { index, data in
            let seller = sellers[index % sellers.count]
            let createdDate = Calendar.current.date(byAdding: .day, value: -Int.random(in: 1...365), to: Date()) ?? Date()
            
            return Product(
                name: data.0,
                price: data.1,
                imageURLs: data.2,
                description: data.3,
                detailedDescription: data.4,
                category: data.5,
                sellerId: seller.id,
                rating: Double.random(in: 4.0...5.0),
                reviewCount: Int.random(in: 15...200),
                isFavorite: false,
                tags: data.6,
                materials: data.7,
                dimensions: Product.ProductDimensions(
                    length: Double.random(in: 5...30),
                    width: Double.random(in: 5...25),
                    height: Double.random(in: 2...15),
                    unit: "cm"
                ),
                weight: Double.random(in: 0.1...5.0),
                shippingInfo: Product.ShippingInfo(
                    estimatedDelivery: data.8,
                    shippingCost: Bool.random() ? 0 : Double.random(in: 5...15),
                    freeShippingThreshold: 75.0,
                    internationalShipping: Bool.random(),
                    expressShipping: Bool.random()
                ),
                inventory: Product.ProductInventory(
                    stockQuantity: Int.random(in: 0...50),
                    lowStockThreshold: 5,
                    isInStock: Bool.random() ? true : Int.random(in: 1...10) > 2,
                    maxOrderQuantity: 10
                ),
                customizationOptions: data.9 ? [
                    Product.CustomizationOption(
                        name: "Size",
                        options: ["Small", "Medium", "Large"],
                        additionalCost: 0,
                        isRequired: false
                    ),
                    Product.CustomizationOption(
                        name: "Color",
                        options: ["Natural", "Dark", "Light"],
                        additionalCost: 5.0,
                        isRequired: false
                    )
                ] : [],
                createdDate: createdDate,
                updatedDate: createdDate,
                isAvailable: true,
                discount: Bool.random() ? Product.Discount(
                    percentage: Double.random(in: 10...30),
                    startDate: Calendar.current.date(byAdding: .day, value: -5, to: Date()) ?? Date(),
                    endDate: Calendar.current.date(byAdding: .day, value: 15, to: Date()) ?? Date(),
                    isActive: true
                ) : nil,
                seoTitle: "\(data.0) - Handcrafted by \(seller.name)",
                seoDescription: data.3,
                isHandmade: data.9,
                isVintage: data.10,
                processingTime: data.8
            )
        }
    }
    
    private func createDummyUser() {
        guard authUser != nil else { return }
        
        currentUser = User(
            name: authUser?.displayName ?? "Demo User",
            email: authUser?.email ?? "demo@example.com",
            username: authUser?.username ?? "demouser",
            profileImageURL: authUser?.profileImageURL,
            phoneNumber: "+1-555-123-4567",
            dateOfBirth: Calendar.current.date(byAdding: .year, value: -28, to: Date()),
            gender: .preferNotToSay,
            preferredLanguage: "English",
            currency: "USD",
            addresses: addresses,
            paymentMethods: paymentMethods,
            preferences: User.UserPreferences(
                enableNotifications: true,
                enableEmailMarketing: false,
                enablePushNotifications: true,
                preferredShippingSpeed: .standard,
                themePreference: .system,
                currency: "USD",
                language: "English"
            ),
            joinedDate: authUser?.createdDate ?? Date(),
            lastActiveDate: Date(),
            favoriteCategories: [.jewelry, .homeDecor, .art],
            isEmailVerified: true,
            isPhoneVerified: false,
            membershipTier: .silver,
            totalOrdersCount: 12,
            totalSpent: 847.23,
            loyaltyPoints: 1250
        )
    }
    
    private func createDummyPaymentMethods() {
        paymentMethods = [
            PaymentMethod(
                type: .creditCard,
                isDefault: true,
                lastFour: "4242",
                expiryMonth: 12,
                expiryYear: 2028,
                cardBrand: .visa,
                billingAddress: addresses.first ?? Address(
                    title: "Home",
                    firstName: "Demo",
                    lastName: "User",
                    company: nil,
                    street: "123 Main St",
                    apartment: nil,
                    city: "New York",
                    state: "NY",
                    zipCode: "10001",
                    country: "USA",
                    phoneNumber: nil,
                    isDefault: true,
                    isPrimary: true,
                    addressType: .home,
                    deliveryInstructions: nil
                ),
                createdDate: Calendar.current.date(byAdding: .month, value: -6, to: Date()) ?? Date(),
                isActive: true
            ),
            PaymentMethod(
                type: .applePay,
                isDefault: false,
                lastFour: "Pay",
                expiryMonth: nil,
                expiryYear: nil,
                cardBrand: nil,
                billingAddress: addresses.first ?? Address(
                    title: "Home",
                    firstName: "Demo",
                    lastName: "User",
                    company: nil,
                    street: "123 Main St",
                    apartment: nil,
                    city: "New York",
                    state: "NY",
                    zipCode: "10001",
                    country: "USA",
                    phoneNumber: nil,
                    isDefault: true,
                    isPrimary: true,
                    addressType: .home,
                    deliveryInstructions: nil
                ),
                createdDate: Calendar.current.date(byAdding: .month, value: -3, to: Date()) ?? Date(),
                isActive: true
            )
        ]
    }
    
    private func createDummyAddresses() {
        addresses = [
            Address(
                title: "Home",
                firstName: "Demo",
                lastName: "User",
                company: nil,
                street: "123 Main Street",
                apartment: "Apt 4B",
                city: "New York",
                state: "NY",
                zipCode: "10001",
                country: "USA",
                phoneNumber: "+1-555-123-4567",
                isDefault: true,
                isPrimary: true,
                addressType: .home,
                deliveryInstructions: "Leave with doorman"
            ),
            Address(
                title: "Work",
                firstName: "Demo",
                lastName: "User",
                company: "Demo Company Inc.",
                street: "456 Business Ave",
                apartment: "Suite 200",
                city: "New York",
                state: "NY",
                zipCode: "10002",
                country: "USA",
                phoneNumber: "+1-555-987-6543",
                isDefault: false,
                isPrimary: false,
                addressType: .work,
                deliveryInstructions: "Front desk reception"
            )
        ]
    }
    
    private func createDummyOrders() {
        // Create some dummy orders for demonstration
        let sampleProducts = Array(products.prefix(3))
        let sampleCartItems = sampleProducts.map { product in
            CartItem(
                product: product,
                quantity: Int.random(in: 1...3),
                addedDate: Date(),
                customizations: [:],
                personalMessage: nil,
                giftWrap: false,
                estimatedDelivery: nil
            )
        }
        
        let dummyOrder = Order(
            orderNumber: "EST-123456",
            items: sampleCartItems,
            subtotal: 167.48,
            shippingCost: 0.00,
            tax: 14.83,
            discount: 0.00,
            totalAmount: 182.31,
            orderDate: Calendar.current.date(byAdding: .day, value: -5, to: Date()) ?? Date(),
            status: .shipped,
            shippingAddress: addresses.first!,
            billingAddress: addresses.first!,
            paymentMethod: paymentMethods.first!,
            estimatedDelivery: Calendar.current.date(byAdding: .day, value: 3, to: Date()) ?? Date(),
            actualDelivery: nil,
            trackingNumber: "1Z999AA1012345678",
            carrier: .fedex,
            orderNotes: nil,
            statusHistory: [
                Order.OrderStatusUpdate(
                    status: .pending,
                    date: Calendar.current.date(byAdding: .day, value: -5, to: Date()) ?? Date(),
                    notes: "Order received",
                    location: nil
                ),
                Order.OrderStatusUpdate(
                    status: .confirmed,
                    date: Calendar.current.date(byAdding: .day, value: -4, to: Date()) ?? Date(),
                    notes: "Payment confirmed",
                    location: nil
                ),
                Order.OrderStatusUpdate(
                    status: .processing,
                    date: Calendar.current.date(byAdding: .day, value: -3, to: Date()) ?? Date(),
                    notes: "Order is being prepared",
                    location: "Fulfillment Center"
                ),
                Order.OrderStatusUpdate(
                    status: .shipped,
                    date: Calendar.current.date(byAdding: .day, value: -1, to: Date()) ?? Date(),
                    notes: "Package shipped via FedEx",
                    location: "Distribution Center"
                )
            ]
        )
        
        orders.append(dummyOrder)
    }
    
    private func createDummyNotifications() {
        notifications = [
            AppNotification(
                title: "Order Shipped! 📦",
                message: "Your order EST-123456 has been shipped and is on its way to you.",
                type: .orderUpdate,
                date: Calendar.current.date(byAdding: .hour, value: -2, to: Date()) ?? Date(),
                isRead: false,
                actionURL: nil,
                imageURL: nil,
                metadata: ["orderId": "EST-123456"]
            ),
            AppNotification(
                title: "Flash Sale! ⚡",
                message: "Get 25% off all jewelry items. Limited time offer!",
                type: .promotion,
                date: Calendar.current.date(byAdding: .hour, value: -6, to: Date()) ?? Date(),
                isRead: false,
                actionURL: nil,
                imageURL: nil,
                metadata: ["discount": "25", "category": "jewelry"]
            ),
            AppNotification(
                title: "Back in Stock! 🔄",
                message: "The Handwoven Bohemian Necklace you wishlisted is now available.",
                type: .backInStock,
                date: Calendar.current.date(byAdding: .day, value: -1, to: Date()) ?? Date(),
                isRead: true,
                actionURL: nil,
                imageURL: nil,
                metadata: nil
            )
        ]
    }
}