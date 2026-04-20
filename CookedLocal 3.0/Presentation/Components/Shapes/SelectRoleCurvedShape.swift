//
//  SelectRoleCurvedShape.swift
//  Cooked Local
//

import SwiftUI

struct SelectRoleCurvedShape: Shape {
    func path(in rect: CGRect) -> Path {
        let w = rect.width
        let h = rect.height

        var path = Path()

        path.move(to: CGPoint(x: 0, y: h))
        path.addLine(to: CGPoint(x: w, y: h))
        path.addLine(to: CGPoint(x: w, y: 0))
        path.addQuadCurve(
            to: CGPoint(x: 0, y: h),
            control: CGPoint(x: w * 0.3, y: h * 0.5)
        )
        path.closeSubpath()

        return path
    }
}

#Preview {
    SelectRoleCurvedShape()
        .fill(Color.white)
        .frame(height: 200)
        .background(Color.gray)
}
