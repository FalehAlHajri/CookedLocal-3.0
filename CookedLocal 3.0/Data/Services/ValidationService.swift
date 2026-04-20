//
//  ValidationService.swift
//  Cooked Local
//

import Foundation

final class ValidationService: ValidationServiceProtocol {
    func isValidEmail(_ email: String) -> Bool {
        let emailRegex = #"^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$"#
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }

    func isValidPhone(_ phone: String) -> Bool {
        // UK mobile number validation: starts with 07, followed by 9 digits (total 11 digits)
        let cleaned = phone.replacingOccurrences(of: " ", with: "").replacingOccurrences(of: "-", with: "")
        let phoneRegex = #"^(07\d{9}|\+447\d{9})$"#
        let phonePredicate = NSPredicate(format: "SELF MATCHES %@", phoneRegex)
        return phonePredicate.evaluate(with: cleaned)
    }

    func isValidPassword(_ password: String) -> Bool {
        password.count >= 8
    }

    func isValidName(_ name: String) -> Bool {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.count >= 2
    }

    func isValidEmailOrPhone(_ input: String) -> Bool {
        isValidEmail(input) || isValidPhone(input)
    }
}
