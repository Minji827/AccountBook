import Foundation

class ExchangeRateService {
    static let shared = ExchangeRateService()
    
    // Mock rates (Base: KRW)
    // In a real app, base would likely be USD, but for a Korean app, we might want direct KRW rates.
    // However, most APIs provide USD base. Let's assume we get KRW per 1 Unit of Currency.
    private var rates: [Currency: Double] = [
        .krw: 1.0,
        .usd: 1350.0,
        .eur: 1450.0,
        .jpy: 9.0, // 1 JPY = 9 KRW (approx 900 KRW / 100 JPY)
        .cny: 190.0
    ]
    
    // API Key (To be filled by user)
    private let apiKey = "" // TODO: Add API Key mechanism
    
    func getRate(for currency: Currency) async -> Double {
        // Simulate network delay
        try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 sec
        
        // Return mock rate
        return rates[currency] ?? 1.0
    }
    
    func convert(amount: Double, from source: Currency, to target: Currency) async -> Double {
        let sourceRate = await getRate(for: source)
        let targetRate = await getRate(for: target)
        
        // Convert source to KRW, then KRW to target
        // Amount * SourceRate (KRW) / TargetRate (KRW)
        return amount * sourceRate / targetRate
    }
}
