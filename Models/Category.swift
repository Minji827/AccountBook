import Foundation
import SwiftUI

// 지출 카테고리
enum ExpenseCategory: String, CaseIterable, Codable {
    case food = "음식"
    case transport = "교통"
    case shopping = "쇼핑"
    case entertainment = "여가"
    case health = "의료"
    case education = "교육"
    case utilities = "공과금"
    case housing = "주거"
    case other = "기타"
    
    var emoji: String {
        switch self {
        case .food: return "🍔"
        case .transport: return "🚗"
        case .shopping: return "🛍️"
        case .entertainment: return "🎬"
        case .health: return "💊"
        case .education: return "📚"
        case .utilities: return "💡"
        case .housing: return "🏠"
        case .other: return "💰"
        }
    }
    var color: Color {
        switch self {
        case .food: return .orange
        case .transport: return .blue
        case .shopping: return .pink
        case .entertainment: return .purple
        case .health: return .red
        case .education: return .cyan
        case .utilities: return .yellow
        case .housing: return .brown
        case .other: return .gray
        }
    }

    var systemImageName: String {
        switch self {
        case .food: return "fork.knife.circle.fill"
        case .transport: return "car.fill"
        case .shopping: return "cart.fill.badge.plus"
        case .entertainment: return "tv.fill"
        case .health: return "heart.fill"
        case .education: return "book.fill"
        case .utilities: return "lightbulb.fill"
        case .housing: return "house.fill"
        case .other: return "ellipsis.circle.fill"
        }
    }
}

// 수입 카테고리
enum IncomeCategory: String, CaseIterable, Codable {
    case salary = "급여"
    case bonus = "상여금"
    case business = "사업소득"
    case investment = "투자수익"
    case allowance = "용돈"
    case sidejob = "부수입"
    case refund = "환급"
    case other = "기타"
    
    var emoji: String {
        switch self {
        case .salary: return "💵"
        case .bonus: return "🎁"
        case .business: return "💼"
        case .investment: return "📈"
        case .allowance: return "💝"
        case .sidejob: return "💪"
        case .refund: return "↩️"
        case .other: return "💰"
        }
    }
    var color: Color {
        switch self {
        case .salary: return .green
        case .bonus: return .orange
        case .business: return .blue
        case .investment: return .purple
        case .allowance: return .pink
        case .sidejob: return .teal
        case .refund: return .yellow
        case .other: return .gray
        }
    }
}

// 통합 카테고리 (Transaction에서 사용)
enum TransactionCategory: Codable, Equatable {
    case expense(ExpenseCategory)
    case income(IncomeCategory)
    
    var displayName: String {
        switch self {
        case .expense(let category):
            return category.rawValue
        case .income(let category):
            return category.rawValue
        }
    }
    
    var emoji: String {
        switch self {
        case .expense(let category):
            return category.emoji
        case .income(let category):
            return category.emoji
        }
    }
}
