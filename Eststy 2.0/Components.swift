import SwiftUI

// MARK: - Enhanced Product Card with Liquid Animations
struct ProductCardView: View {
    let product: Product
    @EnvironmentObject var store: EstlyStore
    @State private var isPressed = false
    @State private var isFavoritePressed = false
    @State private var isImageLoaded = false
    @State private var bounceAnimation = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Enhanced Product Image with Liquid Loading
            ZStack(alignment: .topTrailing) {
                // Image Container
                RoundedRectangle(cornerRadius: 16)
                    .fill(
                        LinearGradient(
                            colors: [Color.gray.opacity(0.1), Color.gray.opacity(0.05)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .aspectRatio(1, contentMode: .fit)
                    .overlay {
                        AsyncImage(url: URL(string: product.primaryImageURL)) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .clipped()
                                .onAppear {
                                    withAnimation(.spring(response: 0.8, dampingFraction: 0.8)) {
                                        isImageLoaded = true
                                    }
                                }
                        } placeholder: {
                            LiquidLoadingView()
                        }
                    }
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .overlay {
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.black.opacity(0.05), lineWidth: 1)
                    }
                    .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 4)
                
                // Stock Status Badge
                if !product.inventory.isInStock {
                    VStack {
                        HStack {
                            Spacer()
                            Text("Out of Stock")
                                .font(.caption.weight(.semibold))
                                .foregroundColor(.white)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(.red.opacity(0.9))
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                                .padding(8)
                        }
                        Spacer()
                    }
                }
                
                // Discount Badge
                if let discount = product.discount, discount.isActive {
                    VStack {
                        HStack {
                            Text("-\(Int(discount.percentage))%")
                                .font(.caption.weight(.bold))
                                .foregroundColor(.white)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(
                                    LinearGradient(
                                        colors: [.red, .orange],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                                .padding(8)
                            Spacer()
                        }
                        Spacer()
                    }
                }
                
                // Enhanced Favorite Button with Liquid Animation
                VStack {
                    HStack {
                        Spacer()
                        Button(action: {
                            let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                            impactFeedback.impactOccurred()
                            
                            withAnimation(.liquid(duration: 0.6)) {
                                isFavoritePressed = true
                                store.toggleWishlist(product)
                            }
                            
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                withAnimation(.liquid(duration: 0.4)) {
                                    isFavoritePressed = false
                                }
                            }
                        }) {
                            ZStack {
                                Circle()
                                    .fill(.ultraThinMaterial)
                                    .frame(width: 36, height: 36)
                                    .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                                
                                Image(systemName: store.isInWishlist(product) ? "heart.fill" : "heart")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundStyle(
                                        store.isInWishlist(product) 
                                        ? LinearGradient(colors: [.red, .pink], startPoint: .topLeading, endPoint: .bottomTrailing)
                                        : LinearGradient(colors: [.gray, .gray.opacity(0.8)], startPoint: .topLeading, endPoint: .bottomTrailing)
                                    )
                            }
                        }
                        .scaleEffect(isFavoritePressed ? 1.3 : 1.0)
                        .rotation3DEffect(
                            .degrees(isFavoritePressed ? 10 : 0),
                            axis: (x: 0, y: 1, z: 0)
                        )
                        .animation(.liquid(duration: 0.6), value: isFavoritePressed)
                        .animation(.liquid(duration: 0.4), value: store.isInWishlist(product))
                        .padding(12)
                    }
                    Spacer()
                }
            }
            
            // Enhanced Product Info with Liquid Typography
            VStack(alignment: .leading, spacing: 8) {
                Text(product.name)
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundColor(.primary)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                
                // Rating and Reviews with Enhanced Visuals
                HStack(spacing: 6) {
                    EnhancedRatingStarsView(rating: product.rating, size: 14)
                    Text("(\(product.reviewCount))")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Spacer()
                }
                
                // Enhanced Price Display
                LiquidPriceTagView(product: product)
                
                // Seller Info
                Text("by \(store.getSellerForProduct(product)?.name ?? "Unknown")")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .opacity(0.8)
            }
            .padding(.horizontal, 4)
        }
        .background(.clear)
        .scaleEffect(isPressed ? 0.95 : 1.0)
        .rotation3DEffect(
            .degrees(isPressed ? 2 : 0),
            axis: (x: 1, y: 0, z: 0)
        )
        .animation(.liquid(duration: 0.4), value: isPressed)
        .onTapGesture {
            withAnimation(.liquid(duration: 0.3)) {
                isPressed = true
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.liquid(duration: 0.3)) {
                    isPressed = false
                }
            }
        }
        .onAppear {
            withAnimation(.liquid(duration: 0.8).delay(Double.random(in: 0...0.5))) {
                bounceAnimation = true
            }
        }
    }
}

// MARK: - Liquid Loading View
struct LiquidLoadingView: View {
    @State private var animateGradient = false
    @State private var scale = 0.8
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16)
                .fill(
                    LinearGradient(
                        colors: [.gray.opacity(0.2), .gray.opacity(0.1), .gray.opacity(0.3)],
                        startPoint: animateGradient ? .topLeading : .bottomTrailing,
                        endPoint: animateGradient ? .bottomTrailing : .topLeading
                    )
                )
                .scaleEffect(scale)
                .animation(
                    .easeInOut(duration: 1.5).repeatForever(autoreverses: true),
                    value: animateGradient
                )
                .animation(
                    .easeInOut(duration: 2.0).repeatForever(autoreverses: true),
                    value: scale
                )
            
            Image(systemName: "photo")
                .font(.system(size: 40, weight: .light))
                .foregroundColor(.gray.opacity(0.4))
                .scaleEffect(scale)
                .animation(
                    .easeInOut(duration: 2.0).repeatForever(autoreverses: true),
                    value: scale
                )
        }
        .onAppear {
            animateGradient = true
            scale = 1.1
        }
    }
}

// MARK: - Enhanced Search Bar with Liquid Morphing
struct LiquidSearchBarView: View {
    @Binding var searchText: String
    @FocusState private var isSearchFocused: Bool
    @State private var isAnimating = false
    
    var body: some View {
        HStack(spacing: 12) {
            // Search Icon with Liquid Animation
            ZStack {
                Circle()
                    .fill(.ultraThinMaterial)
                    .frame(width: 40, height: 40)
                    .scaleEffect(isSearchFocused ? 1.1 : 1.0)
                    .animation(.liquid(duration: 0.6), value: isSearchFocused)
                
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundStyle(
                        LinearGradient(
                            colors: isSearchFocused ? [.blue, .purple] : [.gray, .gray.opacity(0.7)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .scaleEffect(isSearchFocused ? 1.1 : 1.0)
                    .animation(.liquid(duration: 0.6), value: isSearchFocused)
            }
            
            // Enhanced Text Field with Liquid Background
            TextField("Search handcrafted treasures...", text: $searchText)
                .font(.system(size: 16, design: .rounded))
                .focused($isSearchFocused)
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(.ultraThinMaterial)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(
                                    LinearGradient(
                                        colors: isSearchFocused ? [.blue.opacity(0.6), .purple.opacity(0.6)] : [.gray.opacity(0.2), .gray.opacity(0.1)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: isSearchFocused ? 2 : 1
                                )
                        )
                        .shadow(
                            color: isSearchFocused ? .blue.opacity(0.2) : .black.opacity(0.05),
                            radius: isSearchFocused ? 8 : 4,
                            x: 0,
                            y: isSearchFocused ? 4 : 2
                        )
                )
                .scaleEffect(isSearchFocused ? 1.02 : 1.0)
                .animation(.liquid(duration: 0.6), value: isSearchFocused)
            
            // Clear Button with Liquid Animation
            if !searchText.isEmpty {
                Button(action: {
                    withAnimation(.liquid(duration: 0.4)) {
                        searchText = ""
                    }
                    let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                    impactFeedback.impactOccurred()
                }) {
                    ZStack {
                        Circle()
                            .fill(.ultraThinMaterial)
                            .frame(width: 28, height: 28)
                        
                        Image(systemName: "xmark")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(.gray)
                    }
                }
                .transition(.scale.combined(with: .opacity))
                .animation(.liquid(duration: 0.4), value: searchText.isEmpty)
            }
        }
        .padding(.horizontal, 16)
    }
}

// MARK: - Enhanced Category Chip with Liquid Morphing
struct LiquidCategoryChipView: View {
    let category: ProductCategory
    let isSelected: Bool
    let action: () -> Void
    @State private var isPressed = false
    
    var body: some View {
        Button(action: {
            let impactFeedback = UIImpactFeedbackGenerator(style: .light)
            impactFeedback.impactOccurred()
            
            withAnimation(.liquid(duration: 0.6)) {
                isPressed = true
                action()
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                withAnimation(.liquid(duration: 0.4)) {
                    isPressed = false
                }
            }
        }) {
            HStack(spacing: 8) {
                ZStack {
                    Circle()
                        .fill(
                            isSelected 
                            ? LinearGradient(colors: category.gradient, startPoint: .topLeading, endPoint: .bottomTrailing)
                            : LinearGradient(colors: [.gray.opacity(0.1), .gray.opacity(0.05)], startPoint: .topLeading, endPoint: .bottomTrailing)
                        )
                        .frame(width: 24, height: 24)
                    
                    Image(systemName: category.systemImage)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(isSelected ? .white : .gray)
                }
                
                Text(category.rawValue)
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundColor(isSelected ? .white : .primary)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 25)
                    .fill(
                        isSelected 
                        ? LinearGradient(colors: category.gradient, startPoint: .topLeading, endPoint: .bottomTrailing)
                        : LinearGradient(colors: [.gray.opacity(0.08), .gray.opacity(0.04)], startPoint: .topLeading, endPoint: .bottomTrailing)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 25)
                            .stroke(
                                isSelected ? .clear : .gray.opacity(0.2),
                                lineWidth: 1
                            )
                    )
                    .shadow(
                        color: isSelected ? category.gradient.first?.opacity(0.3) ?? .clear : .black.opacity(0.05),
                        radius: isSelected ? 8 : 2,
                        x: 0,
                        y: isSelected ? 4 : 1
                    )
            )
        }
        .scaleEffect(isPressed ? 0.95 : 1.0)
        .rotation3DEffect(
            .degrees(isPressed ? 5 : 0),
            axis: (x: 0, y: 1, z: 0)
        )
        .animation(.liquid(duration: 0.6), value: isPressed)
        .animation(.liquid(duration: 0.4), value: isSelected)
    }
}

// MARK: - Liquid Button Component
struct LiquidButton: View {
    let title: String
    let action: () -> Void
    var style: ButtonStyle = .primary
    var size: ButtonSize = .medium
    var isLoading: Bool = false
    @State private var isPressed = false
    @State private var rippleScale: CGFloat = 0
    
    enum ButtonStyle {
        case primary, secondary, tertiary, destructive, glass
        
        var colors: [Color] {
            switch self {
            case .primary: return [.blue, .purple]
            case .secondary: return [.gray.opacity(0.1), .gray.opacity(0.05)]
            case .tertiary: return [.clear]
            case .destructive: return [.red, .orange]
            case .glass: return [.white.opacity(0.1), .white.opacity(0.05)]
            }
        }
        
        var foregroundColor: Color {
            switch self {
            case .primary: return .white
            case .secondary: return .primary
            case .tertiary: return .blue
            case .destructive: return .white
            case .glass: return .primary
            }
        }
        
        var hasBorder: Bool {
            switch self {
            case .tertiary: return true
            default: return false
            }
        }
    }
    
    enum ButtonSize {
        case small, medium, large, extraLarge
        
        var padding: EdgeInsets {
            switch self {
            case .small: return EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16)
            case .medium: return EdgeInsets(top: 12, leading: 24, bottom: 12, trailing: 24)
            case .large: return EdgeInsets(top: 16, leading: 32, bottom: 16, trailing: 32)
            case .extraLarge: return EdgeInsets(top: 20, leading: 40, bottom: 20, trailing: 40)
            }
        }
        
        var fontSize: CGFloat {
            switch self {
            case .small: return 12
            case .medium: return 16
            case .large: return 18
            case .extraLarge: return 20
            }
        }
        
        var cornerRadius: CGFloat {
            switch self {
            case .small: return 12
            case .medium: return 16
            case .large: return 20
            case .extraLarge: return 24
            }
        }
    }
    
    var body: some View {
        Button(action: {
            let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
            impactFeedback.impactOccurred()
            
            withAnimation(.liquid(duration: 0.6)) {
                isPressed = true
                rippleScale = 1.0
            }
            
            action()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                withAnimation(.liquid(duration: 0.4)) {
                    isPressed = false
                    rippleScale = 0
                }
            }
        }) {
            ZStack {
                // Main Button Background
                RoundedRectangle(cornerRadius: size.cornerRadius)
                    .fill(
                        LinearGradient(
                            colors: style.colors,
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: size.cornerRadius)
                            .stroke(
                                style.hasBorder ? .blue.opacity(0.6) : .clear,
                                lineWidth: 2
                            )
                    )
                    .shadow(
                        color: style == .primary || style == .destructive ? style.colors.first?.opacity(0.3) ?? .clear : .black.opacity(0.1),
                        radius: isPressed ? 12 : 8,
                        x: 0,
                        y: isPressed ? 6 : 4
                    )
                
                // Ripple Effect
                if rippleScale > 0 {
                    RoundedRectangle(cornerRadius: size.cornerRadius)
                        .fill(Color.white.opacity(0.3))
                        .scaleEffect(rippleScale)
                        .animation(.easeOut(duration: 0.6), value: rippleScale)
                }
                
                // Button Content
                HStack(spacing: 8) {
                    if isLoading {
                        LiquidLoadingSpinner(size: size.fontSize * 0.8, color: style.foregroundColor)
                    }
                    
                    Text(title)
                        .font(.system(size: size.fontSize, weight: .semibold, design: .rounded))
                        .foregroundColor(style.foregroundColor)
                }
                .padding(size.padding)
            }
        }
        .scaleEffect(isPressed ? 0.96 : 1.0)
        .rotation3DEffect(
            .degrees(isPressed ? 3 : 0),
            axis: (x: 1, y: 0, z: 0)
        )
        .animation(.liquid(duration: 0.6), value: isPressed)
        .disabled(isLoading)
    }
}

// MARK: - Liquid Loading Spinner
struct LiquidLoadingSpinner: View {
    let size: CGFloat
    let color: Color
    @State private var rotation: Double = 0
    @State private var scale: CGFloat = 1.0
    
    var body: some View {
        ZStack {
            Circle()
                .trim(from: 0, to: 0.8)
                .stroke(
                    LinearGradient(
                        colors: [color, color.opacity(0.3)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    style: StrokeStyle(lineWidth: 2, lineCap: .round)
                )
                .frame(width: size, height: size)
                .rotationEffect(.degrees(rotation))
                .scaleEffect(scale)
        }
        .onAppear {
            withAnimation(.linear(duration: 1.0).repeatForever(autoreverses: false)) {
                rotation = 360
            }
            withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                scale = 1.2
            }
        }
    }
}

// MARK: - Enhanced Rating Stars with Liquid Animation
struct EnhancedRatingStarsView: View {
    let rating: Double
    let size: CGFloat
    @State private var animatedRating: Double = 0
    
    init(rating: Double, size: CGFloat = 14) {
        self.rating = rating
        self.size = size
    }
    
    var body: some View {
        HStack(spacing: 2) {
            ForEach(0..<5, id: \.self) { index in
                ZStack {
                    // Background star
                    Image(systemName: "star.fill")
                        .font(.system(size: size, weight: .medium))
                        .foregroundStyle(.gray.opacity(0.2))
                    
                    // Filled star with gradient
                    Image(systemName: "star.fill")
                        .font(.system(size: size, weight: .medium))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.yellow, .orange],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .mask(
                            Rectangle()
                                .size(width: size * min(max(animatedRating - Double(index), 0), 1), height: size)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        )
                        .shadow(color: .yellow.opacity(0.5), radius: 2, x: 0, y: 1)
                }
                .scaleEffect(animatedRating > Double(index) ? 1.1 : 1.0)
                .animation(
                    .liquid(duration: 0.6).delay(Double(index) * 0.1),
                    value: animatedRating
                )
            }
        }
        .onAppear {
            withAnimation(.liquid(duration: 1.0)) {
                animatedRating = rating
            }
        }
    }
}

// MARK: - Liquid Price Tag with Enhanced Styling
struct LiquidPriceTagView: View {
    let product: Product
    @State private var priceAnimation = false
    
    var body: some View {
        HStack(spacing: 8) {
            if let discountedPrice = product.formattedDiscountedPrice {
                // Discounted Price
                Text(discountedPrice)
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.red, .orange],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .scaleEffect(priceAnimation ? 1.05 : 1.0)
                
                // Original Price
                Text(product.formattedPrice)
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundColor(.gray)
                    .strikethrough(true, color: .gray)
                
                // Savings Badge
                if let savings = product.saveAmount {
                    Text(savings)
                        .font(.caption.weight(.semibold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(.green.opacity(0.8))
                        .clipShape(RoundedRectangle(cornerRadius: 4))
                        .scaleEffect(priceAnimation ? 1.1 : 1.0)
                }
            } else {
                Text(product.formattedPrice)
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.primary, .primary.opacity(0.8)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .scaleEffect(priceAnimation ? 1.05 : 1.0)
            }
        }
        .animation(.liquid(duration: 0.8), value: priceAnimation)
        .onAppear {
            withAnimation(.liquid(duration: 0.8).delay(0.3)) {
                priceAnimation = true
            }
        }
    }
}

// MARK: - Floating Notification Banner
struct FloatingNotificationBanner: View {
    let notification: AppNotification
    let onTap: () -> Void
    let onDismiss: () -> Void
    @State private var dragOffset: CGFloat = 0
    @State private var isVisible = false
    
    var body: some View {
        HStack(spacing: 12) {
            // Notification Icon
            ZStack {
                Circle()
                    .fill(notification.type.color.opacity(0.2))
                    .frame(width: 40, height: 40)
                
                Image(systemName: notification.type.icon)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(notification.type.color)
            }
            
            // Notification Content
            VStack(alignment: .leading, spacing: 4) {
                Text(notification.title)
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundColor(.primary)
                    .lineLimit(1)
                
                Text(notification.message)
                    .font(.system(size: 12, design: .rounded))
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
            
            Spacer()
            
            // Time
            Text(notification.timeAgo)
                .font(.caption2)
                .foregroundColor(.gray)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
                .shadow(color: .black.opacity(0.1), radius: 12, x: 0, y: 6)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(.gray.opacity(0.2), lineWidth: 1)
        )
        .scaleEffect(isVisible ? 1.0 : 0.8)
        .offset(x: dragOffset)
        .gesture(
            DragGesture()
                .onChanged { value in
                    dragOffset = value.translation.width
                }
                .onEnded { value in
                    if abs(value.translation.width) > 100 {
                        withAnimation(.liquid(duration: 0.4)) {
                            dragOffset = value.translation.width > 0 ? 300 : -300
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                            onDismiss()
                        }
                    } else {
                        withAnimation(.liquid(duration: 0.4)) {
                            dragOffset = 0
                        }
                    }
                }
        )
        .onTapGesture {
            onTap()
        }
        .onAppear {
            withAnimation(.liquid(duration: 0.6)) {
                isVisible = true
            }
        }
    }
}

// MARK: - Advanced Empty State with Liquid Animation
struct LiquidEmptyStateView: View {
    let title: String
    let message: String
    let systemImage: String
    let actionTitle: String?
    let action: (() -> Void)?
    @State private var bounceAnimation = false
    @State private var textAnimation = false
    
    var body: some View {
        VStack(spacing: 24) {
            // Animated Icon
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [.gray.opacity(0.1), .gray.opacity(0.05)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 120, height: 120)
                    .scaleEffect(bounceAnimation ? 1.1 : 1.0)
                
                Image(systemName: systemImage)
                    .font(.system(size: 48, weight: .light))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.gray.opacity(0.6), .gray.opacity(0.4)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .scaleEffect(bounceAnimation ? 1.05 : 1.0)
            }
            .animation(
                .easeInOut(duration: 2.0).repeatForever(autoreverses: true),
                value: bounceAnimation
            )
            
            // Text Content
            VStack(spacing: 12) {
                Text(title)
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
                    .opacity(textAnimation ? 1.0 : 0.0)
                    .offset(y: textAnimation ? 0 : 20)
                
                Text(message)
                    .font(.system(size: 16, design: .rounded))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
                    .opacity(textAnimation ? 1.0 : 0.0)
                    .offset(y: textAnimation ? 0 : 20)
            }
            .animation(.liquid(duration: 0.8).delay(0.3), value: textAnimation)
            
            // Action Button
            if let actionTitle = actionTitle, let action = action {
                LiquidButton(
                    title: actionTitle,
                    action: action,
                    style: .primary,
                    size: .medium
                )
                .opacity(textAnimation ? 1.0 : 0.0)
                .offset(y: textAnimation ? 0 : 20)
                .animation(.liquid(duration: 0.8).delay(0.6), value: textAnimation)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(UIColor.systemBackground))
        .onAppear {
            bounceAnimation = true
            withAnimation(.liquid(duration: 0.8).delay(0.2)) {
                textAnimation = true
            }
        }
    }
}

// MARK: - Liquid Progress Bar
struct LiquidProgressBar: View {
    let progress: Double
    let color: Color
    @State private var animatedProgress: Double = 0
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // Background
                RoundedRectangle(cornerRadius: 8)
                    .fill(color.opacity(0.2))
                    .frame(height: 8)
                
                // Progress Fill
                RoundedRectangle(cornerRadius: 8)
                    .fill(
                        LinearGradient(
                            colors: [color, color.opacity(0.8)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: geometry.size.width * animatedProgress, height: 8)
                    .animation(.liquid(duration: 1.0), value: animatedProgress)
            }
        }
        .frame(height: 8)
        .onAppear {
            withAnimation(.liquid(duration: 1.0).delay(0.2)) {
                animatedProgress = progress
            }
        }
        .onChange(of: progress) { newValue in
            withAnimation(.liquid(duration: 0.8)) {
                animatedProgress = newValue
            }
        }
    }
}

// MARK: - Enhanced Cart Badge with Liquid Animation
struct LiquidCartBadgeView: View {
    let count: Int
    @State private var pulseAnimation = false
    
    var body: some View {
        ZStack {
            Circle()
                .fill(
                    LinearGradient(
                        colors: [.red, .orange],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 22, height: 22)
                .scaleEffect(pulseAnimation ? 1.2 : 1.0)
                .shadow(color: .red.opacity(0.4), radius: 4, x: 0, y: 2)
            
            Text("\(count)")
                .font(.system(size: 11, weight: .bold, design: .rounded))
                .foregroundColor(.white)
        }
        .opacity(count > 0 ? 1 : 0)
        .scaleEffect(count > 0 ? 1 : 0.1)
        .animation(.liquid(duration: 0.6), value: count > 0)
        .animation(
            .easeInOut(duration: 0.8).repeatForever(autoreverses: true),
            value: pulseAnimation
        )
        .onAppear {
            if count > 0 {
                pulseAnimation = true
            }
        }
        .onChange(of: count) { newCount in
            if newCount > 0 && !pulseAnimation {
                pulseAnimation = true
            } else if newCount == 0 {
                pulseAnimation = false
            }
        }
    }
}

// MARK: - Custom Liquid Animation Extension
extension Animation {
    static func liquid(duration: Double) -> Animation {
        .timingCurve(0.2, 0.8, 0.2, 1.0, duration: duration)
    }
}

// MARK: - View Extensions
extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
    func liquidTransition() -> some View {
        self.transition(
            .asymmetric(
                insertion: .scale(scale: 0.8).combined(with: .opacity),
                removal: .scale(scale: 1.2).combined(with: .opacity)
            )
        )
    }
    
    func liquidShadow(color: Color = .black, radius: CGFloat = 8, x: CGFloat = 0, y: CGFloat = 4) -> some View {
        self.shadow(color: color.opacity(0.1), radius: radius, x: x, y: y)
    }
}

// MARK: - Custom Shapes for Liquid Effects
struct LiquidShape: Shape {
    var animatableData: Double
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        let wave1 = sin(animatableData * .pi * 2) * 10
        let wave2 = cos(animatableData * .pi * 1.5) * 15
        
        path.move(to: CGPoint(x: 0, y: rect.height / 2))
        
        path.addCurve(
            to: CGPoint(x: rect.width, y: rect.height / 2),
            control1: CGPoint(x: rect.width * 0.3, y: rect.height / 2 + wave1),
            control2: CGPoint(x: rect.width * 0.7, y: rect.height / 2 + wave2)
        )
        
        path.addLine(to: CGPoint(x: rect.width, y: rect.height))
        path.addLine(to: CGPoint(x: 0, y: rect.height))
        path.closeSubpath()
        
        return path
    }
} 