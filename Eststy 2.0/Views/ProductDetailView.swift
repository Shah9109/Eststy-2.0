import SwiftUI

struct ProductDetailView: View {
    let product: Product
    @EnvironmentObject var store: EstlyStore
    @Environment(\.dismiss) private var dismiss
    @State private var selectedQuantity = 1
    @State private var showingImageDetail = false
    @State private var showingSellerProfile = false
    @State private var addToCartAnimation = false
    @State private var scrollOffset: CGFloat = 0
    @State private var showingShareSheet = false
    
    var seller: Seller? {
        store.getSellerForProduct(product)
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 0) {
                    // Product Image Section
                    productImageSection
                    
                    // Product Info Section
                    VStack(alignment: .leading, spacing: 20) {
                        // Basic Info
                        productBasicInfo
                        
                        // Price and Add to Cart
                        priceAndCartSection
                        
                        // Product Details
                        productDetailsSection
                        
                        // Seller Info
                        if let seller = seller {
                            sellerInfoSection(seller)
                        }
                        
                        // Shipping Info
                        shippingInfoSection
                        
                        // Reviews Preview
                        reviewsSection
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 100) // For floating cart button
                }
            }
            .background(Color(UIColor.systemBackground))
            .overlay(alignment: .bottom) {
                floatingAddToCartButton
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar(content: {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.primary)
                            .frame(width: 32, height: 32)
                            .background(Color(UIColor.systemBackground).opacity(0.8))
                            .clipShape(Circle())
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack(spacing: 12) {
                        // Favorite Button
                        Button(action: {
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                                if store.favoriteProductIds.contains(product.id) {
                                    store.favoriteProductIds.remove(product.id)
                                } else {
                                    store.favoriteProductIds.insert(product.id)
                                }
                            }
                        }) {
                            Image(systemName: store.favoriteProductIds.contains(product.id) ? "heart.fill" : "heart")
                                .font(.system(size: 18, weight: .medium))
                                .foregroundColor(store.favoriteProductIds.contains(product.id) ? .red : .primary)
                                .frame(width: 32, height: 32)
                                .background(Color(UIColor.systemBackground).opacity(0.8))
                                .clipShape(Circle())
                        }
                        .scaleEffect(store.favoriteProductIds.contains(product.id) ? 1.1 : 1.0)
                        .animation(.spring(response: 0.4, dampingFraction: 0.6), value: store.favoriteProductIds.contains(product.id))
                        
                        // Share Button
                        Button(action: { showingShareSheet = true }) {
                            Image(systemName: "square.and.arrow.up")
                                .font(.system(size: 18, weight: .medium))
                                .foregroundColor(.primary)
                                .frame(width: 32, height: 32)
                                .background(Color(UIColor.systemBackground).opacity(0.8))
                                .clipShape(Circle())
                        }
                    }
                }
            })
            .sheet(isPresented: $showingSellerProfile) {
                if let seller = seller {
                    SellerProfileView(seller: seller)
                        .environmentObject(store)
                }
            }
        }
    }
    
    // MARK: - Product Image Section
    private var productImageSection: some View {
        ZStack(alignment: .bottom) {
            Rectangle()
                .fill(Color.gray.opacity(0.1))
                .frame(height: 400)
                .overlay(
                    Image(systemName: "photo")
                        .font(.system(size: 60))
                        .foregroundColor(.gray.opacity(0.6))
                )
                .onTapGesture {
                    showingImageDetail = true
                }
            
            // Discount Badge
            if product.discountedPrice != nil {
                HStack {
                    Text("15% OFF")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.red)
                        .clipShape(Capsule())
                    
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
        }
        .clipped()
    }
    
    // MARK: - Product Basic Info
    private var productBasicInfo: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Category Badge
            HStack {
                Text(product.category.rawValue)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.blue)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.blue.opacity(0.1))
                    .clipShape(Capsule())
                
                Spacer()
            }
            
            // Product Name
            Text(product.name)
                .font(.system(size: 26, weight: .bold))
                .foregroundColor(.primary)
                .lineLimit(3)
            
            // Rating and Reviews
            HStack(spacing: 8) {
                                            EnhancedRatingStarsView(rating: product.rating, size: 16)
                
                Text(String(format: "%.1f", product.rating))
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.primary)
                
                Text("(\(product.reviewCount) reviews)")
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
                
                Spacer()
            }
        }
        .padding(.top, 20)
    }
    
    // MARK: - Price and Cart Section
    private var priceAndCartSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Price
            HStack(alignment: .bottom, spacing: 8) {
                                    LiquidPriceTagView(product: product)
                
                if product.discountedPrice != nil {
                    Text("Save \(String(format: "%.0f", (product.price - (product.discountedPrice ?? 0))))")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.green)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.green.opacity(0.1))
                        .clipShape(Capsule())
                }
                
                Spacer()
            }
            
            // Quantity Selector
            HStack {
                Text("Quantity:")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.primary)
                
                Spacer()
                
                HStack(spacing: 12) {
                    Button(action: {
                        if selectedQuantity > 1 {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                selectedQuantity -= 1
                            }
                        }
                    }) {
                        Image(systemName: "minus")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.primary)
                            .frame(width: 32, height: 32)
                            .background(Color.gray.opacity(0.1))
                            .clipShape(Circle())
                    }
                    .disabled(selectedQuantity <= 1)
                    
                    Text("\(selectedQuantity)")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.primary)
                        .frame(width: 40)
                    
                    Button(action: {
                        if selectedQuantity < 10 {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                selectedQuantity += 1
                            }
                        }
                    }) {
                        Image(systemName: "plus")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.primary)
                            .frame(width: 32, height: 32)
                            .background(Color.gray.opacity(0.1))
                            .clipShape(Circle())
                    }
                    .disabled(selectedQuantity >= 10)
                }
            }
        }
    }
    
    // MARK: - Product Details Section
    private var productDetailsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Description")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.primary)
            
            Text(product.description)
                .font(.system(size: 16))
                .foregroundColor(.primary)
                .lineSpacing(4)
            
            // Materials
            if !product.materials.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Materials")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.primary)
                    
                    Text(product.materials.joined(separator: ", "))
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                }
            }
            
            // Tags
            if !product.tags.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Tags")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.primary)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            ForEach(product.tags, id: \.self) { tag in
                                Text("#\(tag)")
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundColor(.blue)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(Color.blue.opacity(0.1))
                                    .clipShape(Capsule())
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                    .padding(.horizontal, -20)
                }
            }
        }
    }
    
    // MARK: - Seller Info Section
    private func sellerInfoSection(_ seller: Seller) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Seller Information")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.primary)
            
            Button(action: {
                showingSellerProfile = true
            }) {
                HStack(spacing: 12) {
                    Text(String(seller.name.prefix(1)))
                        .font(.system(size: 24))
                        .frame(width: 50, height: 50)
                        .background(Color.gray.opacity(0.1))
                        .clipShape(Circle())
                    
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text(seller.shopName)
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.primary)
                            
                            if seller.isVerified {
                                Image(systemName: "checkmark.seal.fill")
                                    .font(.system(size: 12))
                                    .foregroundColor(.blue)
                            }
                        }
                        
                        Text("by \(seller.name)")
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                        
                        HStack {
                                                            EnhancedRatingStarsView(rating: seller.rating, size: 12)
                            Text("(\(seller.totalSales) sales)")
                                .font(.system(size: 12))
                                .foregroundColor(.gray)
                        }
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.gray)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(Color.gray.opacity(0.05))
                .cornerRadius(12)
            }
        }
    }
    
    // MARK: - Shipping Info Section
    private var shippingInfoSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Shipping & Returns")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.primary)
            
            VStack(spacing: 8) {
                HStack {
                    Image(systemName: "truck")
                        .font(.system(size: 16))
                        .foregroundColor(.blue)
                        .frame(width: 24)
                    
                    Text(product.shippingInfo.formattedShippingCost)
                        .font(.system(size: 14))
                        .foregroundColor(.primary)
                    
                    Spacer()
                }
                
                HStack {
                    Image(systemName: "arrow.uturn.left")
                        .font(.system(size: 16))
                        .foregroundColor(.blue)
                        .frame(width: 24)
                    
                    Text("30-day return policy")
                        .font(.system(size: 14))
                        .foregroundColor(.primary)
                    
                    Spacer()
                }
            }
        }
    }
    
    // MARK: - Reviews Section
    private var reviewsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Reviews")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.primary)
                
                Spacer()
                
                Button("See All") {
                    // Navigate to reviews
                }
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.blue)
            }
            
            Text("Customer reviews will appear here")
                .font(.system(size: 14))
                .foregroundColor(.gray)
                .padding(.vertical, 20)
        }
    }
    
    // MARK: - Floating Add to Cart Button
    private var floatingAddToCartButton: some View {
        VStack {
            Spacer()
            
            HStack(spacing: 12) {
                // Quick Add Button
                Button(action: {
                    addToCartWithAnimation()
                }) {
                    Image(systemName: "plus")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(width: 50, height: 50)
                        .background(Color.blue)
                        .clipShape(Circle())
                        .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
                }
                .scaleEffect(addToCartAnimation ? 1.2 : 1.0)
                
                // Main Add to Cart Button
                Button(action: {
                    addToCartWithAnimation()
                }) {
                    HStack {
                        Image(systemName: "bag.badge.plus")
                            .font(.system(size: 16, weight: .semibold))
                        
                        Text("Add to Cart")
                            .font(.system(size: 16, weight: .semibold))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(Color.blue)
                    .cornerRadius(25)
                    .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
                }
                .scaleEffect(addToCartAnimation ? 1.05 : 1.0)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 34) // Safe area bottom
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.6), value: addToCartAnimation)
    }
    
    // MARK: - Helper Functions
    private func addToCartWithAnimation() {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
            addToCartAnimation = true
            store.addToCart(product, quantity: selectedQuantity)
        }
        
        // Haptic feedback
        let impact = UIImpactFeedbackGenerator(style: .medium)
        impact.impactOccurred()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                addToCartAnimation = false
            }
        }
    }
}

// MARK: - Preview
#Preview {
    ProductDetailView(product: Product(
        name: "Handwoven Bohemian Necklace",
        price: 45.99,
        imageURLs: [
            "https://images.unsplash.com/photo-1515562141207-7a88fb7ce338?w=400&h=400&fit=crop",
            "https://images.unsplash.com/photo-1506630448388-4e683c67ddb0?w=400&h=400&fit=crop"
        ],
        description: "Beautiful handwoven necklace with natural stones and sustainable materials. Perfect for any occasion.",
        detailedDescription: "This stunning bohemian necklace is meticulously handwoven using premium natural stones and sustainable cotton cord. Each piece is unique and crafted with care by skilled artisans. The necklace features genuine silver accents and is perfect for both casual and formal occasions. The adjustable design ensures a comfortable fit for all neck sizes.",
        category: .jewelry,
        sellerId: UUID(),
        rating: 4.8,
        reviewCount: 127,
        isFavorite: false,
        tags: ["boho", "natural", "handmade"],
        materials: ["Silver", "Natural stones", "Cotton cord"],
        dimensions: Product.ProductDimensions(length: 50, width: 3, height: 1, unit: "cm"),
        weight: 25.5,
        shippingInfo: Product.ShippingInfo(
            estimatedDelivery: "Ships in 2-3 business days",
            shippingCost: 0.0,
            freeShippingThreshold: 50.0,
            internationalShipping: true,
            expressShipping: true
        ),
        inventory: Product.ProductInventory(
            stockQuantity: 15,
            lowStockThreshold: 5,
            isInStock: true,
            maxOrderQuantity: 3
        ),
        customizationOptions: [
            Product.CustomizationOption(
                name: "Chain Length",
                options: ["45cm", "50cm", "55cm"],
                additionalCost: 0.0,
                isRequired: false
            )
        ],
        createdDate: Calendar.current.date(byAdding: .month, value: -2, to: Date()) ?? Date(),
        updatedDate: Date(),
        isAvailable: true,
        discount: nil,
        seoTitle: "Handwoven Bohemian Necklace - Natural Stones",
        seoDescription: "Beautiful handwoven bohemian necklace with natural stones and sustainable materials",
        isHandmade: true,
        isVintage: false,
        processingTime: "1-2 business days"
    ))
    .environmentObject(EstlyStore())
} 