import Foundation

class StorageService {
    static let shared = StorageService()
    
    private let transactionsKey = "transactions"
    private let budgetKey = "monthlyBudget"
    
    // 거래 내역 저장
    func saveTransactions(_ transactions: [Transaction]) {
        if let encoded = try? JSONEncoder().encode(transactions) {
            UserDefaults.standard.set(encoded, forKey: transactionsKey)
        }
    }
    
    // 거래 내역 불러오기
    func loadTransactions() -> [Transaction] {
        if let data = UserDefaults.standard.data(forKey: transactionsKey),
           let decoded = try? JSONDecoder().decode([Transaction].self, from: data) {
            return decoded
        }
        return []
    }
    
    // 월 예산 저장
    func saveBudget(_ budget: Double) {
        UserDefaults.standard.set(budget, forKey: budgetKey)
    }
    
    // 월 예산 불러오기
    func loadBudget() -> Double {
        return UserDefaults.standard.double(forKey: budgetKey)
    }
}
