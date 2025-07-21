import Foundation
import SwiftUI

// MARK: - Category Enum
enum ProductCategory: String, CaseIterable, Identifiable, Codable {
    case jewelry = "Jewelry"
    case homeDecor = "Home Decor"
    case art = "Art"
    case clothing = "Clothing"
    case accessories = "Accessories"
    case handmade = "Handmade"
    case vintage = "Vintage"
    case crafts = "Crafts"
    case pottery = "Pottery"
    case textiles = "Textiles"
    
    var id: String { self.rawValue }
    
    var systemImage: String {
        switch self {
        case .jewelry: return "sparkles"
        case .homeDecor: return "house.fill"
        case .art: return "paintbrush.fill"
        case .clothing: return "tshirt.fill"
        case .accessories: return "bag.fill"
        case .handmade: return "hands.sparkles.fill"
        case .vintage: return "clock.fill"
        case .crafts: return "hammer.fill"
        case .pottery: return "circle.circle"
        case .textiles: return "scissors"
        }
    }
    
    var gradient: [Color] {
        switch self {
        case .jewelry: return [Color.purple, Color.pink]
        case .homeDecor: return [Color.blue, Color.cyan]
        case .art: return [Color.red, Color.orange]
        case .clothing: return [Color.green, Color.mint]
        case .accessories: return [Color.brown, Color.orange]
        case .handmade: return [Color.purple, Color.blue]
        case .vintage: return [Color.yellow, Color.orange]
        case .crafts: return [Color.red, Color.pink]
        case .pottery: return [Color.brown, Color.yellow]
        case .textiles: return [Color.indigo, Color.purple]
        }
    }
}

// MARK: - Authentication Models
struct AuthUser: Identifiable, Codable {
    let id = UUID()
    var email: String
    var username: String
    var displayName: String
    var profileImageURL: String?
    var isEmailVerified: Bool
    var provider: AuthProvider
    var lastLoginDate: Date
    var createdDate: Date
    var isActive: Bool
    
    enum AuthProvider: String, Codable {
        case email = "email"
        case google = "google"
        case apple = "apple"
        case facebook = "facebook"
    }
}

struct LoginCredentials: Codable {
    let email: String
    let password: String
}

struct RegisterCredentials: Codable {
    let email: String
    let password: String
    let username: String
    let displayName: String
}

// MARK: - Enhanced Product Model
struct Product: Identifiable, Codable, Hashable {
    let id = UUID()
    let name: String
    let price: Double
    let imageURLs: [String] // Multiple images with real URLs
    let description: String
    let detailedDescription: String
    let category: ProductCategory
    let sellerId: UUID
    let rating: Double
    let reviewCount: Int
    var isFavorite: Bool
    let tags: [String]
    let materials: [String]
    let dimensions: ProductDimensions?
    let weight: Double?
    let shippingInfo: ShippingInfo
    let inventory: ProductInventory
    let customizationOptions: [CustomizationOption]
    let createdDate: Date
    let updatedDate: Date
    let isAvailable: Bool
    let discount: Discount?
    let seoTitle: String
    let seoDescription: String
    let isHandmade: Bool
    let isVintage: Bool
    let processingTime: String
    
    struct ProductDimensions: Codable, Hashable {
        let length: Double
        let width: Double
        let height: Double
        let unit: String // "cm", "inches"
        
        var formatted: String {
            return "\(length) × \(width) × \(height) \(unit)"
        }
    }
    
    struct ShippingInfo: Codable, Hashable {
        let estimatedDelivery: String
        let shippingCost: Double
        let freeShippingThreshold: Double?
        let internationalShipping: Bool
        let expressShipping: Bool
        
        var formattedShippingCost: String {
            return shippingCost == 0 ? "Free Shipping" : String(format: "$%.2f", shippingCost)
        }
    }
    
    struct ProductInventory: Codable, Hashable {
        let stockQuantity: Int
        let lowStockThreshold: Int
        let isInStock: Bool
        let maxOrderQuantity: Int
        
        var stockStatus: String {
            if !isInStock { return "Out of Stock" }
            if stockQuantity <= lowStockThreshold { return "Low Stock" }
            return "In Stock"
        }
    }
    
    struct CustomizationOption: Identifiable, Codable, Hashable {
        let id = UUID()
        let name: String
        let options: [String]
        let additionalCost: Double
        let isRequired: Bool
    }
    
    struct Discount: Codable, Hashable {
        let percentage: Double
        let startDate: Date
        let endDate: Date
        let isActive: Bool
        
        var discountedPrice: Double {
            guard isActive && Date() >= startDate && Date() <= endDate else { return 0 }
            return percentage / 100
        }
    }
    
    var primaryImageURL: String {
        return imageURLs.first ?? "https://via.placeholder.com/300x300/E5E5E5/9E9E9E?text=No+Image"
    }
    
    var formattedPrice: String {
        return String(format: "$%.2f", price)
    }
    
    var discountedPrice: Double? {
        guard let discount = discount, discount.isActive else { return nil }
        let discountAmount = price * discount.discountedPrice
        return price - discountAmount
    }
    
    var formattedDiscountedPrice: String? {
        guard let discounted = discountedPrice else { return nil }
        return String(format: "$%.2f", discounted)
    }
    
    var saveAmount: String? {
        guard let discounted = discountedPrice else { return nil }
        let saved = price - discounted
        return String(format: "Save $%.2f", saved)
    }
}

// MARK: - Enhanced Seller Model
struct Seller: Identifiable, Codable, Hashable {
    let id = UUID()
    let name: String
    let shopName: String
    let profileImageURL: String
    let coverImageURL: String
    let bio: String
    let detailedBio: String
    let rating: Double
    let totalSales: Int
    let totalReviews: Int
    let joinedDate: Date
    let location: Address
    let specialties: [String]
    let isVerified: Bool
    let isActive: Bool
    let socialMediaLinks: SocialMediaLinks
    let policies: SellerPolicies
    let certifications: [String]
    let awards: [String]
    let responseTime: String
    let languages: [String]
    
    struct SocialMediaLinks: Codable, Hashable {
        let website: String?
        let instagram: String?
        let facebook: String?
        let twitter: String?
        let pinterest: String?
        let etsy: String?
    }
    
    struct SellerPolicies: Codable, Hashable {
        let returnPolicy: String
        let exchangePolicy: String
        let privacyPolicy: String
        let shippingPolicy: String
        let customOrderPolicy: String
    }
    
    var formattedJoinedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: joinedDate)
    }
    
    var averageRating: String {
        return String(format: "%.1f", rating)
    }
}

// MARK: - Enhanced User Model
struct User: Identifiable, Codable {
    let id = UUID()
    var name: String
    var email: String
    var username: String
    var profileImageURL: String?
    var phoneNumber: String?
    var dateOfBirth: Date?
    var gender: Gender?
    var preferredLanguage: String
    var currency: String
    var addresses: [Address]
    var paymentMethods: [PaymentMethod]
    var preferences: UserPreferences
    var joinedDate: Date
    var lastActiveDate: Date
    var favoriteCategories: [ProductCategory]
    var isEmailVerified: Bool
    var isPhoneVerified: Bool
    var membershipTier: MembershipTier
    var totalOrdersCount: Int
    var totalSpent: Double
    var loyaltyPoints: Int
    
    enum Gender: String, CaseIterable, Codable {
        case male = "Male"
        case female = "Female"
        case other = "Other"
        case preferNotToSay = "Prefer not to say"
    }
    
    enum MembershipTier: String, Codable {
        case bronze = "Bronze"
        case silver = "Silver"
        case gold = "Gold"
        case platinum = "Platinum"
        
        var benefits: [String] {
            switch self {
            case .bronze: return ["Basic support", "Standard shipping"]
            case .silver: return ["Priority support", "Free shipping on orders over $50"]
            case .gold: return ["24/7 support", "Free shipping", "Exclusive discounts"]
            case .platinum: return ["VIP support", "Free express shipping", "Exclusive access", "Personal shopper"]
            }
        }
    }
    
    struct UserPreferences: Codable {
        var enableNotifications: Bool
        var enableEmailMarketing: Bool
        var enablePushNotifications: Bool
        var preferredShippingSpeed: ShippingSpeed
        var themePreference: ThemePreference
        var currency: String
        var language: String
        
        enum ShippingSpeed: String, CaseIterable, Codable {
            case standard = "Standard"
            case express = "Express"
            case overnight = "Overnight"
        }
        
        enum ThemePreference: String, CaseIterable, Codable {
            case system = "System"
            case light = "Light"
            case dark = "Dark"
        }
    }
    
    var primaryAddress: Address? {
        return addresses.first { $0.isPrimary } ?? addresses.first
    }
    
    var formattedTotalSpent: String {
        return String(format: "$%.2f", totalSpent)
    }
}

// MARK: - Address Model
struct Address: Identifiable, Codable, Hashable {
    let id = UUID()
    var title: String // "Home", "Work", etc.
    var firstName: String
    var lastName: String
    var company: String?
    var street: String
    var apartment: String?
    var city: String
    var state: String
    var zipCode: String
    var country: String
    var phoneNumber: String?
    var isDefault: Bool
    var isPrimary: Bool
    var addressType: AddressType
    var deliveryInstructions: String?
    
    enum AddressType: String, CaseIterable, Codable {
        case home = "Home"
        case work = "Work"
        case other = "Other"
    }
    
    var fullName: String {
        return "\(firstName) \(lastName)"
    }
    
    var formatted: String {
        var components = [street]
        if let apt = apartment, !apt.isEmpty {
            components[0] += ", \(apt)"
        }
        components.append("\(city), \(state) \(zipCode)")
        components.append(country)
        return components.joined(separator: "\n")
    }
    
    var singleLine: String {
        var components = [street]
        if let apt = apartment, !apt.isEmpty {
            components[0] += ", \(apt)"
        }
        components.append(city)
        components.append(state)
        components.append(zipCode)
        return components.joined(separator: ", ")
    }
}

// MARK: - Payment Models
struct PaymentMethod: Identifiable, Codable {
    let id = UUID()
    let type: PaymentType
    var isDefault: Bool
    let lastFour: String
    let expiryMonth: Int?
    let expiryYear: Int?
    let cardBrand: CardBrand?
    let billingAddress: Address
    let createdDate: Date
    let isActive: Bool
    
    enum PaymentType: String, CaseIterable, Codable {
        case creditCard = "Credit Card"
        case debitCard = "Debit Card"
        case paypal = "PayPal"
        case applePay = "Apple Pay"
        case googlePay = "Google Pay"
        case bankTransfer = "Bank Transfer"
    }
    
    enum CardBrand: String, CaseIterable, Codable {
        case visa = "Visa"
        case mastercard = "Mastercard"
        case amex = "American Express"
        case discover = "Discover"
        case other = "Other"
        
        var logo: String {
            switch self {
            case .visa: return "creditcard.fill"
            case .mastercard: return "creditcard.fill"
            case .amex: return "creditcard.fill"
            case .discover: return "creditcard.fill"
            case .other: return "creditcard"
            }
        }
    }
    
    var displayName: String {
        switch type {
        case .creditCard, .debitCard:
            return "\(cardBrand?.rawValue ?? type.rawValue) •••• \(lastFour)"
        default:
            return type.rawValue
        }
    }
    
    var maskedNumber: String {
        return "•••• •••• •••• \(lastFour)"
    }
}

struct Transaction: Identifiable, Codable {
    let id = UUID()
    let orderId: UUID
    let paymentMethodId: UUID
    let amount: Double
    let currency: String
    let status: TransactionStatus
    let transactionDate: Date
    let transactionId: String
    let paymentGateway: String
    let refundAmount: Double?
    let refundDate: Date?
    
    enum TransactionStatus: String, CaseIterable, Codable {
        case pending = "Pending"
        case processing = "Processing"
        case completed = "Completed"
        case failed = "Failed"
        case cancelled = "Cancelled"
        case refunded = "Refunded"
        case partiallyRefunded = "Partially Refunded"
    }
    
    var formattedAmount: String {
        return String(format: "$%.2f", amount)
    }
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: transactionDate)
    }
}

// MARK: - Cart Item Model
struct CartItem: Identifiable, Codable {
    let id = UUID()
    let product: Product
    var quantity: Int
    let addedDate: Date
    var customizations: [String: String] // Option name -> selected value
    var personalMessage: String?
    var giftWrap: Bool
    var estimatedDelivery: Date?
    
    var totalPrice: Double {
        let basePrice = product.discountedPrice ?? product.price
        let customizationCost = product.customizationOptions
            .filter { customizations.keys.contains($0.name) }
            .reduce(0) { $0 + $1.additionalCost }
        let giftWrapCost = giftWrap ? 5.0 : 0.0
        return (basePrice + customizationCost + giftWrapCost) * Double(quantity)
    }
    
    var formattedTotalPrice: String {
        return String(format: "$%.2f", totalPrice)
    }
    
    var isAvailable: Bool {
        return product.isAvailable && product.inventory.isInStock && quantity <= product.inventory.stockQuantity
    }
}

// MARK: - Enhanced Review Model
struct Review: Identifiable, Codable {
    let id = UUID()
    let userId: UUID
    let productId: UUID
    let orderId: UUID?
    let userName: String
    let userProfileImageURL: String?
    let rating: Int
    let title: String
    let comment: String
    let date: Date
    let helpfulCount: Int
    let images: [String] // Review images
    let isVerifiedPurchase: Bool
    let sellerResponse: SellerResponse?
    let updatedDate: Date?
    
    struct SellerResponse: Codable {
        let message: String
        let date: Date
        let sellerName: String
    }
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
    
    var ratingStars: String {
        return String(repeating: "★", count: rating) + String(repeating: "☆", count: 5 - rating)
    }
}

// MARK: - Enhanced Order Model
struct Order: Identifiable, Codable {
    let id = UUID()
    let orderNumber: String
    let items: [CartItem]
    let subtotal: Double
    let shippingCost: Double
    let tax: Double
    let discount: Double
    let totalAmount: Double
    let orderDate: Date
    var status: OrderStatus
    let shippingAddress: Address
    let billingAddress: Address
    let paymentMethod: PaymentMethod
    let estimatedDelivery: Date
    let actualDelivery: Date?
    var trackingNumber: String?
    var carrier: ShippingCarrier?
    let orderNotes: String?
    var statusHistory: [OrderStatusUpdate]
    
    enum OrderStatus: String, CaseIterable, Codable {
        case pending = "Pending"
        case confirmed = "Confirmed"
        case processing = "Processing"
        case shipped = "Shipped"
        case outForDelivery = "Out for Delivery"
        case delivered = "Delivered"
        case cancelled = "Cancelled"
        case refunded = "Refunded"
        case returned = "Returned"
        
        var color: Color {
            switch self {
            case .pending: return .orange
            case .confirmed: return .blue
            case .processing: return .purple
            case .shipped: return .indigo
            case .outForDelivery: return .mint
            case .delivered: return .green
            case .cancelled: return .red
            case .refunded: return .red
            case .returned: return .gray
            }
        }
        
        var icon: String {
            switch self {
            case .pending: return "clock"
            case .confirmed: return "checkmark.circle"
            case .processing: return "gearshape"
            case .shipped: return "shippingbox"
            case .outForDelivery: return "truck"
            case .delivered: return "house"
            case .cancelled: return "xmark.circle"
            case .refunded: return "arrow.counterclockwise"
            case .returned: return "return"
            }
        }
    }
    
    enum ShippingCarrier: String, CaseIterable, Codable {
        case fedex = "FedEx"
        case ups = "UPS"
        case usps = "USPS"
        case dhl = "DHL"
        case amazon = "Amazon"
        case other = "Other"
    }
    
    struct OrderStatusUpdate: Identifiable, Codable {
        let id = UUID()
        let status: OrderStatus
        let date: Date
        let notes: String?
        let location: String?
    }
    
    var formattedTotal: String {
        return String(format: "$%.2f", totalAmount)
    }
    
    var formattedSubtotal: String {
        return String(format: "$%.2f", subtotal)
    }
    
    var formattedShipping: String {
        return shippingCost == 0 ? "Free" : String(format: "$%.2f", shippingCost)
    }
    
    var formattedTax: String {
        return String(format: "$%.2f", tax)
    }
    
    var formattedDiscount: String {
        return discount > 0 ? "-$\(String(format: "%.2f", discount))" : "$0.00"
    }
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: orderDate)
    }
    
    var estimatedDeliveryFormatted: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: estimatedDelivery)
    }
    
    var canCancel: Bool {
        return [.pending, .confirmed].contains(status)
    }
    
    var canTrack: Bool {
        return trackingNumber != nil && [.shipped, .outForDelivery].contains(status)
    }
}

// MARK: - Wishlist Model
struct WishlistItem: Identifiable, Codable {
    let id = UUID()
    let productId: UUID
    let addedDate: Date
    var notes: String?
    var priority: Priority
    
    enum Priority: String, CaseIterable, Codable {
        case low = "Low"
        case medium = "Medium"
        case high = "High"
        
        var color: Color {
            switch self {
            case .low: return .green
            case .medium: return .orange
            case .high: return .red
            }
        }
    }
}

// MARK: - Notification Model
struct AppNotification: Identifiable, Codable {
    let id = UUID()
    let title: String
    let message: String
    let type: NotificationType
    let date: Date
    var isRead: Bool
    let actionURL: String?
    let imageURL: String?
    let metadata: [String: String]?
    
    enum NotificationType: String, CaseIterable, Codable {
        case orderUpdate = "Order Update"
        case promotion = "Promotion"
        case newProduct = "New Product"
        case priceAlert = "Price Alert"
        case backInStock = "Back in Stock"
        case review = "Review"
        case message = "Message"
        case system = "System"
        
        var icon: String {
            switch self {
            case .orderUpdate: return "shippingbox"
            case .promotion: return "tag"
            case .newProduct: return "sparkles"
            case .priceAlert: return "dollarsign.circle"
            case .backInStock: return "arrow.clockwise"
            case .review: return "star"
            case .message: return "message"
            case .system: return "gear"
            }
        }
        
        var color: Color {
            switch self {
            case .orderUpdate: return .blue
            case .promotion: return .purple
            case .newProduct: return .green
            case .priceAlert: return .orange
            case .backInStock: return .mint
            case .review: return .yellow
            case .message: return .indigo
            case .system: return .gray
            }
        }
    }
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    var timeAgo: String {
        let now = Date()
        let timeInterval = now.timeIntervalSince(date)
        
        if timeInterval < 60 {
            return "Just now"
        } else if timeInterval < 3600 {
            let minutes = Int(timeInterval / 60)
            return "\(minutes)m ago"
        } else if timeInterval < 86400 {
            let hours = Int(timeInterval / 3600)
            return "\(hours)h ago"
        } else {
            let days = Int(timeInterval / 86400)
            return "\(days)d ago"
        }
    }
}

// MARK: - Search History Model
struct SearchHistory: Identifiable, Codable {
    let id = UUID()
    let query: String
    let date: Date
    let resultCount: Int
    let category: ProductCategory?
    let filters: [String: String]?
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter.string(from: date)
    }
}

// MARK: - Recommendation Model
struct Recommendation: Identifiable, Codable {
    let id = UUID()
    let productId: UUID
    let reason: RecommendationReason
    let score: Double
    let createdDate: Date
    
    enum RecommendationReason: String, CaseIterable, Codable {
        case viewedSimilar = "People who viewed this also viewed"
        case boughtTogether = "Frequently bought together"
        case basedOnPurchases = "Based on your purchases"
        case trending = "Trending now"
        case newInCategory = "New in your favorite categories"
        case priceReduction = "Price reduced on items you liked"
        
        var title: String {
            return self.rawValue
        }
    }
}

// MARK: - App Configuration Model
struct AppConfiguration: Codable {
    let apiBaseURL: String
    let supportedCountries: [String]
    let supportedCurrencies: [String]
    let defaultCurrency: String
    let minimumOrderAmount: Double
    let freeShippingThreshold: Double
    let taxRate: Double
    let features: FeatureFlags
    let socialMediaLinks: [String: String]
    let customerSupportInfo: CustomerSupportInfo
    
    struct FeatureFlags: Codable {
        let enableWishlist: Bool
        let enableReviews: Bool
        let enableNotifications: Bool
        let enableSocialSharing: Bool
        let enableGiftCards: Bool
        let enableLoyaltyProgram: Bool
        let enableLiveChat: Bool
        let enableARViewer: Bool
    }
    
    struct CustomerSupportInfo: Codable {
        let email: String
        let phone: String
        let chatEnabled: Bool
        let businessHours: String
        let languages: [String]
    }
} 