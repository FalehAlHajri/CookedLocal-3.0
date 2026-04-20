//
//  DesignTokens.swift
//  Cooked Local
//

import SwiftUI

enum DesignTokens {
    enum Spacing {
        static let xs: CGFloat = 8
        static let sm: CGFloat = 12
        static let md: CGFloat = 16
        static let lg: CGFloat = 24
        static let xl: CGFloat = 32
        static let xxl: CGFloat = 40
    }

    enum CornerRadius {
        static let small: CGFloat = 8
        static let medium: CGFloat = 16
        static let large: CGFloat = 27
        static let pill: CGFloat = 30
    }

    enum FontSize {
        static let caption: CGFloat = 12
        static let body: CGFloat = 14
        static let subheadline: CGFloat = 16
        static let headline: CGFloat = 24
        static let display: CGFloat = 48
    }

    enum ImageHeight {
        static let authScreenRatio: CGFloat = 0.55
        static let onboardingScreenRatio: CGFloat = 0.5
        static let curveRatio: CGFloat = 0.25
    }
}
