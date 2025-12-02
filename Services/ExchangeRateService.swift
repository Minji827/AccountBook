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

class ExchangeRateService: ObservableObject {
    static let shared = ExchangeRateService()

    @Published var exchangeRates: [ExchangeRate] = []
    @Published var lastUpdated: Date?
    @Published var isLoading = false
    @Published var errorMessage: String?

    // 한국 수출입은행 API Key
    private let apiKey = "8On5pK8OO8PuhBIAG1fGbz7hoj6zmFNO"
    private let baseURL = "https://www.koreaexim.go.kr/site/program/financial/exchangeJSON"

    // 우선순위 통화 (먼저 표시할 통화)
    private let priorityCurrencies = ["USD", "JPY(100)", "EUR", "GBP"]

    private init() {}

    // MARK: - Fetch Exchange Rates
    func fetchExchangeRates() async {
        await MainActor.run {
            isLoading = true
            errorMessage = nil
        }

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd"
        let today = dateFormatter.string(from: Date())

        guard var urlComponents = URLComponents(string: baseURL) else {
            await MainActor.run {
                isLoading = false
                errorMessage = "잘못된 URL"
            }
            return
        }

        urlComponents.queryItems = [
            URLQueryItem(name: "authkey", value: apiKey),
            URLQueryItem(name: "searchdate", value: today),
            URLQueryItem(name: "data", value: "AP01")
        ]

        guard let url = urlComponents.url else {
            await MainActor.run {
                isLoading = false
                errorMessage = "URL 생성 실패"
            }
            return
        }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let responses = try JSONDecoder().decode([ExchangeRateResponse].self, from: data)

            let now = Date()
            // 모든 환율 정보를 가져오되, 우선순위에 따라 정렬
            let rates = responses
                .map { ExchangeRate(from: $0, lastUpdated: now) }
                .sorted { rate1, rate2 in
                    let priority1 = priorityCurrencies.firstIndex(of: rate1.currencyCode) ?? Int.max
                    let priority2 = priorityCurrencies.firstIndex(of: rate2.currencyCode) ?? Int.max

                    if priority1 != priority2 {
                        return priority1 < priority2
                    }
                    return rate1.currencyCode < rate2.currencyCode
                }

            await MainActor.run {
                self.exchangeRates = rates
                self.lastUpdated = now
                self.isLoading = false
            }
        } catch {
            await MainActor.run {
                self.isLoading = false
                self.errorMessage = "환율 정보를 가져올 수 없습니다: \(error.localizedDescription)"
            }
        }
    }

    // MARK: - Legacy Support
    func getRate(for currency: Currency) async -> Double {
        if exchangeRates.isEmpty {
            await fetchExchangeRates()
        }

        let code = currency.rawValue.uppercased()
        let exchangeRate = exchangeRates.first { $0.currencyCode == code || $0.displayName == code }
        return exchangeRate?.baseRate ?? 1.0
    }

    func convert(amount: Double, from source: Currency, to target: Currency) async -> Double {
        let sourceRate = await getRate(for: source)
        let targetRate = await getRate(for: target)

        return amount * sourceRate / targetRate
    }
}
