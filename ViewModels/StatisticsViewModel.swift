import Foundation

class StatisticsViewModel: ObservableObject {
    @Published var transactions: [Transaction]
    
    init(transactions: [Transaction]) {
        self.transactions = transactions
    }
    
    // 지출 카테고리별 데이터
    func expenseCategoryData() -> [(category: ExpenseCategory, amount: Double)] {
        var result: [ExpenseCategory: Double] = [:]
        
        for transaction in transactions {
            if case .expense(let category) = transaction.category {
                result[category, default: 0] += transaction.amount
            }
        }
        
        return result.map { ($0.key, $0.value) }
            .sorted { $0.amount > $1.amount }
    }
    
    // 수입 카테고리별 데이터
    func incomeCategoryData() -> [(category: IncomeCategory, amount: Double)] {
        var result: [IncomeCategory: Double] = [:]
        
        for transaction in transactions {
            if case .income(let category) = transaction.category {
                result[category, default: 0] += transaction.amount
            }
        }
        
        return result.map { ($0.key, $0.value) }
            .sorted { $0.amount > $1.amount }
    }
    
    // 최근 7일 지출 데이터
    func recentWeekExpenses() -> [(date: Date, amount: Double)] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let weekAgo = calendar.date(byAdding: .day, value: -6, to: today)!
        
        let recentTransactions = transactions.filter { transaction in
            !transaction.isIncome && transaction.date >= weekAgo
        }
        
        var dailyExpenses: [Date: Double] = [:]
        
        for transaction in recentTransactions {
            let day = calendar.startOfDay(for: transaction.date)
            dailyExpenses[day, default: 0] += transaction.amount
        }
        
        return dailyExpenses.map { ($0.key, $0.value) }
            .sorted { $0.date < $1.date }
    }
    
    // 최근 7일 수입 데이터
    func recentWeekIncome() -> [(date: Date, amount: Double)] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let weekAgo = calendar.date(byAdding: .day, value: -6, to: today)!
        
        let recentTransactions = transactions.filter { transaction in
            transaction.isIncome && transaction.date >= weekAgo
        }
        
        var dailyIncome: [Date: Double] = [:]
        
        for transaction in recentTransactions {
            let day = calendar.startOfDay(for: transaction.date)
            dailyIncome[day, default: 0] += transaction.amount
        }
        
        return dailyIncome.map { ($0.key, $0.value) }
            .sorted { $0.date < $1.date }
    }
    
    // 총 지출
    func totalExpense() -> Double {
        transactions.filter { !$0.isIncome }.reduce(0) { $0 + $1.amount }
    }
    
    // 총 수입
    func totalIncome() -> Double {
        transactions.filter { $0.isIncome }.reduce(0) { $0 + $1.amount }
    }
}
