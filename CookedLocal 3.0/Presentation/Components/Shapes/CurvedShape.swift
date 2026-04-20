//
//  CurvedShape.swift
//  Cooked Local
//

import SwiftUI

struct CurvedShape: Shape {
    func path(in rect: CGRect) -> Path {
        let w = rect.width
        let h = rect.height

        var path = Path()

        path.move(to: CGPoint(x: 0, y: 0))

        path.addCurve(
            to:       CGPoint(x: w, y: h),
            control1: CGPoint(x: 43.0  / 376 * w, y: 49.0  / 187 * h),
            control2: CGPoint(x: 159.0 / 376 * w, y: 124.0 / 187 * h)
        )

        path.addLine(to: CGPoint(x: 0, y: h))
        path.closeSubpath()

        return path
    }
}

#Preview {
    CurvedShape()
        .fill(Color.white)
        .frame(height: 200)
        .background(Color.gray)
}
