import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var store: EstlyStore
    @State private var showingEditProfile = false
    @State private var showingSettings = false
    @State private var showingFavorites = false
    @State private var showingOrders = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Profile Header
                    profileHeader
                    
                    // Quick Stats
                    quickStats
                    
                    // Menu Options
                    menuOptions
                    
                    // App Info
                    appInfo
                }
                .padding(.horizontal, 16)
                .padding(.top, 20)
            }
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Settings") {
                        showingSettings = true
                    }
                    .font(.system(size: 16))
                }
            }
        }
        .sheet(isPresented: $showingEditProfile) {
            EditProfileView()
                .environmentObject(store)
        }
        .sheet(isPresented: $showingSettings) {
            SettingsView()
        }
        .sheet(isPresented: $showingFavorites) {
            FavoritesView()
                .environmentObject(store)
        }
    }
    
    // MARK: - Profile Header
    private var profileHeader: some View {
        VStack(spacing: 16) {
            // Profile Image
            Button(action: {
                showingEditProfile = true
            }) {
                ZStack {
                    Circle()
                        .fill(Color.blue.opacity(0.1))
                        .frame(width: 100, height: 100)
                    
                    if let user = store.currentUser {
                        Text(String(user.name.prefix(1)))
                            .font(.system(size: 40))
                    } else {
                        Image(systemName: "person.fill")
                            .font(.system(size: 40))
                            .foregroundColor(.blue)
                    }
                    
                    // Edit Badge
                    Circle()
                        .fill(Color.blue)
                        .frame(width: 32, height: 32)
                        .overlay(
                            Image(systemName: "pencil")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(.white)
                        )
                        .offset(x: 35, y: 35)
                }
            }
            .buttonStyle(PlainButtonStyle())
            
            // User Info
            VStack(spacing: 4) {
                if let user = store.currentUser {
                    Text(user.name)
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.primary)
                    
                    Text(user.email)
                        .font(.system(size: 16))
                        .foregroundColor(.gray)
                    
                    Text("Member since \(user.joinedDate.formatted(date: .abbreviated, time: .omitted))")
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                } else {
                    Text("Guest User")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.primary)
                    
                    Button("Sign In") {
                        // Handle sign in
                    }
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.blue)
                }
            }
        }
    }
    
    // MARK: - Quick Stats
    private var quickStats: some View {
        HStack(spacing: 20) {
            StatCard(
                title: "Favorites",
                value: "\(store.favoriteProductIds.count)",
                icon: "heart.fill",
                color: .red
            ) {
                showingFavorites = true
            }
            
            StatCard(
                title: "Cart Items",
                value: "\(store.cartItemCount)",
                icon: "bag.fill",
                color: .blue
            ) {
                // Navigate to cart
            }
            
            StatCard(
                title: "Orders",
                value: "0", // In a real app, this would be dynamic
                icon: "box.fill",
                color: .green
            ) {
                showingOrders = true
            }
        }
    }
    
    // MARK: - Menu Options
    private var menuOptions: some View {
        VStack(spacing: 16) {
            Text("Account")
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(.primary)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            VStack(spacing: 0) {
                MenuRow(
                    title: "Edit Profile",
                    icon: "person.circle",
                    action: { showingEditProfile = true }
                )
                
                Divider()
                    .padding(.leading, 50)
                
                MenuRow(
                    title: "Favorites",
                    icon: "heart",
                    badge: store.favoriteProductIds.count > 0 ? "\(store.favoriteProductIds.count)" : nil,
                    action: { showingFavorites = true }
                )
                
                Divider()
                    .padding(.leading, 50)
                
                MenuRow(
                    title: "Order History",
                    icon: "clock",
                    action: { showingOrders = true }
                )
                
                Divider()
                    .padding(.leading, 50)
                
                MenuRow(
                    title: "Addresses",
                    icon: "location",
                    action: { /* Navigate to addresses */ }
                )
                
                Divider()
                    .padding(.leading, 50)
                
                MenuRow(
                    title: "Payment Methods",
                    icon: "creditcard",
                    action: { /* Navigate to payment methods */ }
                )
            }
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(UIColor.secondarySystemBackground))
            )
            
            // Support Section
            VStack(spacing: 0) {
                Text("Support")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.primary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 24)
                    .padding(.bottom, 16)
                
                VStack(spacing: 0) {
                    MenuRow(
                        title: "Help Center",
                        icon: "questionmark.circle",
                        action: { /* Navigate to help */ }
                    )
                    
                    Divider()
                        .padding(.leading, 50)
                    
                    MenuRow(
                        title: "Contact Support",
                        icon: "envelope",
                        action: { /* Navigate to contact */ }
                    )
                    
                    Divider()
                        .padding(.leading, 50)
                    
                    MenuRow(
                        title: "About Estly",
                        icon: "info.circle",
                        action: { /* Navigate to about */ }
                    )
                }
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(UIColor.secondarySystemBackground))
                )
            }
        }
    }
    
    // MARK: - App Info
    private var appInfo: some View {
        VStack(spacing: 8) {
            Text("Estly")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.primary)
            
            Text("Version 1.0.0")
                .font(.system(size: 14))
                .foregroundColor(.gray)
            
            Text("Handcrafted with ❤️")
                .font(.system(size: 12))
                .foregroundColor(.gray)
        }
        .padding(.top, 20)
        .padding(.bottom, 40)
    }
}

// MARK: - Stat Card Component
struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    let action: () -> Void
    @State private var isPressed = false
    
    var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                isPressed = true
                action()
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                isPressed = false
            }
        }) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(color)
                
                Text(value)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.primary)
                
                Text(title)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.gray)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(UIColor.secondarySystemBackground))
            )
        }
        .scaleEffect(isPressed ? 0.95 : 1.0)
        .animation(.spring(response: 0.4, dampingFraction: 0.7), value: isPressed)
    }
}

// MARK: - Menu Row Component
struct MenuRow: View {
    let title: String
    let icon: String
    let badge: String?
    let action: () -> Void
    @State private var isPressed = false
    
    init(title: String, icon: String, badge: String? = nil, action: @escaping () -> Void) {
        self.title = title
        self.icon = icon
        self.badge = badge
        self.action = action
    }
    
    var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                isPressed = true
                action()
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                isPressed = false
            }
        }) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.blue)
                    .frame(width: 24)
                
                Text(title)
                    .font(.system(size: 16))
                    .foregroundColor(.primary)
                
                Spacer()
                
                if let badge = badge {
                    Text(badge)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(Color.red)
                        .clipShape(Capsule())
                }
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.gray)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
        .scaleEffect(isPressed ? 0.98 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isPressed)
    }
}

// MARK: - Edit Profile View
struct EditProfileView: View {
    @EnvironmentObject var store: EstlyStore
    @Environment(\.dismiss) private var dismiss
    @State private var name = ""
    @State private var email = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section("Personal Information") {
                    TextField("Name", text: $name)
                    TextField("Email", text: $email)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                }
                
                Section("Preferences") {
                    // Add preference settings here
                    Text("Notification preferences coming soon")
                        .foregroundColor(.gray)
                }
            }
            .navigationTitle("Edit Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveProfile()
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
        .onAppear {
            if let user = store.currentUser {
                name = user.name
                email = user.email
            }
        }
    }
    
    private func saveProfile() {
        // In a real app, update the user profile
        // store.updateUser(name: name, email: email)
    }
}

// MARK: - Settings View
struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @AppStorage("notificationsEnabled") private var notificationsEnabled = true
    @AppStorage("darkModeEnabled") private var darkModeEnabled = false
    
    var body: some View {
        NavigationView {
            Form {
                Section("Preferences") {
                    Toggle("Push Notifications", isOn: $notificationsEnabled)
                    Toggle("Dark Mode", isOn: $darkModeEnabled)
                }
                
                Section("Privacy") {
                    Button("Privacy Policy") {
                        // Show privacy policy
                    }
                    
                    Button("Terms of Service") {
                        // Show terms
                    }
                }
                
                Section("Account") {
                    Button("Sign Out") {
                        // Handle sign out
                    }
                    .foregroundColor(.red)
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Favorites View
struct FavoritesView: View {
    @EnvironmentObject var store: EstlyStore
    @Environment(\.dismiss) private var dismiss
    @State private var selectedProduct: Product?
    @State private var showingProductDetail = false
    
    private let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]
    
    var favoriteProducts: [Product] {
        store.products.filter { store.favoriteProductIds.contains($0.id) }
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                if favoriteProducts.isEmpty {
                    LiquidEmptyStateView(
                        title: "No Favorites Yet",
                        message: "Items you favorite will appear here",
                        systemImage: "heart",
                        actionTitle: "Start Shopping",
                        action: {
                            dismiss()
                        }
                    )
                    .padding(EdgeInsets(top: 100, leading: 0, bottom: 0, trailing: 0))
                } else {
                    LazyVGrid(columns: columns, spacing: 16) {
                        ForEach(favoriteProducts) { product in
                            ProductCardView(product: product)
                                .environmentObject(store)
                                .onTapGesture {
                                    selectedProduct = product
                                    showingProductDetail = true
                                }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 16)
                }
            }
            .navigationTitle("Favorites")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
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
}

// MARK: - Preview
#Preview {
    ProfileView()
        .environmentObject(EstlyStore())
} 