import SwiftUI

struct NotificationsView: View {
    @EnvironmentObject var store: EstlyStore
    @Environment(\.presentationMode) var presentationMode
    @State private var selectedFilter: NotificationFilter = .all
    @State private var showingSettings = false
    @State private var headerAnimation = false
    @State private var listAnimation = false
    
    enum NotificationFilter: String, CaseIterable {
        case all = "All"
        case unread = "Unread"
        case orders = "Orders"
        case promotions = "Promotions"
        case system = "System"
        
        var icon: String {
            switch self {
            case .all: return "tray.fill"
            case .unread: return "circle.fill"
            case .orders: return "shippingbox.fill"
            case .promotions: return "tag.fill"
            case .system: return "gear.circle.fill"
            }
        }
        
        var color: Color {
            switch self {
            case .all: return .blue
            case .unread: return .red
            case .orders: return .green
            case .promotions: return .purple
            case .system: return .orange
            }
        }
    }
    
    var filteredNotifications: [AppNotification] {
        switch selectedFilter {
        case .all:
            return store.notifications
        case .unread:
            return store.notifications.filter { !$0.isRead }
        case .orders:
            return store.notifications.filter { $0.type == .orderUpdate }
        case .promotions:
            return store.notifications.filter { $0.type == .promotion }
        case .system:
            return store.notifications.filter { $0.type == .system }
        }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background gradient
                LinearGradient(
                    colors: [.blue.opacity(0.05), .purple.opacity(0.05)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Enhanced Header
                    enhancedHeader
                    
                    // Filter Tabs
                    filterTabsSection
                    
                    // Notifications List
                    if filteredNotifications.isEmpty {
                        emptyStateView
                    } else {
                        notificationsListView
                    }
                }
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showingSettings) {
                NotificationSettingsView()
                    .environmentObject(store)
            }
            .onAppear {
                withAnimation(.liquid(duration: 0.8)) {
                    headerAnimation = true
                }
                withAnimation(.liquid(duration: 1.0).delay(0.3)) {
                    listAnimation = true
                }
            }
        }
    }
    
    // MARK: - Enhanced Header
    private var enhancedHeader: some View {
        HStack {
            // Back Button
            Button(action: {
                let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                impactFeedback.impactOccurred()
                presentationMode.wrappedValue.dismiss()
            }) {
                ZStack {
                    Circle()
                        .fill(.ultraThinMaterial)
                        .frame(width: 40, height: 40)
                        .liquidShadow()
                    
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.primary)
                }
            }
            
            Spacer()
            
            // Title with animation
            VStack(spacing: 4) {
                Text("Notifications")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
                    .opacity(headerAnimation ? 1.0 : 0.0)
                    .offset(y: headerAnimation ? 0 : -20)
                
                if store.unreadNotificationCount > 0 {
                    Text("\(store.unreadNotificationCount) unread")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .opacity(headerAnimation ? 1.0 : 0.0)
                        .offset(y: headerAnimation ? 0 : -20)
                }
            }
            .animation(.liquid(duration: 0.8), value: headerAnimation)
            
            Spacer()
            
            // Action Buttons
            HStack(spacing: 12) {
                // Mark All Read Button
                if store.unreadNotificationCount > 0 {
                    Button(action: {
                        withAnimation(.liquid(duration: 0.6)) {
                            store.markAllNotificationsAsRead()
                        }
                        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                        impactFeedback.impactOccurred()
                    }) {
                        ZStack {
                            Circle()
                                .fill(.green.opacity(0.1))
                                .frame(width: 40, height: 40)
                                .liquidShadow(color: .green)
                            
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.green)
                        }
                    }
                    .liquidTransition()
                }
                
                // Settings Button
                Button(action: {
                    let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                    impactFeedback.impactOccurred()
                    showingSettings = true
                }) {
                    ZStack {
                        Circle()
                            .fill(.ultraThinMaterial)
                            .frame(width: 40, height: 40)
                            .liquidShadow()
                        
                        Image(systemName: "gearshape.fill")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.primary)
                    }
                }
            }
            .opacity(headerAnimation ? 1.0 : 0.0)
            .offset(x: headerAnimation ? 0 : 30)
            .animation(.liquid(duration: 0.8).delay(0.2), value: headerAnimation)
        }
        .padding(.horizontal, 20)
        .padding(.top, 10)
        .padding(.bottom, 20)
    }
    
    // MARK: - Filter Tabs Section
    private var filterTabsSection: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(NotificationFilter.allCases, id: \.self) { filter in
                    FilterTab(
                        filter: filter,
                        isSelected: selectedFilter == filter,
                        count: getNotificationCount(for: filter)
                    ) {
                        withAnimation(.liquid(duration: 0.4)) {
                            selectedFilter = filter
                        }
                        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                        impactFeedback.impactOccurred()
                    }
                }
            }
            .padding(.horizontal, 20)
        }
        .padding(.bottom, 20)
        .opacity(headerAnimation ? 1.0 : 0.0)
        .offset(x: headerAnimation ? 0 : -50)
        .animation(.liquid(duration: 0.8).delay(0.4), value: headerAnimation)
    }
    
    // MARK: - Notifications List View
    private var notificationsListView: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(Array(filteredNotifications.enumerated()), id: \.element.id) { index, notification in
                    NotificationCard(
                        notification: notification,
                        onTap: {
                            handleNotificationTap(notification)
                        },
                        onDismiss: {
                            withAnimation(.liquid(duration: 0.6)) {
                                store.markNotificationAsRead(notification)
                            }
                        }
                    )
                    .environmentObject(store)
                    .opacity(listAnimation ? 1.0 : 0.0)
                    .offset(y: listAnimation ? 0 : 50)
                    .animation(
                        .liquid(duration: 0.6).delay(Double(index) * 0.1),
                        value: listAnimation
                    )
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 100)
        }
    }
    
    // MARK: - Empty State View
    private var emptyStateView: some View {
        LiquidEmptyStateView(
            title: getEmptyStateTitle(),
            message: getEmptyStateMessage(),
            systemImage: getEmptyStateIcon(),
            actionTitle: selectedFilter == .unread ? "Mark All Read" : nil
        ) {
            if selectedFilter == .unread {
                store.markAllNotificationsAsRead()
            }
        }
        .opacity(listAnimation ? 1.0 : 0.0)
        .animation(.liquid(duration: 0.8).delay(0.5), value: listAnimation)
    }
    
    // MARK: - Helper Functions
    private func getNotificationCount(for filter: NotificationFilter) -> Int {
        switch filter {
        case .all:
            return store.notifications.count
        case .unread:
            return store.unreadNotificationCount
        case .orders:
            return store.notifications.filter { $0.type == .orderUpdate }.count
        case .promotions:
            return store.notifications.filter { $0.type == .promotion }.count
        case .system:
            return store.notifications.filter { $0.type == .system }.count
        }
    }
    
    private func getEmptyStateTitle() -> String {
        switch selectedFilter {
        case .all: return "No Notifications"
        case .unread: return "All Caught Up!"
        case .orders: return "No Order Updates"
        case .promotions: return "No Promotions"
        case .system: return "No System Notifications"
        }
    }
    
    private func getEmptyStateMessage() -> String {
        switch selectedFilter {
        case .all: return "You don't have any notifications yet. We'll notify you about important updates."
        case .unread: return "You've read all your notifications. Great job staying on top of things!"
        case .orders: return "No order updates at the moment. Check back later for shipping and delivery notifications."
        case .promotions: return "No promotional offers right now. We'll let you know about great deals when they're available."
        case .system: return "No system notifications. Everything is running smoothly!"
        }
    }
    
    private func getEmptyStateIcon() -> String {
        switch selectedFilter {
        case .all: return "bell.slash"
        case .unread: return "checkmark.seal.fill"
        case .orders: return "shippingbox"
        case .promotions: return "tag"
        case .system: return "gear"
        }
    }
    
    private func handleNotificationTap(_ notification: AppNotification) {
        // Mark as read if unread
        if !notification.isRead {
            store.markNotificationAsRead(notification)
        }
        
        // Handle action based on notification type
        switch notification.type {
        case .orderUpdate:
            // Navigate to order details
            break
        case .promotion:
            // Navigate to promotional items
            break
        case .newProduct:
            // Navigate to new products
            break
        case .priceAlert:
            // Navigate to product with price alert
            break
        case .backInStock:
            // Navigate to back in stock item
            break
        case .review:
            // Navigate to reviews
            break
        case .message:
            // Open message
            break
        case .system:
            // Handle system notification
            break
        }
    }
}

// MARK: - Filter Tab Component
struct FilterTab: View {
    let filter: NotificationsView.NotificationFilter
    let isSelected: Bool
    let count: Int
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
            HStack(spacing: 8) {
                ZStack {
                    Circle()
                        .fill(
                            isSelected 
                            ? filter.color
                            : filter.color.opacity(0.1)
                        )
                        .frame(width: 24, height: 24)
                    
                    Image(systemName: filter.icon)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(
                            isSelected ? .white : filter.color
                        )
                }
                
                Text(filter.rawValue)
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundColor(
                        isSelected ? .white : .primary
                    )
                
                if count > 0 {
                    Text("\(count)")
                        .font(.caption.weight(.bold))
                        .foregroundColor(
                            isSelected ? .white.opacity(0.8) : .secondary
                        )
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(
                                    isSelected 
                                    ? Color.white.opacity(0.2)
                                    : Color.gray.opacity(0.1)
                                )
                        )
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(
                        isSelected 
                        ? LinearGradient(
                            colors: [filter.color, filter.color.opacity(0.8)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                        : LinearGradient(
                            colors: [.gray.opacity(0.05), .gray.opacity(0.02)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(
                                isSelected ? .clear : .gray.opacity(0.2),
                                lineWidth: 1
                            )
                    )
                    .liquidShadow(
                        color: isSelected ? filter.color : .clear,
                        radius: isSelected ? 8 : 2
                    )
            )
        }
        .scaleEffect(isPressed ? 0.95 : 1.0)
        .animation(.liquid(duration: 0.3), value: isPressed)
        .animation(.liquid(duration: 0.4), value: isSelected)
    }
}

// MARK: - Notification Card Component
struct NotificationCard: View {
    let notification: AppNotification
    let onTap: () -> Void
    let onDismiss: () -> Void
    @EnvironmentObject var store: EstlyStore
    @State private var dragOffset: CGFloat = 0
    @State private var isPressed = false
    
    var body: some View {
        Button(action: {
            withAnimation(.liquid(duration: 0.3)) {
                isPressed = true
            }
            
            onTap()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.liquid(duration: 0.3)) {
                    isPressed = false
                }
            }
        }) {
            HStack(spacing: 16) {
                // Notification Icon
                ZStack {
                    Circle()
                        .fill(notification.type.color.opacity(0.15))
                        .frame(width: 48, height: 48)
                    
                    Image(systemName: notification.type.icon)
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(notification.type.color)
                }
                
                // Notification Content
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text(notification.title)
                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                            .foregroundColor(.primary)
                            .lineLimit(2)
                        
                        Spacer()
                        
                        if !notification.isRead {
                            Circle()
                                .fill(.blue)
                                .frame(width: 8, height: 8)
                        }
                    }
                    
                    Text(notification.message)
                        .font(.system(size: 14, design: .rounded))
                        .foregroundColor(.secondary)
                        .lineLimit(3)
                        .multilineTextAlignment(.leading)
                    
                    HStack {
                        Text(notification.timeAgo)
                            .font(.caption)
                            .foregroundColor(.gray)
                        
                        Spacer()
                        
                        Text(notification.type.rawValue)
                            .font(.caption.weight(.medium))
                            .foregroundColor(notification.type.color)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(notification.type.color.opacity(0.1))
                            .clipShape(RoundedRectangle(cornerRadius: 4))
                    }
                }
                
                Spacer()
                
                // Arrow indicator
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.gray)
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(
                                notification.isRead ? .clear : notification.type.color.opacity(0.3),
                                lineWidth: notification.isRead ? 0 : 1
                            )
                    )
                    .liquidShadow(
                        color: notification.isRead ? .black : notification.type.color,
                        radius: notification.isRead ? 4 : 8
                    )
            )
        }
        .scaleEffect(isPressed ? 0.98 : 1.0)
        .rotation3DEffect(
            .degrees(isPressed ? 1 : 0),
            axis: (x: 1, y: 0, z: 0)
        )
        .offset(x: dragOffset)
        .gesture(
            DragGesture()
                .onChanged { value in
                    withAnimation(.liquid(duration: 0.2)) {
                        dragOffset = value.translation.width
                    }
                }
                .onEnded { value in
                    if abs(value.translation.width) > 100 {
                        withAnimation(.liquid(duration: 0.6)) {
                            dragOffset = value.translation.width > 0 ? 300 : -300
                        }
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                            onDismiss()
                        }
                    } else {
                        withAnimation(.liquid(duration: 0.4)) {
                            dragOffset = 0
                        }
                    }
                }
        )
        .animation(.liquid(duration: 0.3), value: isPressed)
    }
}

// MARK: - Notification Settings View
struct NotificationSettingsView: View {
    @EnvironmentObject var store: EstlyStore
    @Environment(\.presentationMode) var presentationMode
    @State private var enableNotifications = true
    @State private var enablePushNotifications = true
    @State private var enableEmailNotifications = false
    @State private var enableOrderUpdates = true
    @State private var enablePromotions = true
    @State private var enableNewProducts = false
    @State private var enablePriceAlerts = true
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 8) {
                        Text("Notification Settings")
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundColor(.primary)
                        
                        Text("Customize how you receive notifications")
                            .font(.system(size: 16, design: .rounded))
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 20)
                    
                    // Settings Groups
                    VStack(spacing: 20) {
                        SettingsGroup(title: "General") {
                            SettingsToggle(
                                title: "Enable Notifications",
                                subtitle: "Turn on all notifications",
                                isOn: $enableNotifications,
                                icon: "bell.fill",
                                color: .blue
                            )
                            
                            SettingsToggle(
                                title: "Push Notifications",
                                subtitle: "Get instant updates",
                                isOn: $enablePushNotifications,
                                icon: "iphone",
                                color: .green
                            )
                            
                            SettingsToggle(
                                title: "Email Notifications",
                                subtitle: "Receive updates via email",
                                isOn: $enableEmailNotifications,
                                icon: "envelope.fill",
                                color: .orange
                            )
                        }
                        
                        SettingsGroup(title: "Order Updates") {
                            SettingsToggle(
                                title: "Order Status",
                                subtitle: "Shipping and delivery updates",
                                isOn: $enableOrderUpdates,
                                icon: "shippingbox.fill",
                                color: .blue
                            )
                        }
                        
                        SettingsGroup(title: "Shopping") {
                            SettingsToggle(
                                title: "Promotions & Deals",
                                subtitle: "Special offers and discounts",
                                isOn: $enablePromotions,
                                icon: "tag.fill",
                                color: .purple
                            )
                            
                            SettingsToggle(
                                title: "New Products",
                                subtitle: "Latest arrivals from artisans",
                                isOn: $enableNewProducts,
                                icon: "sparkles",
                                color: .pink
                            )
                            
                            SettingsToggle(
                                title: "Price Alerts",
                                subtitle: "When wishlist items go on sale",
                                isOn: $enablePriceAlerts,
                                icon: "dollarsign.circle.fill",
                                color: .green
                            )
                        }
                    }
                    
                    Spacer()
                }
                .padding(.horizontal, 20)
            }
            .navigationBarTitle("Settings", displayMode: .inline)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                    .foregroundColor(.blue)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveSettings()
                        presentationMode.wrappedValue.dismiss()
                    }
                    .foregroundColor(.blue)
                    .fontWeight(.semibold)
                }
            }
        }
    }
    
    private func saveSettings() {
        // Save notification preferences
        // In a real app, this would update user preferences
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
    }
}

// MARK: - Settings Components
struct SettingsGroup<Content: View>: View {
    let title: String
    let content: Content
    
    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(title)
                .font(.system(size: 18, weight: .semibold, design: .rounded))
                .foregroundColor(.primary)
                .padding(.horizontal, 4)
            
            VStack(spacing: 0) {
                content
            }
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(.ultraThinMaterial)
                    .liquidShadow()
            )
        }
    }
}

struct SettingsToggle: View {
    let title: String
    let subtitle: String
    @Binding var isOn: Bool
    let icon: String
    let color: Color
    @State private var animateToggle = false
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.15))
                    .frame(width: 40, height: 40)
                
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(color)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundColor(.primary)
                
                Text(subtitle)
                    .font(.system(size: 14, design: .rounded))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Toggle("", isOn: $isOn)
                .scaleEffect(0.9)
                .onChange(of: isOn) { _ in
                    let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                    impactFeedback.impactOccurred()
                    
                    withAnimation(.liquid(duration: 0.3)) {
                        animateToggle.toggle()
                    }
                }
        }
        .padding(16)
        .scaleEffect(animateToggle ? 1.02 : 1.0)
        .animation(.liquid(duration: 0.3), value: animateToggle)
    }
}

#Preview {
    NotificationsView()
        .environmentObject(EstlyStore())
} 