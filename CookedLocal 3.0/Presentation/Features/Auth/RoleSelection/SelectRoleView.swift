//
//  SelectRoleView.swift
//  Cooked Local
//

import SwiftUI

struct SelectRoleView: View {
    @StateObject var viewModel: SelectRoleViewModel

    var body: some View {
        AuthScreenLayout(imageName: "CakeImage", showBackButton: true) {
            Spacer()

            Text("SELECT YOUR ROLE")
                .font(.anton(DesignTokens.FontSize.headline))
                .foregroundColor(Color.neutral900)

            Spacer()

            OutlinedButton(title: "Join as a Chef") {
                viewModel.selectRole(.chef)
            }
            .padding(.horizontal, DesignTokens.Spacing.lg)

            PrimaryButton(title: "Join as a Customer", action: {
                viewModel.selectRole(.customer)
            }, backgroundColor: .primary900)
            .padding(.horizontal, DesignTokens.Spacing.lg)
            .padding(.bottom, DesignTokens.Spacing.xxl)
        }
    }
}

#Preview {
    SelectRoleView(viewModel: SelectRoleViewModel(router: Router()))
}
