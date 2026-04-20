//
//  AppleSignInService.swift
//  Cooked Local
//

import Foundation
import AuthenticationServices

final class AppleSignInService: NSObject {
    static let shared = AppleSignInService()

    private var completionHandler: ((Result<AppleSignInCredentials, Error>) -> Void)?

    private override init() {}

    func signIn() async throws -> AppleSignInCredentials {
        try await withCheckedThrowingContinuation { continuation in
            signIn { result in
                continuation.resume(with: result)
            }
        }
    }

    private func signIn(completion: @escaping (Result<AppleSignInCredentials, Error>) -> Void) {
        self.completionHandler = completion

        let request = ASAuthorizationAppleIDProvider().createRequest()
        request.requestedScopes = [.fullName, .email]

        let controller = ASAuthorizationController(authorizationRequests: [request])
        controller.delegate = self
        controller.presentationContextProvider = self
        controller.performRequests()
    }
}

// MARK: - ASAuthorizationControllerDelegate

extension AppleSignInService: ASAuthorizationControllerDelegate {
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential else {
            completionHandler?(.failure(AppleSignInError.invalidCredential))
            return
        }

        guard let identityToken = appleIDCredential.identityToken,
              let tokenString = String(data: identityToken, encoding: .utf8) else {
            completionHandler?(.failure(AppleSignInError.noIdentityToken))
            return
        }

        let credentials = AppleSignInCredentials(
            userId: appleIDCredential.user,
            email: appleIDCredential.email,
            fullName: appleIDCredential.fullName,
            identityToken: tokenString
        )

        completionHandler?(.success(credentials))
    }

    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        completionHandler?(.failure(error))
    }
}

// MARK: - ASAuthorizationControllerPresentationContextProviding

extension AppleSignInService: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else {
            fatalError("No window found")
        }
        return window
    }
}

// MARK: - Supporting Types

struct AppleSignInCredentials {
    let userId: String
    let email: String?
    let fullName: PersonNameComponents?
    let identityToken: String
}

enum AppleSignInError: Error {
    case invalidCredential
    case noIdentityToken
}
