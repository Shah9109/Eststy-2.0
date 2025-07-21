import SwiftUI

struct SellerProfileView: View {
    let seller: Seller
    @EnvironmentObject var store: EstlyStore
    @Environment(\.dismiss) private var dismiss
    @State private var selectedProduct: Product?
    @State private var showingProductDetail = false
    @State private var selectedTab = 0
    
    private let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]
    
    var sellerProducts: [Product] {
        store.getProductsBySeller(seller.id)
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Seller Header
                    sellerHeader
                    
                    // Stats Section
                    sellerStats
                    
                    // Tab Selection
                    tabSelection
                    
                    // Content based on selected tab
                    tabContent
                }
                .padding(.horizontal, 16)
                .padding(.top, 20)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
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
                    Button(action: {
                        // Share seller profile
                    }) {
                        Image(systemName: "square.and.arrow.up")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.primary)
                            .frame(width: 32, height: 32)
                            .background(Color(UIColor.systemBackground).opacity(0.8))
                            .clipShape(Circle())
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
    }
    
    // MARK: - Seller Header
    private var sellerHeader: some View {
        VStack(spacing: 16) {
            // Profile Image and Basic Info
            HStack(spacing: 16) {
                // Profile Image
                ZStack {
                    Circle()
                        .fill(Color.gray.opacity(0.1))
                        .frame(width: 80, height: 80)
                    
                    Text(String(seller.name.prefix(1)))
                        .font(.system(size: 32))
                }
                
                // Seller Info
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(seller.shopName)
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.primary)
                        
                        if seller.isVerified {
                            Image(systemName: "checkmark.seal.fill")
                                .font(.system(size: 16))
                                .foregroundColor(.blue)
                        }
                    }
                    
                    Text("by \(seller.name)")
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                    
                    Text("\(seller.location.city), \(seller.location.state)")
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                    
                    // Rating
                    HStack(spacing: 4) {
                        EnhancedRatingStarsView(rating: seller.rating, size: 14)
                        
                        Text(String(format: "%.1f", seller.rating))
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.primary)
                        
                        Text("(\(seller.totalSales) sales)")
                            .font(.system(size: 12))
                            .foregroundColor(.gray)
                    }
                }
                
                Spacer()
            }
            
            // Bio
            Text(seller.bio)
                .font(.system(size: 16))
                .foregroundColor(.primary)
                .lineSpacing(4)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            // Specialties
            if !seller.specialties.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(seller.specialties, id: \.self) { specialty in
                            Text(specialty)
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.blue)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.blue.opacity(0.1))
                                .clipShape(Capsule())
                        }
                    }
                    .padding(.horizontal, 16)
                }
                .padding(.horizontal, -16)
            }
        }
    }
    
    // MARK: - Seller Stats
    private var sellerStats: some View {
        HStack(spacing: 20) {
            StatColumn(
                title: "Products",
                value: "\(sellerProducts.count)",
                icon: "cube.box"
            )
            
            StatColumn(
                title: "Rating",
                value: String(format: "%.1f", seller.rating),
                icon: "star.fill"
            )
            
            StatColumn(
                title: "Sales",
                value: "\(seller.totalSales)",
                icon: "cart.fill"
            )
            
            StatColumn(
                title: "Member",
                value: "\(yearsActive) yr\(yearsActive != 1 ? "s" : "")",
                icon: "calendar"
            )
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 20)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(UIColor.secondarySystemBackground))
        )
    }
    
    private var yearsActive: Int {
        let calendar = Calendar.current
        let years = calendar.dateComponents([.year], from: seller.joinedDate, to: Date()).year ?? 0
        return max(1, years)
    }
    
    // MARK: - Tab Selection
    private var tabSelection: some View {
        HStack(spacing: 0) {
            TabButton(
                title: "Products (\(sellerProducts.count))",
                isSelected: selectedTab == 0
            ) {
                withAnimation(.easeInOut(duration: 0.2)) {
                    selectedTab = 0
                }
            }
            
            TabButton(
                title: "Reviews",
                isSelected: selectedTab == 1
            ) {
                withAnimation(.easeInOut(duration: 0.2)) {
                    selectedTab = 1
                }
            }
            
            TabButton(
                title: "About",
                isSelected: selectedTab == 2
            ) {
                withAnimation(.easeInOut(duration: 0.2)) {
                    selectedTab = 2
                }
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(UIColor.secondarySystemBackground))
        )
    }
    
    // MARK: - Tab Content
    private var tabContent: some View {
        Group {
            switch selectedTab {
            case 0:
                productsTab
            case 1:
                reviewsTab
            case 2:
                aboutTab
            default:
                productsTab
            }
        }
        .animation(.easeInOut(duration: 0.3), value: selectedTab)
    }
    
    // MARK: - Products Tab
    private var productsTab: some View {
        LazyVGrid(columns: columns, spacing: 16) {
            ForEach(sellerProducts) { product in
                ProductCardView(product: product)
                    .environmentObject(store)
                    .onTapGesture {
                        selectedProduct = product
                        showingProductDetail = true
                    }
            }
        }
        .transition(.opacity)
    }
    
    // MARK: - Reviews Tab
    private var reviewsTab: some View {
        VStack(spacing: 16) {
            // Review Summary
            VStack(spacing: 12) {
                HStack {
                    Text("Customer Reviews")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.primary)
                    
                    Spacer()
                }
                
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            EnhancedRatingStarsView(rating: seller.rating, size: 20)
                            
                            Text(String(format: "%.1f", seller.rating))
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.primary)
                        }
                        
                        Text("Based on \(seller.totalSales) reviews")
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                    }
                    
                    Spacer()
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 20)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(UIColor.secondarySystemBackground))
            )
            
            // Individual Reviews (placeholder)
            Text("Individual reviews will appear here")
                .font(.system(size: 16))
                .foregroundColor(.gray)
                .padding(.vertical, 40)
        }
        .transition(.opacity)
    }
    
    // MARK: - About Tab
    private var aboutTab: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Shop Policies
            VStack(alignment: .leading, spacing: 12) {
                Text("Shop Policies")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.primary)
                
                VStack(spacing: 8) {
                    PolicyRow(
                        icon: "truck",
                        title: "Shipping",
                        description: "Ships worldwide, 2-7 business days"
                    )
                    
                    PolicyRow(
                        icon: "arrow.uturn.left",
                        title: "Returns",
                        description: "30-day return policy"
                    )
                    
                    PolicyRow(
                        icon: "creditcard",
                        title: "Payment",
                        description: "Secure payment processing"
                    )
                }
            }
            
            // Shop Details
            VStack(alignment: .leading, spacing: 12) {
                Text("Shop Details")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.primary)
                
                VStack(spacing: 8) {
                    DetailRow(title: "Member since", value: seller.formattedJoinedDate)
                    DetailRow(title: "Location", value: "\(seller.location.city), \(seller.location.state)")
                    DetailRow(title: "Total sales", value: "\(seller.totalSales)")
                    DetailRow(title: "Verified seller", value: seller.isVerified ? "Yes" : "No")
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .transition(.opacity)
    }
}

// MARK: - Supporting Components
struct StatColumn: View {
    let title: String
    let value: String
    let icon: String
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.blue)
            
            Text(value)
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.primary)
            
            Text(title)
                .font(.system(size: 12))
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
    }
}

struct TabButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 14, weight: isSelected ? .semibold : .medium))
                .foregroundColor(isSelected ? .white : .primary)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 6)
                        .fill(isSelected ? Color.blue : Color.clear)
                )
        }
    }
}

struct PolicyRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.blue)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.primary)
                
                Text(description)
                    .font(.system(size: 12))
                    .foregroundColor(.gray)
            }
            
            Spacer()
        }
    }
}

struct DetailRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(.system(size: 14))
                .foregroundColor(.gray)
            
            Spacer()
            
            Text(value)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.primary)
        }
    }
}

// MARK: - Preview
#Preview {
    SellerProfileView(seller: Seller(
        name: "Emma Rodriguez",
        shopName: "Emma's Handcrafted Treasures",
        profileImageURL: "https://images.unsplash.com/photo-1494790108755-2616b612b787?w=150&h=150&fit=crop&crop=face",
        coverImageURL: "https://images.unsplash.com/photo-1513475382585-d06e58bcb0e0?w=800&h=300&fit=crop",
        bio: "Specializing in unique handmade jewelry and accessories with sustainable materials.",
        detailedBio: "Emma Rodriguez is a passionate artisan who has been creating beautiful handmade jewelry for over 5 years. She specializes in unique, one-of-a-kind pieces made with sustainable materials. Each piece tells a story and is crafted with love and attention to detail. Emma draws inspiration from nature and travels to create jewelry that speaks to the soul.",
        rating: 4.8,
        totalSales: 1250,
        totalReviews: 342,
        joinedDate: Calendar.current.date(byAdding: .year, value: -3, to: Date()) ?? Date(),
        location: Address(
            title: "Business",
            firstName: "Emma",
            lastName: "Rodriguez",
            street: "123 Artisan Way",
            city: "Portland",
            state: "OR",
            zipCode: "97201",
            country: "USA",
            isDefault: true,
            isPrimary: true,
            addressType: .work
        ),
        specialties: ["Jewelry", "Eco-friendly", "Custom Design"],
        isVerified: true,
        isActive: true,
        socialMediaLinks: Seller.SocialMediaLinks(
            website: "https://emmastreasures.com",
            instagram: "https://instagram.com/emmascrafts",
            facebook: nil,
            twitter: nil,
            pinterest: "https://pinterest.com/emmascrafts",
            etsy: "https://etsy.com/shop/emmascrafts"
        ),
        policies: Seller.SellerPolicies(
            returnPolicy: "30-day return policy on all items",
            exchangePolicy: "Exchanges accepted within 14 days",
            privacyPolicy: "We protect your privacy and never share your data",
            shippingPolicy: "Items ship within 1-2 business days",
            customOrderPolicy: "Custom orders welcome, contact for pricing"
        ),
        certifications: ["Artisan Certified", "Sustainable Materials"],
        awards: ["Best Handmade Jewelry 2023", "Customer Choice Award"],
        responseTime: "Usually responds within 2 hours",
        languages: ["English", "Spanish"]
    ))
    .environmentObject(EstlyStore())
} 