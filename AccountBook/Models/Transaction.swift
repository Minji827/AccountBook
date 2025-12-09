import Foundation

struct Transaction: Identifiable, Codable {
    var id = UUID()
    var amount: Double // Always in KRW (converted)
    var originalAmount: Double // Amount in original currency
    var currency: Currency
    var exchangeRate: Double // Rate at the time of transaction (1 Unit = X KRW)
    var category: TransactionCategory
    var note: String
    var date: Date
    
    var isIncome: Bool {
        if case .income = category {
            return true
        }
        return false
    }
    
    init(amount: Double, currency: Currency = .krw, exchangeRate: Double = 1.0, category: TransactionCategory, note: String, date: Date = Date()) {
        self.originalAmount = amount
        self.currency = currency
        self.exchangeRate = exchangeRate
        
        // Calculate KRW amount
        if currency == .krw {
            self.amount = amount
        } else {
            // JPY is usually treated as 100 JPY = X KRW in some contexts, but standard API is 1 Unit.
            // Assuming exchangeRate is "KRW per 1 Unit of Currency"
            self.amount = amount * exchangeRate
        }
        
        self.category = category
        self.note = note
        self.date = date
    }
}
