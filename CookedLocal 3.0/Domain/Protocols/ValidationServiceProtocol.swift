//
//  ValidationServiceProtocol.swift
//  Cooked Local
//

import Foundation

protocol ValidationServiceProtocol {
    func isValidEmail(_ email: String) -> Bool
    func isValidPhone(_ phone: String) -> Bool
    func isValidPassword(_ password: String) -> Bool
    func isValidName(_ name: String) -> Bool
}
