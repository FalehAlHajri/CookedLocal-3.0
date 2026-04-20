//
//  HomeTabBar.swift
//  Cooked Local
//

import SwiftUI

enum HomeTab: CaseIterable {
    case home
    case categories
    case myOrder
    case profile

    var icon: String {
        switch self {
        case .home: return "homeIcon"
        case .categories: return "categoryIcon"
        case .myOrder: return "myOrderIcon"
        case .profile: return "profileIcon"
        }
    }

    var title: String {
        switch self {
        case .home: return "Home"
        case .categories: return "Categories"
        case .myOrder: return "My Order"
        case .profile: return "Profile"
        }
    }

    var chefTitle: String {
        switch self {
        case .home: return "Home"
        case .categories: return "My Dish"
        case .myOrder: return "My Order"
        case .profile: return "Profile"
        }
    }
}

struct HomeTabBar: View {
    @Binding var selectedTab: HomeTab
    var isChef: Bool = false
    @Namespace private var tabAnimation

    init(selectedTab: Binding<HomeTab>, isChef: Bool = false) {
        self._selectedTab = selectedTab
        self.isChef = isChef
    }

    var body: some View {
        HStack(spacing: 0) {
            ForEach(HomeTab.allCases, id: \.self) { tab in
                tabItem(tab)
            }
        }
        .padding(.horizontal, DesignTokens.Spacing.lg)
        .padding(.vertical, DesignTokens.Spacing.sm)
        .background(Color.white)
    }

    private func tabItem(_ tab: HomeTab) -> some View {
        Button {
            withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                selectedTab = tab
            }
        } label: {
            ZStack {
                if selectedTab == tab {
                    Capsule()
                        .fill(Color.brandOrange)
                        .matchedGeometryEffect(id: "activeTab", in: tabAnimation)
                }

                if selectedTab == tab {
                    Text(isChef ? tab.chefTitle : tab.title)
                        .font(.anton(DesignTokens.FontSize.caption))
                        .lineLimit(1)
                        .fixedSize(horizontal: true, vertical: false)
                        .foregroundColor(.white)
                        .padding(.horizontal, DesignTokens.Spacing.md)
                        .padding(.vertical, DesignTokens.Spacing.sm)
                        .transition(.opacity)
                } else {
                    Image(tab.icon)
                        .font(.system(size: 20))
                        .foregroundColor(.neutral600)
                        .transition(.opacity)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 44)
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    VStack {
        Spacer()
        HomeTabBar(selectedTab: .constant(.home))
        HomeTabBar(selectedTab: .constant(.categories))
        HomeTabBar(selectedTab: .constant(.myOrder))
        HomeTabBar(selectedTab: .constant(.profile))
    }
    .background(Color.backgroundColor)
}
