//
//  SessionManager.swift
//  Cooked Local
//

import SwiftUI
import Combine

final class SessionManager: ObservableObject {
    static let shared = SessionManager()

    @Published var currentUser: SessionUser?
    @Published var isAuthenticated: Bool = false

    private init() {
        refreshFromStorage()
    }

    // MARK: - Public Methods

    func saveSession(user: SessionUser, token: String) {
        TokenManager.shared.saveToken(token)
        TokenManager.shared.saveCurrentUser(user)
        DispatchQueue.main.async {
            self.currentUser = user
            self.isAuthenticated = true
        }
    }

    func clearSession() {
        TokenManager.shared.deleteToken()
        TokenManager.shared.deleteCurrentUser()
        TokenManager.shared.clearOTPEmail()
        CachedProfileImage.clearCache()
        DispatchQueue.main.async {
            self.currentUser = nil
            self.isAuthenticated = false
        }
    }

    func updateUser(_ user: SessionUser) {
        let oldURL = currentUser?.profileUrl
        TokenManager.shared.saveCurrentUser(user)
        if user.profileUrl != oldURL {
            CachedProfileImage.clearCache()
        }
        DispatchQueue.main.async {
            self.currentUser = user
        }
    }

    func refreshFromStorage() {
        let user = TokenManager.shared.getCurrentUser()
        let token = TokenManager.shared.getToken()
        DispatchQueue.main.async {
            self.currentUser = user
            self.isAuthenticated = user != nil && token != nil
        }
    }
}
