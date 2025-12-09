import SwiftUI

// MARK: - Neo-Brutalism Colors
public struct NeoColors {
    static let background = Color(hex: "FDFDFD") // Off-white
    static let text = Color.black
    static let border = Color.black
    
    // Vibrant Accents
    static let primary = Color(hex: "5D5FEF") // Bright Blue
    static let secondary = Color(hex: "FF5C00") // Orange
    static let success = Color(hex: "00C48C") // Green
    static let warning = Color(hex: "FFD600") // Yellow
    static let error = Color(hex: "FF3B30") // Red
    static let pink = Color(hex: "FF9F9F") // Pink
}

// MARK: - View Modifiers
struct NeoShadow: ViewModifier {
    var color: Color = .black
    var radius: CGFloat = 0
    var x: CGFloat = 4
    var y: CGFloat = 4
    
    func body(content: Content) -> some View {
        content
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(NeoColors.border, lineWidth: 2)
            )
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white)
            )
            .shadow(color: color, radius: 0, x: x, y: y)
    }
}

struct NeoButton: ViewModifier {
    var backgroundColor: Color
    
    func body(content: Content) -> some View {
        content
            .padding()
            .background(backgroundColor)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(NeoColors.border, lineWidth: 2)
            )
            .shadow(color: .black, radius: 0, x: 4, y: 4)
            .foregroundColor(.black)
            .font(.system(size: 16, weight: .bold))
    }
}

struct NeoCard: ViewModifier {
    var backgroundColor: Color = .white
    
    func body(content: Content) -> some View {
        content
            .padding()
            .background(backgroundColor)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(NeoColors.border, lineWidth: 2)
            )
            .shadow(color: .black, radius: 0, x: 4, y: 4)
    }
}

// MARK: - Extensions
extension View {
    func neoShadow() -> some View {
        modifier(NeoShadow())
    }
    
    func neoButton(color: Color = NeoColors.primary) -> some View {
        modifier(NeoButton(backgroundColor: color))
    }
    
    func neoCard(color: Color = .white) -> some View {
        modifier(NeoCard(backgroundColor: color))
    }
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
