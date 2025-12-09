import Foundation
import SwiftUI

extension Date {
    func formatted() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd"
        return formatter.string(from: self)
    }
}

extension Color {
    static let customBackground = Color(.systemBackground)
    static let customSecondary = Color(.secondarySystemBackground)
}
