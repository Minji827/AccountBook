import Foundation

struct CategoryBudget: Codable {
    var category: ExpenseCategory
    var budget: Double
    
    init(category: ExpenseCategory, budget: Double) {
        self.category = category
        self.budget = budget
    }
}
