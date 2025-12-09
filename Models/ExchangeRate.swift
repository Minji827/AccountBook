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
        // 통화 코드에서 괄호 제거 (JPY(100) -> JPY)
        let cleanCode = currencyCode.components(separatedBy: "(").first ?? currencyCode

        switch cleanCode {
        // 주요 통화
        case "USD": return "🇺🇸"
        case "JPY": return "🇯🇵"
        case "EUR": return "🇪🇺"
        case "CNH", "CNY": return "🇨🇳"
        case "GBP": return "🇬🇧"
        case "CHF": return "🇨🇭"
        case "CAD": return "🇨🇦"
        case "AUD": return "🇦🇺"

        // 아시아/태평양
        case "HKD": return "🇭🇰"
        case "SGD": return "🇸🇬"
        case "THB": return "🇹🇭"
        case "MYR": return "🇲🇾"
        case "IDR": return "🇮🇩"
        case "PHP": return "🇵🇭"
        case "VND": return "🇻🇳"
        case "TWD": return "🇹🇼"
        case "INR": return "🇮🇳"
        case "PKR": return "🇵🇰"
        case "BDT": return "🇧🇩"
        case "LKR": return "🇱🇰"
        case "NZD": return "🇳🇿"
        case "FJD": return "🇫🇯"
        case "MNT": return "🇲🇳"

        // 중동
        case "AED": return "🇦🇪"
        case "BHD": return "🇧🇭"
        case "SAR": return "🇸🇦"
        case "KWD": return "🇰🇼"
        case "OMR": return "🇴🇲"
        case "QAR": return "🇶🇦"
        case "JOD": return "🇯🇴"
        case "ILS": return "🇮🇱"
        case "EGP": return "🇪🇬"

        // 유럽
        case "NOK": return "🇳🇴"
        case "SEK": return "🇸🇪"
        case "DKK": return "🇩🇰"
        case "ISK": return "🇮🇸"
        case "CZK": return "🇨🇿"
        case "PLN": return "🇵🇱"
        case "HUF": return "🇭🇺"
        case "RON": return "🇷🇴"
        case "RUB": return "🇷🇺"
        case "TRY": return "🇹🇷"

        // 아메리카
        case "MXN": return "🇲🇽"
        case "BRL": return "🇧🇷"
        case "ARS": return "🇦🇷"
        case "CLP": return "🇨🇱"
        case "COP": return "🇨🇴"

        // 아프리카
        case "ZAR": return "🇿🇦"
        case "NGN": return "🇳🇬"
        case "KES": return "🇰🇪"

        // 기타
        case "KZT": return "🇰🇿"

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
