//
//  MyProfileViewModel.swift
//  Cooked Local
//

import SwiftUI
import Combine

final class MyProfileViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published private(set) var userName: String = "User"
    @Published private(set) var userEmail: String = ""
    @Published private(set) var profileImageURL: String?
    @Published var showLogoutDialog: Bool = false
    @Published private(set) var isLoading: Bool = false

    /// Backward-compatible property used by views that render a local asset name
    var profileImageName: String { "placeholderProfileImage" }

    // MARK: - Properties
    let isChef: Bool

    // MARK: - Dependencies
    private let router: Router
    private let userService: UserService
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Initialization
    init(router: Router, isChef: Bool = false, userService: UserService = UserService()) {
        self.router = router
        self.isChef = isChef
        self.userService = userService
        loadFromSession()
        Task { await loadProfile() }

        SessionManager.shared.$currentUser
            .compactMap { $0 }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] user in
                self?.userName = user.name
                self?.userEmail = user.email
                self?.profileImageURL = user.profileUrl
            }
            .store(in: &cancellables)
    }

    // MARK: - Methods

    func navigateToManageProfile() {
        router.navigate(to: isChef ? .manageShop : .manageProfile)
    }

    func navigateToPaymentMethods() {
        router.navigate(to: .paymentMethods)
    }

    func navigateToChangePassword() {
        router.navigate(to: .changePassword)
    }

    func navigateToPrivacyPolicy() {
        router.navigate(to: .privacyPolicy)
    }

    func navigateToTermsAndConditions() {
        router.navigate(to: .termsAndConditions)
    }

    func navigateToAboutUs() {
        router.navigate(to: .aboutUs)
    }

    func confirmLogout() {
        showLogoutDialog = true
    }

    @MainActor
    func logout() {
        showLogoutDialog = false
        SessionManager.shared.clearSession()
        router.replace(with: .signIn())
    }

    @MainActor
    func refresh() async {
        await loadProfile()
    }

    // MARK: - Private Methods

    private func loadFromSession() {
        if let user = SessionManager.shared.currentUser {
            userName = user.name
            userEmail = user.email
            profileImageURL = user.profileUrl
        }
    }

    @MainActor
    private func loadProfile() async {
        isLoading = true
        do {
            let profile = try await userService.fetchMyProfile()
            userName = profile.name ?? userName
            userEmail = profile.email ?? userEmail
            profileImageURL = profile.profile_url
        } catch {
            // Keep session data as fallback
        }
        isLoading = false
    }
}
