import Foundation

enum GoalType: String, CaseIterable, Codable {
    case savings = "저축"
    case debt = "부채 상환"
}

struct Goal: Identifiable, Codable {
    var id = UUID()
    var title: String
    var targetAmount: Double
    var currentAmount: Double
    var deadline: Date
    var type: GoalType
    var color: String // Hex string or asset name
    
    var progress: Double {
        guard targetAmount > 0 else { return 0 }
        return min(currentAmount / targetAmount, 1.0)
    }
    
    var isCompleted: Bool {
        return currentAmount >= targetAmount
    }
}
