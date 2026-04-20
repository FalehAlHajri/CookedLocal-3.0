//
//  OTPView.swift
//  Cooked Local
//

import SwiftUI

struct OTPView: View {
    @StateObject var viewModel: OTPViewModel
    @FocusState private var focusedField: Int?

    var body: some View {
        AuthScreenLayout(imageName: "CakeImage", showBackButton: true) {
            Spacer()

            Text("ENTER OTP")
                .font(.anton(DesignTokens.FontSize.headline))
                .foregroundColor(Color.neutral900)

            Text("We sent a verification code to your email")
                .font(.anton(DesignTokens.FontSize.caption))
                .foregroundColor(Color.neutral600)
                .multilineTextAlignment(.center)

            Spacer()

            HStack(spacing: DesignTokens.Spacing.sm) {
                ForEach(0..<6, id: \.self) { index in
                    OTPTextField(
                        text: $viewModel.otpDigits[index],
                        isFocused: focusedField == index
                    )
                    .focused($focusedField, equals: index)
                    .onChange(of: viewModel.otpDigits[index]) { newValue in
                        if newValue.count == 1 && index < 5 {
                            focusedField = index + 1
                        } else if newValue.isEmpty && index > 0 {
                            focusedField = index - 1
                        }
                    }
                }
            }
            .padding(.horizontal, DesignTokens.Spacing.lg)

            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .font(.anton(DesignTokens.FontSize.caption))
                    .foregroundColor(.red)
                    .padding(.horizontal, DesignTokens.Spacing.lg)
            }

            Spacer()

            PrimaryButton(
                title: "Verify",
                action: {
                    Task {
                        await viewModel.verifyOTP()
                    }
                },
                isLoading: viewModel.isLoading
            )
            .padding(.horizontal, DesignTokens.Spacing.lg)

            Button(action: {
                Task {
                    await viewModel.resendOTP()
                }
            }) {
                Text("Resend OTP")
                    .font(.anton(DesignTokens.FontSize.caption))
                    .foregroundColor(Color.brandOrange)
            }
            .padding(.bottom, DesignTokens.Spacing.xxl)
        }
        .onAppear {
            focusedField = 0
        }
    }
}

#Preview {
    OTPView(viewModel: OTPViewModel(
        emailOrPhone: "test@example.com",
        router: Router(),
        authService: AuthService()
    ))
}
