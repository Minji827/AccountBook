import Foundation

// MARK: - Exchange Rate Response Model
struct ExchangeRateResponse: Codable {
    let result: Int
    let curUnit: String
    let curNm: String
    let ttb: String?
    let tts: String?
    let dealBasR: String?
    let bkpr: String?
    let yyEfeeR: String?
    let tenDdEfeeR: String?
    let kftcDealBasR: String?
    let kftcBkpr: String?

    enum CodingKeys: String, CodingKey {
        case result
        case curUnit = "cur_unit"
        case curNm = "cur_nm"
        case ttb
        case tts
        case dealBasR = "deal_bas_r"
        case bkpr
        case yyEfeeR = "yy_efee_r"
        case tenDdEfeeR = "ten_dd_efee_r"
        case kftcDealBasR = "kftc_deal_bas_r"
        case kftcBkpr = "kftc_bkpr"
    }
}

// MARK: - Exchange Rate Model
struct ExchangeRate: Identifiable {
    let id = UUID()
    let currencyCode: String
    let currencyName: String
    let baseRate: Double
    let buyRate: Double?
    let sellRate: Double?
    let lastUpdated: Date

    init(from response: ExchangeRateResponse, lastUpdated: Date = Date()) {
        self.currencyCode = response.curUnit
        self.currencyName = response.curNm
        self.baseRate = Double(response.dealBasR?.replacingOccurrences(of: ",", with: "") ?? "0") ?? 0
        self.buyRate = Double(response.ttb?.replacingOccurrences(of: ",", with: "") ?? "0")
        self.sellRate = Double(response.tts?.replacingOccurrences(of: ",", with: "") ?? "0")
        self.lastUpdated = lastUpdated
    }

    var flag: String {
        switch currencyCode {
        case "USD": return "🇺🇸"
        case "JPY(100)": return "🇯🇵"
        case "EUR": return "🇪🇺"
        case "CNH": return "🇨🇳"
        case "GBP": return "🇬🇧"
        case "CHF": return "🇨🇭"
        case "CAD": return "🇨🇦"
        case "AUD": return "🇦🇺"
        case "HKD": return "🇭🇰"
        case "SGD": return "🇸🇬"
        case "AED": return "🇦🇪"
        case "BHD": return "🇧🇭"
        case "DKK": return "🇩🇰"
        case "IDR(100)": return "🇮🇩"
        case "KWD": return "🇰🇼"
        case "MYR": return "🇲🇾"
        case "NOK": return "🇳🇴"
        case "NZD": return "🇳🇿"
        case "SAR": return "🇸🇦"
        case "SEK": return "🇸🇪"
        case "THB": return "🇹🇭"
        default: return "🌍"
        }
    }

    var displayName: String {
        switch currencyCode {
        case "JPY(100)": return "JPY"
        default: return currencyCode
        }
    }
}
