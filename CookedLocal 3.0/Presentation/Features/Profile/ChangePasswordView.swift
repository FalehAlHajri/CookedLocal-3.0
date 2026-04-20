//
//  ChangePasswordView.swift
//  Cooked Local
//

import SwiftUI

struct ChangePasswordView: View {
    @StateObject var viewModel: ChangePasswordViewModel
    @State private var showOldPassword: Bool = false
    @State private var showNewPassword: Bool = false
    @State private var showConfirmPassword: Bool = false

    var body: some View {
        VStack(spacing: 0) {
            headerSection

            VStack(spacing: DesignTokens.Spacing.lg) {
                formSection

                if let error = viewModel.errorMessage {
                    Text(error)
                        .font(.system(size: DesignTokens.FontSize.caption))
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, DesignTokens.Spacing.md)
                }

                if let success = viewModel.successMessage {
                    Text(success)
                        .font(.system(size: DesignTokens.FontSize.caption))
                        .foregroundColor(.green)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, DesignTokens.Spacing.md)
                }

                updateButton

                forgotPasswordLink

                Spacer()
            }
            .padding(.top, DesignTokens.Spacing.md)
        }
        .background(Color.backgroundColor)
        .navigationBarHidden(true)
    }

    // MARK: - Header Section
    private var headerSection: some View {
        HStack(spacing: DesignTokens.Spacing.sm) {
            Button(action: { viewModel.goBack() }) {
                Image(systemName: "arrow.left")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.neutral900)
                    .frame(width: 44, height: 44)
                    .background(Color.neutral100.opacity(0.5))
                    .clipShape(Circle())
            }

            Text("Change Password")
                .font(.anton(DesignTokens.FontSize.subheadline))
                .foregroundColor(.neutral900)

            Spacer()
        }
        .padding(.horizontal, DesignTokens.Spacing.md)
        .padding(.vertical, DesignTokens.Spacing.md)
    }

    // MARK: - Form Section
    private var formSection: some View {
        VStack(spacing: DesignTokens.Spacing.md) {
            PasswordField(
                icon: "lock",
                placeholder: "Enter Your Old Password",
                text: $viewModel.oldPassword,
                isVisible: $showOldPassword
            )

            PasswordField(
                icon: "lock",
                placeholder: "Enter Your New Password",
                text: $viewModel.newPassword,
                isVisible: $showNewPassword
            )

            PasswordField(
                icon: "lock",
                placeholder: "Re-type Your New Password",
                text: $viewModel.confirmPassword,
                isVisible: $showConfirmPassword
            )
        }
        .padding(.horizontal, DesignTokens.Spacing.md)
    }

    // MARK: - Update Button
    private var updateButton: some View {
        Button(action: {
            Task { await viewModel.updatePassword() }
        }) {
            if viewModel.isLoading {
                ProgressView()
                    .tint(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, DesignTokens.Spacing.sm)
            } else {
                Text("Update Password")
                    .font(.anton(DesignTokens.FontSize.body))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, DesignTokens.Spacing.sm)
            }
        }
        .background(Color.brandOrange)
        .cornerRadius(DesignTokens.CornerRadius.pill)
        .padding(.horizontal, DesignTokens.Spacing.md)
        .disabled(viewModel.isLoading)
    }

    // MARK: - Forgot Password Link
    private var forgotPasswordLink: some View {
        HStack(spacing: 4) {
            Text("Forgot Password ?")
                .font(.system(size: DesignTokens.FontSize.body))
                .foregroundColor(.neutral900)

            Button(action: { viewModel.navigateToResetPassword() }) {
                Text("Reset Now")
                    .font(.system(size: DesignTokens.FontSize.body, weight: .semibold))
                    .foregroundColor(.brandOrange)
            }
        }
    }
}

// MARK: - Password Field
struct PasswordField: View {
    let icon: String
    let placeholder: String
    @Binding var text: String
    @Binding var isVisible: Bool

    var body: some View {
        HStack(spacing: DesignTokens.Spacing.sm) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(.neutral600)
                .frame(width: 24)

            Group {
                if isVisible {
                    TextField("", text: $text, prompt: Text(placeholder).foregroundColor(.neutral600))
                } else {
                    SecureField("", text: $text, prompt: Text(placeholder).foregroundColor(.neutral600))
                }
            }
            .font(.system(size: DesignTokens.FontSize.body))
            .foregroundColor(.neutral900)
            .tint(.neutral900)

            Button(action: { isVisible.toggle() }) {
                Image(systemName: isVisible ? "eye" : "eye.slash")
                    .font(.system(size: 16))
                    .foregroundColor(.neutral600)
            }
        }
        .padding(.horizontal, DesignTokens.Spacing.md)
        .padding(.vertical, DesignTokens.Spacing.md)
        .background(Color.white)
        .cornerRadius(DesignTokens.CornerRadius.large)
        .overlay(
            RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.large)
                .stroke(Color.neutral100, lineWidth: 1)
        )
    }
}

#Preview {
    ChangePasswordView(viewModel: ChangePasswordViewModel(router: Router(), userService: UserService()))
}
