import Foundation

class StorageService {
    static let shared = StorageService()

    private let transactionsKey = "transactions"
    private let budgetKey = "monthlyBudget"
    private let categoryBudgetsKey = "categoryBudgets"

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

    // 카테고리별 예산 저장
    func saveCategoryBudgets(_ budgets: [CategoryBudget]) {
        if let encoded = try? JSONEncoder().encode(budgets) {
            UserDefaults.standard.set(encoded, forKey: categoryBudgetsKey)
        }
    }

    // 카테고리별 예산 불러오기
    func loadCategoryBudgets() -> [CategoryBudget] {
        if let data = UserDefaults.standard.data(forKey: categoryBudgetsKey),
           let decoded = try? JSONDecoder().decode([CategoryBudget].self, from: data) {
            return decoded
        }
        return []
    }
}
