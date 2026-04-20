//
//  ManageProfileView.swift
//  Cooked Local
//

import SwiftUI
import PhotosUI

struct ManageProfileView: View {
    @StateObject var viewModel: ManageProfileViewModel

    var body: some View {
        VStack(spacing: 0) {
            headerSection

            ScrollView(showsIndicators: false) {
                VStack(spacing: DesignTokens.Spacing.lg) {
                    profileImageSection

                    formSection

                    updateButton

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

                    Spacer()
                }
                .padding(.top, DesignTokens.Spacing.md)
            }
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

            Text("Manage Profile")
                .font(.anton(DesignTokens.FontSize.subheadline))
                .foregroundColor(.neutral900)

            Spacer()
        }
        .padding(.horizontal, DesignTokens.Spacing.md)
        .padding(.vertical, DesignTokens.Spacing.md)
    }

    // MARK: - Profile Image
    private var profileImageSection: some View {
        PhotosPicker(selection: $viewModel.selectedImageItem, matching: .images) {
            ZStack(alignment: .bottomTrailing) {
                if let data = viewModel.selectedImageData, let uiImage = UIImage(data: data) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 100, height: 100)
                        .clipShape(Circle())
                } else {
                    CachedProfileImage(urlString: viewModel.profileImageURL, size: 100)
                }

                Image(systemName: "camera.fill")
                    .font(.system(size: 14))
                    .foregroundColor(.white)
                    .frame(width: 30, height: 30)
                    .background(Color.neutral600.opacity(0.7))
                    .clipShape(Circle())
            }
        }
    }

    // MARK: - Form Section
    private var formSection: some View {
        VStack(spacing: DesignTokens.Spacing.md) {
            IconTextField(
                icon: "person",
                placeholder: "User Name",
                text: $viewModel.userName
            )

            IconTextField(
                icon: "envelope",
                placeholder: "Enter your Email",
                text: $viewModel.email,
                keyboardType: .emailAddress
            )
            .disabled(true)
            .opacity(0.6)
        }
        .padding(.horizontal, DesignTokens.Spacing.md)
    }

    // MARK: - Update Button
    private var updateButton: some View {
        Button(action: {
            Task { await viewModel.updateProfile() }
        }) {
            if viewModel.isLoading {
                ProgressView()
                    .tint(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, DesignTokens.Spacing.sm)
            } else {
                Text("Update Profile")
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
}

#Preview {
    ManageProfileView(viewModel: ManageProfileViewModel(router: Router(), userService: UserService()))
}
