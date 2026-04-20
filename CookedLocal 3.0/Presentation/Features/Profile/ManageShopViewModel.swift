//
//  ManageShopViewModel.swift
//  Cooked Local
//

import SwiftUI
import Combine

final class ManageShopViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var shopName: String = ""
    @Published var email: String = ""
    @Published var phoneNumber: String = ""
    @Published var shopLocation: String = ""
    @Published var shortBio: String = ""
    @Published var facebookURL: String = ""
    @Published var instagramURL: String = ""
    @Published var whatsappNumber: String = ""
    @Published var profileImageURL: String?
    @Published var selectedProfileImage: UIImage?
    @Published var selectedBannerImage: UIImage?
    @Published var selectedQualificationData: Data?
    @Published var qualificationFileName: String?
    @Published private(set) var isLoading: Bool = false
    @Published private(set) var errorMessage: String?
    @Published private(set) var successMessage: String?

    // MARK: - Dependencies
    private let router: Router
    private let userService: UserService

    // MARK: - Initialization
    init(router: Router, userService: UserService) {
        self.router = router
        self.userService = userService
        loadFromSession()
        Task { await loadProfile() }
    }

    // MARK: - Methods

    func goBack() {
        router.pop()
    }

    @MainActor
    func updateShop() async {
        errorMessage = nil
        successMessage = nil
        isLoading = true

        let profileData = selectedProfileImage?.jpegData(compressionQuality: 0.8)
        let bannerData = selectedBannerImage?.jpegData(compressionQuality: 0.8)

        do {
            let profile = try await userService.updateShopProfile(
                shopName: shopName.isEmpty ? nil : shopName,
                bio: shortBio.isEmpty ? nil : shortBio,
                phoneNumber: phoneNumber.isEmpty ? nil : phoneNumber,
                location: shopLocation.isEmpty ? nil : shopLocation,
                facebookUrl: facebookURL.isEmpty ? nil : facebookURL,
                instagramUrl: instagramURL.isEmpty ? nil : instagramURL,
                whatsappNumber: whatsappNumber.isEmpty ? nil : whatsappNumber,
                profileImage: profileData,
                bannerImage: bannerData,
                qualificationPDF: selectedQualificationData
            )
            successMessage = "Shop details updated successfully!"
            profileImageURL = profile.profile_url

            // Update session
            if let user = SessionManager.shared.currentUser {
                var updated = user
                if let url = profile.profile_url {
                    updated = SessionUser(id: user.id, name: shopName.isEmpty ? user.name : shopName, email: user.email, role: user.role, profileUrl: url)
                }
                SessionManager.shared.updateUser(updated)
            }
        } catch let apiError as APIError {
            errorMessage = apiError.errorDescription
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    // MARK: - Private

    private func loadFromSession() {
        if let user = SessionManager.shared.currentUser {
            email = user.email
        }
    }

    @MainActor
    private func loadProfile() async {
        do {
            let profile = try await userService.fetchMyProfile()
            email = profile.email ?? email
            shopName = profile.shop?.shop_name ?? ""
            shortBio = profile.shop?.bio ?? ""
            phoneNumber = profile.phone_number ?? ""
            shopLocation = profile.shop?.location ?? ""
            facebookURL = profile.social_info?.facebook_url ?? ""
            instagramURL = profile.social_info?.instagram_url ?? ""
            whatsappNumber = profile.social_info?.whatsapp_number ?? ""
            profileImageURL = profile.profile_url
        } catch {
            print("[ManageShopViewModel] loadProfile error: \(error)")
        }
    }
}
