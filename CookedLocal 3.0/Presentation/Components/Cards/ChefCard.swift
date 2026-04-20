//
//  ChefCard.swift
//  Cooked Local
//

import SwiftUI

struct ChefCard: View {
    let chef: Chef
    let onViewShop: () -> Void
    
    private let profileImageSize: CGFloat = 60
    private let coverHeight: CGFloat = 80

    var body: some View {
        VStack(alignment: .center, spacing: 0) {
            ZStack(alignment: .bottom) {
                UShapedCover(imageURL: chef.bannerURL, imageName: chef.bannerImageName, curveDepth: profileImageSize / 2)
                    .frame(height: coverHeight)

                chefProfileImage
                    .frame(width: profileImageSize, height: profileImageSize)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.white, lineWidth: 3))
                    .offset(y: profileImageSize * 0.65)
            }
            .padding(.bottom, profileImageSize * 0.65)
            
            VStack(alignment: .center, spacing: DesignTokens.Spacing.xs) {
                Text(chef.name)
                    .font(.anton(DesignTokens.FontSize.body))
                    .foregroundColor(.neutral900)
                    .lineLimit(1)
                    .multilineTextAlignment(.center)

                HStack(spacing: 4) {
                    Image(systemName: "star.fill")
                        .font(.system(size: 10))
                        .foregroundColor(.yellow)
                    Text("\(String(format: "%.1f", chef.rating)) (\(chef.reviewCount)+)")
                        .font(.system(size: DesignTokens.FontSize.caption))
                        .foregroundColor(.neutral600)
                }

                HStack(spacing: DesignTokens.Spacing.xs) {
                    if chef.hasFacebook { socialIcon("facebook") }
                    if chef.hasInstagram { socialIcon("instagram") }
                    if chef.hasWhatsApp { socialIcon("whatsapp") }
                }
                .padding(.vertical, 4)

                Button(action: onViewShop) {
                    Text("View Shop")
                        .font(.anton(DesignTokens.FontSize.caption))
                        .foregroundColor(.brandOrange)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 6)
                        .overlay(
                            RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.small)
                                .stroke(Color.brandOrange, lineWidth: 1)
                        )
                }
            }
            .padding(.horizontal, DesignTokens.Spacing.sm)
            .padding(.bottom, DesignTokens.Spacing.sm)
        }
        .background(Color.white)
        .cornerRadius(DesignTokens.CornerRadius.medium)
    }

    @ViewBuilder
    private var chefProfileImage: some View {
        if let urlString = chef.imageURL, let url = URL(string: urlString) {
            AsyncImage(url: url) { phase in
                switch phase {
                case .success(let img): img.resizable().aspectRatio(contentMode: .fill)
                default: Image(systemName: "person.circle.fill").resizable().foregroundColor(.neutral600)
                }
            }
        } else {
            Image(systemName: "person.circle.fill").resizable().foregroundColor(.neutral600)
        }
    }

    private func socialIcon(_ name: String) -> some View {
        Circle()
            .frame(width: 20, height: 20)
            .overlay(
                Image(name)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 12, height: 12)
            )
    }
}

// U-shaped cover with URL + local name support
struct UShapedCover: View {
    var imageURL: String?
    let imageName: String
    let curveDepth: CGFloat
    
    var body: some View {
        GeometryReader { geometry in
            Group {
                if let urlString = imageURL, let url = URL(string: urlString) {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .success(let img):
                            img.resizable().aspectRatio(contentMode: .fill)
                                .frame(width: geometry.size.width, height: geometry.size.height)
                                .transition(.opacity.animation(.easeIn(duration: 0.3)))
                        default:
                            Rectangle().fill(Color.neutral100)
                                .frame(width: geometry.size.width, height: geometry.size.height)
                        }
                    }
                } else {
                    Image(imageName)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: geometry.size.width, height: geometry.size.height)
                }
            }
            .clipShape(UShape(curveDepth: curveDepth))
        }
    }
}

struct UShape: Shape {
    let curveDepth: CGFloat
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: 0, y: 0))
        path.addLine(to: CGPoint(x: rect.maxX, y: 0))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addQuadCurve(
            to: CGPoint(x: 0, y: rect.maxY),
            control: CGPoint(x: rect.midX, y: rect.maxY + curveDepth)
        )
        path.addLine(to: CGPoint(x: 0, y: 0))
        return path
    }
}

#Preview {
    ChefCard(chef: Chef.samples[0], onViewShop: {})
        .frame(width: 170)
        .padding()
        .background(Color.backgroundColor)
}
