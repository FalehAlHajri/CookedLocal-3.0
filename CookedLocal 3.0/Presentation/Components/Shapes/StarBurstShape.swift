//
//  StarBurstShape.swift
//  Cooked Local
//

import SwiftUI

struct StarBurstShape: Shape {
    func path(in rect: CGRect) -> Path {
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let outerRadius = min(rect.width, rect.height) / 2
        let innerRadius = outerRadius * 0.75
        let points = 16

        var path = Path()

        for i in 0..<points * 2 {
            let radius = i.isMultiple(of: 2) ? outerRadius : innerRadius
            let angle = (Double(i) / Double(points * 2)) * 2 * .pi - .pi / 2
            let x = center.x + CGFloat(cos(angle)) * radius
            let y = center.y + CGFloat(sin(angle)) * radius

            if i == 0 {
                path.move(to: CGPoint(x: x, y: y))
            } else {
                path.addLine(to: CGPoint(x: x, y: y))
            }
        }

        path.closeSubpath()
        return path
    }
}

struct SuccessBadge: View {
    var body: some View {
        ZStack {
            StarBurstShape()
                .fill(Color.brandOrange)

            Image(systemName: "checkmark")
                .font(.system(size: 40, weight: .bold))
                .foregroundColor(.white)
        }
    }
}

#Preview {
    SuccessBadge()
        .frame(width: 120, height: 120)
}
