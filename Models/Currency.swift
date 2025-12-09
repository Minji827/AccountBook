import Foundation

enum Currency: String, CaseIterable, Codable, Identifiable {
    case krw = "KRW"
    case usd = "USD"
    case eur = "EUR"
    case jpy = "JPY"
    case cny = "CNY"
    
    var id: String { self.rawValue }
    
    var symbol: String {
        switch self {
        case .krw: return "₩"
        case .usd: return "$"
        case .eur: return "€"
        case .jpy: return "¥"
        case .cny: return "¥"
        }
    }
    
    var flag: String {
        switch self {
        case .krw: return "🇰🇷"
        case .usd: return "🇺🇸"
        case .eur: return "🇪🇺"
        case .jpy: return "🇯🇵"
        case .cny: return "🇨🇳"
        }
    }
}
