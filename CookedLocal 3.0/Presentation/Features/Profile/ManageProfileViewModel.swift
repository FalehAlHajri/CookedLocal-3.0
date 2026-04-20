//
//  ManageProfileViewModel.swift
//  Cooked Local
//

import SwiftUI
import Combine
import PhotosUI

final class ManageProfileViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var userName: String = ""
    @Published var email: String = ""
    @Published var selectedImageItem: PhotosPickerItem? = nil
    @Published var selectedImageData: Data? = nil
    @Published var profileImageURL: String? = nil
    @Published private(set) var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    @Published var successMessage: String? = nil

    // MARK: - Dependencies
    private let router: Router
    private let userService: UserService
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Initialization
    init(router: Router, userService: UserService) {
        self.router = router
        self.userService = userService
        loadFromSession()
        Task { await loadProfile() }

        $selectedImageItem
            .compactMap { $0 }
            .sink { item in
                Task { @MainActor in
                    if let data = try? await item.loadTransferable(type: Data.self) {
                        self.selectedImageData = data
                    }
                }
            }
            .store(in: &cancellables)
    }

    // MARK: - Methods

    func goBack() {
        router.pop()
    }

    @MainActor
    func updateProfile() async {
        guard !userName.trimmingCharacters(in: .whitespaces).isEmpty else {
            errorMessage = "Name cannot be empty."
            return
        }
        isLoading = true
        errorMessage = nil
        do {
            let updatedProfile = try await userService.updateMyProfile(name: userName, image: selectedImageData)
            profileImageURL = updatedProfile.profile_url
            successMessage = "Profile updated successfully."
            // Update cached session user
            if let current = SessionManager.shared.currentUser {
                let updated = SessionUser(
                    id: current.id,
                    name: updatedProfile.name ?? current.name,
                    email: updatedProfile.email ?? current.email,
                    role: current.role,
                    profileUrl: updatedProfile.profile_url,
                    shopName: current.shopName
                )
                SessionManager.shared.updateUser(updated)
            }
        } catch {
            errorMessage = "Failed to update profile. Please try again."
        }
        isLoading = false
    }

    // MARK: - Private Methods

    private func loadFromSession() {
        if let user = SessionManager.shared.currentUser {
            userName = user.name
            email = user.email
            profileImageURL = user.profileUrl
        }
    }

    @MainActor
    private func loadProfile() async {
        do {
            let profile = try await userService.fetchMyProfile()
            userName = profile.name ?? userName
            email = profile.email ?? email
            profileImageURL = profile.profile_url
        } catch {
            // Keep session data as fallback
        }
    }
}
