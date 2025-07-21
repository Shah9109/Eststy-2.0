//
//  ContentView.swift
//  Eststy 2.0
//
//  Created by Sanjay Shah on 20/07/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var store = EstlyStore()
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // Home Tab
            HomeView()
                .environmentObject(store)
                .tabItem {
                    Image(systemName: selectedTab == 0 ? "house.fill" : "house")
                    Text("Home")
                }
                .tag(0)
            
            // Search Tab
            SearchView()
                .environmentObject(store)
                .tabItem {
                    Image(systemName: selectedTab == 1 ? "magnifyingglass.circle.fill" : "magnifyingglass")
                    Text("Search")
                }
                .tag(1)
            
            // Cart Tab
            CartView()
                .environmentObject(store)
                .tabItem {
                    Image(systemName: selectedTab == 2 ? "bag.fill" : "bag")
                    Text("Cart")
                }
                .tag(2)
                .modifier(ConditionalBadge(count: store.cartItemCount))
            
            // Profile Tab
            ProfileView()
                .environmentObject(store)
                .tabItem {
                    Image(systemName: selectedTab == 3 ? "person.fill" : "person")
                    Text("Profile")
                }
                .tag(3)
        }
        .accentColor(.blue)
        .onAppear {
            // Customize tab bar appearance
            let appearance = UITabBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = UIColor.systemBackground
            
            // Selected state
            appearance.stackedLayoutAppearance.selected.iconColor = UIColor.systemBlue
            appearance.stackedLayoutAppearance.selected.titleTextAttributes = [
                .foregroundColor: UIColor.systemBlue,
                .font: UIFont.systemFont(ofSize: 10, weight: .medium)
            ]
            
            // Normal state
            appearance.stackedLayoutAppearance.normal.iconColor = UIColor.systemGray
            appearance.stackedLayoutAppearance.normal.titleTextAttributes = [
                .foregroundColor: UIColor.systemGray,
                .font: UIFont.systemFont(ofSize: 10, weight: .medium)
            ]
            
            UITabBar.appearance().standardAppearance = appearance
            UITabBar.appearance().scrollEdgeAppearance = appearance
        }
        .sheet(isPresented: $store.showingCart) {
            CartView()
                .environmentObject(store)
        }
    }
}

// MARK: - Conditional Badge Modifier
struct ConditionalBadge: ViewModifier {
    let count: Int
    
    func body(content: Content) -> some View {
        if count > 0 {
            content.badge(count)
        } else {
            content
        }
    }
}

#Preview {
    ContentView()
}
