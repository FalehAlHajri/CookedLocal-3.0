//
//  AppRoute.swift
//  Cooked Local
//

import Foundation

enum AppRoute: Hashable {
    case splash
    case onboarding
    case selectRole
    case signUp(role: UserRole)
    case signUpDetails(role: UserRole)
    case signIn(role: UserRole = .customer)
    case resetPassword
    case otp(emailOrPhone: String)
    case registrationOTP(email: String)
    case newPassword
    case success(message: String, subtitle: String, buttonTitle: String, navigateToHome: Bool)
    case home
    case chefHome
    case search
    case cart
    case confirmOrder
    case payment(address: String, note: String?)
    case cashOnDelivery
    case shopDetail(chef: Chef)
    case foodDetail(item: FoodItem, isFromOrder: Bool = false, isFromChef: Bool = false)
    case review(item: FoodItem)
    case notifications
    case manageProfile
    case manageShop
    case paymentMethods
    case changePassword
    case privacyPolicy
    case termsAndConditions
    case aboutUs
    case editDish(item: FoodItem)
    case addDish
}
