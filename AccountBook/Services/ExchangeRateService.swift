import Foundation

struct ExchangeRateResponse: Codable {
    let result: Int
    let cur_unit: String
    let ttb: String // 전신환받으실때 (송금 받을때)
    let tts: String // 전신환보내실때 (송금 보낼때)
    let deal_bas_r: String // 매매 기준율
    let bkpr: String // 장부가격
    let yy_efee_r: String // 년환가료율
    let ten_dd_efee_r: String // 10일환가료율
    let kftc_bkpr: String // 서울외국환중개 매매기준율
    let kftc_deal_bas_r: String // 서울외국환중개 장부가격
    let cur_nm: String // 국가명
}

class ExchangeRateService {
    static let shared = ExchangeRateService()
    
    private let authKey = "8On5pK8OO8PuhBIAG1fGbz7hoj6zmFNO"
    private let baseURL = "https://www.koreaexim.go.kr/site/program/financial/exchangeJSON"
    
    // Cache to store rates for the day
    private var cachedRates: [Currency: Double] = [:]
    private var lastFetchDate: Date?
    
    // Mock rates for fallback (weekend/holiday)
    private let mockRates: [Currency: Double] = [
        .usd: 1350.0,
        .eur: 1450.0,
        .jpy: 9.0, // 100 JPY = 900 KRW -> 1 JPY = 9 KRW
        .cny: 190.0,
        .krw: 1.0
    ]
    
    func getRate(for currency: Currency) async -> Double {
        if currency == .krw { return 1.0 }
        
        // Check cache first
        if let lastDate = lastFetchDate, Calendar.current.isDateInToday(lastDate), let rate = cachedRates[currency] {
            return rate
        }
        
        // Fetch from API
        if let rate = await fetchRateFromAPI(for: currency) {
            cachedRates[currency] = rate
            lastFetchDate = Date()
            return rate
        }
        
        // Fallback to mock if API fails or returns no data (e.g., weekend)
        print("⚠️ Using fallback mock rate for \(currency.rawValue)")
        return mockRates[currency] ?? 1.0
    }
    
    private func fetchRateFromAPI(for currency: Currency) async -> Double? {
        let dateString = currentDateString()
        
        // Construct URL
        var components = URLComponents(string: baseURL)!
        components.queryItems = [
            URLQueryItem(name: "authkey", value: authKey),
            URLQueryItem(name: "searchdate", value: dateString),
            URLQueryItem(name: "data", value: "AP01")
        ]
        
        guard let url = components.url else { return nil }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let responses = try JSONDecoder().decode([ExchangeRateResponse].self, from: data)
            
            // Find the rate for the requested currency
            // KEXIM returns JPY as "JPY(100)", others as "USD", "EUR"
            let targetUnit = currency == .jpy ? "JPY(100)" : currency.rawValue
            
            if let match = responses.first(where: { $0.cur_unit == targetUnit }) {
                // deal_bas_r comes as "1,350.50" (String with comma)
                let rateString = match.deal_bas_r.replacingOccurrences(of: ",", with: "")
                if let rate = Double(rateString) {
                    // Adjust for JPY(100)
                    return currency == .jpy ? rate / 100.0 : rate
                }
            }
            
            return nil
        } catch {
            print("Exchange Rate API Error: \(error)")
            return nil
        }
    }
    
    private func currentDateString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd"
        return formatter.string(from: Date())
    }
    
    func convert(amount: Double, from source: Currency, to target: Currency) async -> Double {
        let sourceRate = await getRate(for: source)
        let targetRate = await getRate(for: target)
        
        // Convert source to KRW, then KRW to target
        let amountInKRW = amount * sourceRate
        return amountInKRW / targetRate
    }
}
