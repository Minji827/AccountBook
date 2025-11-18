import Foundation

struct Transaction: Identifiable, Codable {
    var id = UUID()
    var amount: Double
    var category: TransactionCategory
    var note: String
    var date: Date
    
    var isIncome: Bool {
        if case .income = category {
            return true
        }
        return false
    }
    
    init(amount: Double, category: TransactionCategory, note: String, date: Date = Date()) {
        self.amount = amount
        self.category = category
        self.note = note
        self.date = date
    }
}
