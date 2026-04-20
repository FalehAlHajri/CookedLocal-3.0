//
//  InfoPageView.swift
//  Cooked Local
//

import SwiftUI

struct InfoPageView: View {
    @StateObject var viewModel: InfoPageViewModel

    var body: some View {
        VStack(spacing: 0) {
            headerSection

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: DesignTokens.Spacing.lg) {
                    illustrationSection

                    Text(contentForType(viewModel.pageType))
                        .font(.system(size: DesignTokens.FontSize.body))
                        .foregroundColor(.neutral600)
                        .lineSpacing(6)
                        .padding(.horizontal, DesignTokens.Spacing.md)
                }
                .padding(.bottom, DesignTokens.Spacing.lg)
            }
        }
        .background(Color.backgroundColor)
        .navigationBarHidden(true)
    }

    // MARK: - Header Section
    private var headerSection: some View {
        HStack(spacing: DesignTokens.Spacing.sm) {
            Button(action: { viewModel.goBack() }) {
                Image(systemName: "arrow.left")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.neutral900)
                    .frame(width: 44, height: 44)
                    .background(Color.neutral100.opacity(0.5))
                    .clipShape(Circle())
            }

            Text(viewModel.title)
                .font(.anton(DesignTokens.FontSize.subheadline))
                .foregroundColor(.neutral900)

            Spacer()
        }
        .padding(.horizontal, DesignTokens.Spacing.md)
        .padding(.vertical, DesignTokens.Spacing.md)
    }

    // MARK: - Illustration Section
    private var illustrationSection: some View {
        HStack {
            Spacer()
            ZStack {
                RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.medium)
                    .fill(Color.neutral100.opacity(0.3))
                    .frame(height: 180)

                VStack(spacing: DesignTokens.Spacing.sm) {
                    Image(systemName: iconForType(viewModel.pageType))
                        .font(.system(size: 50))
                        .foregroundColor(.brandOrange)

                    HStack(spacing: DesignTokens.Spacing.xl) {
                        Image(systemName: "checkmark.shield")
                            .font(.system(size: 24))
                            .foregroundColor(.neutral600)

                        Image(systemName: secondaryIconForType(viewModel.pageType))
                            .font(.system(size: 24))
                            .foregroundColor(.neutral600)

                        Image(systemName: "person.2.fill")
                            .font(.system(size: 20))
                            .foregroundColor(.neutral600)
                    }
                }
            }
            Spacer()
        }
        .padding(.horizontal, DesignTokens.Spacing.md)
    }

    // MARK: - Content Helpers
    private func contentForType(_ type: InfoPageType) -> String {
        switch type {
        case .terms:
            return termsAndConditionsContent
        case .about:
            return aboutUsContent
        case .privacy:
            return privacyPolicyContent
        }
    }

    private func iconForType(_ type: InfoPageType) -> String {
        switch type {
        case .terms: return "doc.text.fill"
        case .about: return "heart.fill"
        case .privacy: return "lock.shield.fill"
        }
    }

    private func secondaryIconForType(_ type: InfoPageType) -> String {
        switch type {
        case .terms: return "lock.fill"
        case .about: return "star.fill"
        case .privacy: return "hand.raised.fill"
        }
    }

    // MARK: - Terms and Conditions Content
    private var termsAndConditionsContent: String {
        """
        Terms and Conditions – Cooked Local
        
        Effective Date: April 2026
        
        Welcome to Cooked Local. By accessing or using our mobile application, website, or services (collectively, the "Platform"), you agree to be bound by these Terms and Conditions. If you do not agree, please do not use the Platform.
        
        
        1. Overview of Services
        
        Cooked Local is a platform that connects users with local chefs ("Providers") who prepare and sell homemade meals. Cooked Local facilitates ordering, payment processing, and communication but is not the direct provider of food.
        
        
        2. User Accounts
        
        To use certain features, you must create an account. You agree to:
        - Provide accurate and complete information
        - Keep your login credentials secure
        - Be responsible for all activity under your account
        
        We reserve the right to suspend or terminate accounts that violate these terms.
        
        
        3. Orders and Payments
        
        - All orders are subject to availability and acceptance by Providers
        - Prices are set by Providers and include applicable taxes or fees
        - Payments may be made via card (processed securely through third-party providers such as Stripe) or cash on delivery
        - Once an order is placed, cancellations may not be guaranteed
        
        
        4. Role of Cooked Local
        
        Cooked Local acts solely as an intermediary between Customers and Providers. We:
        - Do not prepare or handle food
        - Do not guarantee quality, safety, or legality of food items
        - Are not liable for actions or omissions of Providers
        
        
        5. Provider Responsibilities
        
        Providers (chefs) agree to:
        - Comply with all local food safety and hygiene regulations
        - Provide accurate descriptions of menu items
        - Fulfill accepted orders in a timely manner
        
        
        6. User Conduct
        
        You agree not to:
        - Use the platform for unlawful purposes
        - Provide false or misleading information
        - Interfere with platform functionality
        - Harass or abuse other users
        
        
        7. Reviews and Content
        
        Users may submit reviews and content. By doing so, you grant Cooked Local a non-exclusive right to use, display, and distribute such content. We reserve the right to remove inappropriate or misleading content.
        
        
        8. Intellectual Property
        
        All content, branding, and design of Cooked Local are owned by or licensed to us. You may not copy, reproduce, or distribute any material without permission.
        
        
        9. Limitation of Liability
        
        To the maximum extent permitted by law:
        - Cooked Local is not liable for indirect, incidental, or consequential damages
        - We do not guarantee uninterrupted or error-free service
        
        
        10. Account Suspension and Termination
        
        We may suspend or terminate accounts that:
        - Violate these Terms
        - Engage in fraudulent or harmful behavior
        - Breach platform policies
        
        
        11. Changes to Terms
        
        We may update these Terms from time to time. Continued use of the Platform after changes constitutes acceptance of the revised Terms.
        
        
        12. Governing Law
        
        These Terms shall be governed by and interpreted in accordance with the laws of the United Kingdom.
        
        
        13. Contact Us
        
        If you have any questions about these Terms, please contact us at:
        support@cookedlocal.com
        """
    }

    // MARK: - About Us Content
    private var aboutUsContent: String {
        """
        About Us
        
        Cooked Local is a modern food delivery platform built to connect people with authentic, home-cooked meals from local chefs in their community.
        
        We believe that great food isn't just made in restaurants — it's made in homes, by passionate individuals who bring culture, creativity, and authenticity to every dish. Our mission is to empower local chefs by giving them a platform to showcase their skills while providing customers with access to fresh, diverse, and meaningful meals.
        
        Through Cooked Local, users can:
        - Discover unique dishes made by local chefs
        - Support small, independent food creators
        - Enjoy a more personal and authentic food experience
        
        For chefs, Cooked Local offers the tools to:
        - Build their own food business
        - Reach new customers
        - Manage menus, orders, and profiles with ease
        
        We are committed to:
        - Simplicity and user-friendly design
        - Secure and reliable transactions
        - Building a trusted community of food lovers and creators
        
        Cooked Local is more than food delivery — it's a platform that brings people together through food, culture, and local talent.
        
        Local chefs. Real people. Real food.
        """
    }

    // MARK: - Privacy Policy Content
    private var privacyPolicyContent: String {
        """
        Privacy Policy – Cooked Local
        
        Effective Date: April 2026
        
        At Cooked Local, we are committed to protecting your personal information and respecting your privacy.
        
        
        1. Information We Collect
        
        We collect information that you provide directly to us, including:
        - Name and contact details
        - Profile information
        - Payment information (processed securely by third-party providers)
        - Order history
        - Location data (with your permission)
        
        
        2. How We Use Your Information
        
        We use your information to:
        - Process orders and payments
        - Connect you with local chefs
        - Provide customer support
        - Send notifications about your orders
        - Improve our services
        
        
        3. Information Sharing
        
        We share information with:
        - Chefs/Providers to fulfill orders
        - Payment processors to handle transactions
        - Service providers who assist our operations
        
        We do not sell your personal information to third parties.
        
        
        4. Data Security
        
        We implement appropriate security measures to protect your personal information from unauthorized access or disclosure.
        
        
        5. Your Rights
        
        You have the right to:
        - Access your personal information
        - Update or correct your information
        - Request deletion of your data
        - Opt out of marketing communications
        
        
        6. Contact Us
        
        If you have questions about this Privacy Policy, please contact us at:
        support@cookedlocal.com
        """
    }
}

#Preview {
    InfoPageView(viewModel: InfoPageViewModel(title: "Terms & Conditions", pageType: .terms, router: Router(), commonService: CommonService()))
}
