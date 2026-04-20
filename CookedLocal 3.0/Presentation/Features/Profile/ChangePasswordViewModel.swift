//
//  ChangePasswordViewModel.swift
//  Cooked Local
//

import SwiftUI
import Combine

final class ChangePasswordViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var oldPassword: String = ""
    @Published var newPassword: String = ""
    @Published var confirmPassword: String = ""
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
    }

    // MARK: - Methods

    func goBack() {
        router.pop()
    }

    func navigateToResetPassword() {
        router.navigate(to: .resetPassword)
    }

    @MainActor
    func updatePassword() async {
        errorMessage = nil
        successMessage = nil

        guard !oldPassword.isEmpty else {
            errorMessage = "Please enter your old password."
            return
        }
        guard newPassword.count >= 6 else {
            errorMessage = "New password must be at least 6 characters."
            return
        }
        guard newPassword == confirmPassword else {
            errorMessage = "Passwords do not match."
            return
        }

        isLoading = true
        do {
            try await userService.changePassword(oldPassword: oldPassword, newPassword: newPassword, confirmPassword: confirmPassword)
            successMessage = "Password updated successfully!"
            oldPassword = ""
            newPassword = ""
            confirmPassword = ""
        } catch let apiError as APIError {
            errorMessage = apiError.errorDescription
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
}
