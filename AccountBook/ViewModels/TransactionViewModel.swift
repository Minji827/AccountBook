import Foundation
import Combine

class TransactionViewModel: ObservableObject {
    @Published var transactions: [Transaction] = []
    @Published var monthlyBudget: Double = 0
    @Published var searchText: String = ""
    
    private let storageService = StorageService.shared
    
    init() {
        loadTransactions()
        loadBudget()
    }
    
    var filteredTransactions: [Transaction] {
        if searchText.isEmpty {
            return transactions
        }
        return transactions.filter { transaction in
            transaction.note.localizedCaseInsensitiveContains(searchText) ||
            transaction.category.displayName.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    func addTransaction(_ transaction: Transaction) {
        transactions.append(transaction)
        saveTransactions()
    }
    
    func deleteTransaction(at offsets: IndexSet) {
        transactions.remove(atOffsets: offsets)
        saveTransactions()
    }
    
    func totalExpense() -> Double {
        transactions.filter { !$0.isIncome }.reduce(0) { $0 + $1.amount }
    }
    
    func totalIncome() -> Double {
        transactions.filter { $0.isIncome }.reduce(0) { $0 + $1.amount }
    }
    
    // 지출 카테고리별 금액 계산 (수정됨)
    func expenseByCategory(_ category: ExpenseCategory) -> Double {
        transactions.filter {
            if case .expense(let cat) = $0.category, cat == category {
                return true
            }
            return false
        }.reduce(0) { $0 + $1.amount }
    }
    
    // 수입 카테고리별 금액 계산 (추가)
    func incomeByCategory(_ category: IncomeCategory) -> Double {
        transactions.filter {
            if case .income(let cat) = $0.category, cat == category {
                return true
            }
            return false
        }.reduce(0) { $0 + $1.amount }
    }
    
    func budgetPercentage() -> Double {
        guard monthlyBudget > 0 else { return 0 }
        return (totalExpense() / monthlyBudget) * 100
    }
    
    func setBudget(_ budget: Double) {
        monthlyBudget = budget
        storageService.saveBudget(budget)
    }
    
    func getAIAdvice() -> String {
        return AIService.generateAdvice(totalExpense: totalExpense(), budget: monthlyBudget)
    }
    
    private func saveTransactions() {
        storageService.saveTransactions(transactions)
    }
    
    private func loadTransactions() {
        transactions = storageService.loadTransactions()
    }
    
    private func loadBudget() {
        monthlyBudget = storageService.loadBudget()
    }
}
