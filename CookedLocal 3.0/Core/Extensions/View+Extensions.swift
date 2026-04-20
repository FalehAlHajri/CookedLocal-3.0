//
//  View+Extensions.swift
//  Cooked Local
//

import SwiftUI

#if canImport(UIKit)
import UIKit
#endif

extension View {
    func hideKeyboard() {
        #if canImport(UIKit)
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        #endif
    }
}
