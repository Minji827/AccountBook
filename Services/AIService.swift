import Foundation

class AIService {
    // AI API를 사용한 지출 카테고리 추천
    static func suggestExpenseCategory(from note: String) async -> ExpenseCategory {
        let lowercased = note.lowercased()
        
        if lowercased.contains("밥") || lowercased.contains("음식") || lowercased.contains("카페") || lowercased.contains("식당") || lowercased.contains("치킨") {
            return .food
        } else if lowercased.contains("버스") || lowercased.contains("택시") || lowercased.contains("지하철") || lowercased.contains("주유") || lowercased.contains("교통") {
            return .transport
        } else if lowercased.contains("옷") || lowercased.contains("쇼핑") || lowercased.contains("구매") {
            return .shopping
        } else if lowercased.contains("영화") || lowercased.contains("게임") || lowercased.contains("여행") || lowercased.contains("놀이") {
            return .entertainment
        } else if lowercased.contains("병원") || lowercased.contains("약국") || lowercased.contains("건강") || lowercased.contains("의료") {
            return .health
        } else if lowercased.contains("책") || lowercased.contains("학원") || lowercased.contains("강의") || lowercased.contains("교육") {
            return .education
        } else if lowercased.contains("전기") || lowercased.contains("수도") || lowercased.contains("가스") || lowercased.contains("관리비") {
            return .utilities
        } else if lowercased.contains("월세") || lowercased.contains("전세") || lowercased.contains("집") {
            return .housing
        }
        
        return .other
    }
    
    // AI API를 사용한 수입 카테고리 추천
    static func suggestIncomeCategory(from note: String) async -> IncomeCategory {
        let lowercased = note.lowercased()
        
        if lowercased.contains("월급") || lowercased.contains("급여") || lowercased.contains("연봉") {
            return .salary
        } else if lowercased.contains("보너스") || lowercased.contains("상여") {
            return .bonus
        } else if lowercased.contains("사업") || lowercased.contains("매출") {
            return .business
        } else if lowercased.contains("주식") || lowercased.contains("배당") || lowercased.contains("이자") || lowercased.contains("투자") {
            return .investment
        } else if lowercased.contains("용돈") || lowercased.contains("선물") {
            return .allowance
        } else if lowercased.contains("부업") || lowercased.contains("알바") || lowercased.contains("프리랜서") {
            return .sidejob
        } else if lowercased.contains("환급") || lowercased.contains("세금") {
            return .refund
        }
        
        return .other
    }
    
    // 월별 지출 분석 및 조언 생성
    static func generateAdvice(totalExpense: Double, budget: Double) -> String {
        let percentage = (totalExpense / budget) * 100
        
        if percentage > 100 {
            return "⚠️ 예산을 \(Int(percentage - 100))% 초과했어요. 지출을 줄여보세요!"
        } else if percentage > 80 {
            return "💡 예산의 \(Int(percentage))%를 사용 중이에요. 주의하세요!"
        } else if percentage > 50 {
            return "👍 양호한 소비 패턴이에요. 계속 유지하세요!"
        } else {
            return "✨ 훌륭한 절약이에요. 이대로 계속하세요!"
        }
    }
}
