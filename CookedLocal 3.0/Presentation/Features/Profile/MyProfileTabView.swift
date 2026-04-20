//
//  MyProfileTabView.swift
//  Cooked Local
//

import SwiftUI

struct MyProfileTabView: View {
    @ObservedObject var viewModel: MyProfileViewModel

    var body: some View {
        VStack(spacing: 0) {
            ScrollView(showsIndicators: false) {
                VStack(spacing: DesignTokens.Spacing.lg) {
                    profileHeader

                    profileSection

                    paymentSection

                    settingsSection

                    logoutButton
                }
                .padding(.bottom, DesignTokens.Spacing.lg)
            }
        }
        .background(Color.backgroundColor)
        .overlay(
            Group {
                if viewModel.showLogoutDialog {
                    logoutDialog
                }
            }
        )
    }

    // MARK: - Profile Header
    private var profileHeader: some View {
        VStack(spacing: DesignTokens.Spacing.sm) {
            Text("profile")
                .font(.anton(DesignTokens.FontSize.subheadline))
                .foregroundColor(.neutral900)

            CachedProfileImage(urlString: viewModel.profileImageURL, size: 100)
                .id(viewModel.profileImageURL)

            Text(viewModel.userName)
                .font(.anton(DesignTokens.FontSize.subheadline))
                .foregroundColor(.neutral900)

            Text(viewModel.userEmail)
                .font(.system(size: DesignTokens.FontSize.body))
                .foregroundColor(.neutral600)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, DesignTokens.Spacing.md)
    }

    // MARK: - Profile Section
    private var profileSection: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
            Text("Profile")
                .font(.anton(DesignTokens.FontSize.body))
                .foregroundColor(.neutral900)
                .padding(.horizontal, DesignTokens.Spacing.md)

            ProfileMenuItem(
                icon: viewModel.isChef ? "storefront" : "person",
                title: viewModel.isChef ? "Manage Shop" : "Manage Profile",
                action: { viewModel.navigateToManageProfile() }
            )
        }
    }

    // MARK: - Payment Section
    private var paymentSection: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
            Text("Payment")
                .font(.anton(DesignTokens.FontSize.body))
                .foregroundColor(.neutral900)
                .padding(.horizontal, DesignTokens.Spacing.md)

            ProfileMenuItem(
                icon: "creditcard",
                title: "Payment Methods",
                action: { viewModel.navigateToPaymentMethods() }
            )
        }
    }

    // MARK: - Settings Section
    private var settingsSection: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
            Text("Settings")
                .font(.anton(DesignTokens.FontSize.body))
                .foregroundColor(.neutral900)
                .padding(.horizontal, DesignTokens.Spacing.md)

            ProfileMenuItem(
                icon: "lock",
                title: "Change Password",
                action: { viewModel.navigateToChangePassword() }
            )

            ProfileMenuItem(
                icon: "shield",
                title: "Privacy Policy",
                action: { viewModel.navigateToPrivacyPolicy() }
            )

            ProfileMenuItem(
                icon: "exclamationmark.triangle",
                title: "Terms & Conditions",
                action: { viewModel.navigateToTermsAndConditions() }
            )

            ProfileMenuItem(
                icon: "info.circle",
                title: "About Us",
                action: { viewModel.navigateToAboutUs() }
            )
        }
    }

    // MARK: - Logout Button
    private var logoutButton: some View {
        Button(action: { viewModel.confirmLogout() }) {
            Text("Log out")
                .font(.anton(DesignTokens.FontSize.body))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, DesignTokens.Spacing.sm)
                .background(Color.primary900)
                .cornerRadius(DesignTokens.CornerRadius.pill)
        }
        .padding(.horizontal, DesignTokens.Spacing.md)
        .padding(.top, DesignTokens.Spacing.md)
    }

    // MARK: - Logout Dialog
    private var logoutDialog: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture { viewModel.showLogoutDialog = false }

            VStack(spacing: DesignTokens.Spacing.lg) {
                Text("Ready to log out?")
                    .font(.anton(DesignTokens.FontSize.subheadline))
                    .foregroundColor(.neutral900)

                HStack(spacing: DesignTokens.Spacing.md) {
                    Button(action: { viewModel.showLogoutDialog = false }) {
                        Text("Cancel")
                            .font(.system(size: DesignTokens.FontSize.body, weight: .medium))
                            .foregroundColor(.neutral900)
                            .padding(.horizontal, DesignTokens.Spacing.xl)
                            .padding(.vertical, DesignTokens.Spacing.sm)
                            .background(Color.neutral100.opacity(0.5))
                            .cornerRadius(DesignTokens.CornerRadius.pill)
                    }

                    Button(action: { viewModel.logout() }) {
                        Text("Log out")
                            .font(.system(size: DesignTokens.FontSize.body, weight: .medium))
                            .foregroundColor(.white)
                            .padding(.horizontal, DesignTokens.Spacing.xl)
                            .padding(.vertical, DesignTokens.Spacing.sm)
                            .background(Color.primary900)
                            .cornerRadius(DesignTokens.CornerRadius.pill)
                    }
                }
            }
            .padding(DesignTokens.Spacing.lg)
            .background(Color.white)
            .cornerRadius(DesignTokens.CornerRadius.medium)
            .padding(.horizontal, DesignTokens.Spacing.xl)
        }
    }
}

// MARK: - Profile Menu Item
struct ProfileMenuItem: View {
    let icon: String
    let title: String
    var action: (() -> Void)? = nil

    var body: some View {
        Button(action: { action?() }) {
            HStack(spacing: DesignTokens.Spacing.sm) {
                Image(systemName: icon)
                    .font(.system(size: 16))
                    .foregroundColor(.neutral600)
                    .frame(width: 24, height: 24)

                Text(title)
                    .font(.system(size: DesignTokens.FontSize.body))
                    .foregroundColor(.neutral900)

                Spacer()

                Image(systemName: "arrow.right")
                    .font(.system(size: 14))
                    .foregroundColor(.neutral600)
            }
            .padding(.horizontal, DesignTokens.Spacing.md)
            .padding(.vertical, DesignTokens.Spacing.sm)
            .background(Color.white)
            .cornerRadius(DesignTokens.CornerRadius.medium)
        }
        .padding(.horizontal, DesignTokens.Spacing.md)
    }
}

#Preview {
    MyProfileTabView(
        viewModel: MyProfileViewModel(router: Router())
    )
}
