import SwiftUI

struct CartView: View {
    @EnvironmentObject var store: EstlyStore
    @State private var showingCheckout = false
    @State private var checkoutAnimation = false
    @State private var showingEmptyCart = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                if store.cartItems.isEmpty {
                    // Empty Cart State
                    emptyCartView
                } else {
                    // Cart Content
                    cartContent
                }
            }
            .navigationTitle("Shopping Cart")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    if !store.cartItems.isEmpty {
                        Button("Clear") {
                            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                                store.clearCart()
                            }
                        }
                        .foregroundColor(.red)
                    }
                }
            }
        }
        .alert("Order Placed!", isPresented: $showingCheckout) {
            Button("OK") {
                showingCheckout = false
            }
        } message: {
            Text("Thank you for your order! Your handcrafted items will be shipped soon.")
        }
    }
    
    // MARK: - Empty Cart View
    private var emptyCartView: some View {
        LiquidEmptyStateView(
            title: "Your Cart is Empty",
            message: "Add some beautiful handcrafted items to get started",
            systemImage: "cart",
            actionTitle: "Start Shopping",
            action: {
                // Navigate to home or search
            }
        )
    }
    
    // MARK: - Cart Content
    private var cartContent: some View {
        VStack(spacing: 0) {
            // Cart Items List
            ScrollView {
                LazyVStack(spacing: 16) {
                    ForEach(store.cartItems) { cartItem in
                        CartItemRow(cartItem: cartItem)
                            .environmentObject(store)
                            .transition(.scale.combined(with: .opacity))
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 16)
                .animation(.spring(response: 0.6, dampingFraction: 0.8), value: store.cartItems.count)
            }
            
            // Cart Summary
            cartSummary
        }
    }
    
    // MARK: - Cart Summary
    private var cartSummary: some View {
        VStack(spacing: 0) {
            Divider()
                .padding(.horizontal, 16)
            
            VStack(spacing: 16) {
                // Summary Details
                VStack(spacing: 8) {
                    HStack {
                        Text("Subtotal (\(store.cartItemCount) items)")
                            .font(.system(size: 16))
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        Text(store.formattedCartSubtotal)
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.primary)
                    }
                    
                    HStack {
                        Text("Tax")
                            .font(.system(size: 16))
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        Text(store.formattedCartTax)
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.primary)
                    }
                    
                    Divider()
                    
                    HStack {
                        Text("Total")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        Text(store.formattedCartTotal)
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.primary)
                    }
                }
                
                // Checkout Button
                Button(action: {
                    performCheckout()
                }) {
                    HStack {
                        Image(systemName: "creditcard")
                            .font(.system(size: 16, weight: .semibold))
                        
                        Text("Proceed to Checkout")
                            .font(.system(size: 16, weight: .semibold))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(Color.blue)
                    .cornerRadius(12)
                    .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                }
                .scaleEffect(checkoutAnimation ? 1.05 : 1.0)
                .animation(.spring(response: 0.4, dampingFraction: 0.6), value: checkoutAnimation)
                
                // Security Info
                HStack {
                    Image(systemName: "lock.shield")
                        .font(.system(size: 12))
                        .foregroundColor(.green)
                    
                    Text("Secure checkout with 256-bit SSL encryption")
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                    
                    Spacer()
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 20)
            .background(Color(UIColor.systemBackground))
        }
    }
    
    // MARK: - Helper Functions
    private func performCheckout() {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
            checkoutAnimation = true
        }
        
        // Haptic feedback
        let impact = UIImpactFeedbackGenerator(style: .medium)
        impact.impactOccurred()
        
        // Simulate checkout process
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                checkoutAnimation = false
            }
            
            // Show success and clear cart
            showingCheckout = true
            
            // Simple checkout simulation - clear cart
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                store.cartItems.removeAll()
            }
        }
    }
}

// MARK: - Cart Item Row
struct CartItemRow: View {
    let cartItem: CartItem
    @EnvironmentObject var store: EstlyStore
    @State private var deleteAnimation = false
    @State private var quantityAnimation = false
    
    var body: some View {
        HStack(spacing: 12) {
            // Product Image
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.gray.opacity(0.1))
                .frame(width: 80, height: 80)
                .overlay(
                    Image(systemName: "photo")
                        .font(.system(size: 20))
                        .foregroundColor(.gray.opacity(0.6))
                )
            
            // Product Info
            VStack(alignment: .leading, spacing: 4) {
                Text(cartItem.product.name)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.primary)
                    .lineLimit(2)
                
                if let seller = store.getSellerForProduct(cartItem.product) {
                    Text("by \(seller.name)")
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                }
                
                // Price
                HStack {
                    LiquidPriceTagView(product: cartItem.product)
                    
                    Spacer()
                }
                
                // Quantity Controls
                HStack {
                    // Decrease Button
                    Button(action: {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            if cartItem.quantity > 1 {
                                store.updateCartItemQuantity(cartItem, quantity: cartItem.quantity - 1)
                            } else {
                                store.removeFromCart(cartItem)
                            }
                            quantityAnimation.toggle()
                        }
                    }) {
                        Image(systemName: cartItem.quantity > 1 ? "minus" : "trash")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(cartItem.quantity > 1 ? .primary : .red)
                            .frame(width: 28, height: 28)
                            .background(Color.gray.opacity(0.1))
                            .clipShape(Circle())
                    }
                    
                    // Quantity Display
                    Text("\(cartItem.quantity)")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.primary)
                        .frame(width: 30)
                        .scaleEffect(quantityAnimation ? 1.2 : 1.0)
                        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: quantityAnimation)
                    
                    // Increase Button
                    Button(action: {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            if cartItem.quantity < 10 {
                                store.updateCartItemQuantity(cartItem, quantity: cartItem.quantity + 1)
                                quantityAnimation.toggle()
                            }
                        }
                    }) {
                        Image(systemName: "plus")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.primary)
                            .frame(width: 28, height: 28)
                            .background(Color.gray.opacity(0.1))
                            .clipShape(Circle())
                    }
                    .disabled(cartItem.quantity >= 10)
                    
                    Spacer()
                    
                    // Total Price
                    VStack(alignment: .trailing) {
                        Text(cartItem.formattedTotalPrice)
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.primary)
                        
                        if cartItem.quantity > 1 {
                            Text("\(cartItem.product.formattedPrice) each")
                                .font(.system(size: 10))
                                .foregroundColor(.gray)
                        }
                    }
                }
            }
            
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(UIColor.secondarySystemBackground))
        )
        .scaleEffect(deleteAnimation ? 0.95 : 1.0)
        .opacity(deleteAnimation ? 0.5 : 1.0)
        .animation(.spring(response: 0.4, dampingFraction: 0.7), value: deleteAnimation)
        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
            Button(role: .destructive) {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                    deleteAnimation = true
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    store.removeFromCart(cartItem)
                }
            } label: {
                Image(systemName: "trash")
            }
        }
    }
}

// MARK: - Preview
#Preview {
    CartView()
        .environmentObject(EstlyStore())
} 