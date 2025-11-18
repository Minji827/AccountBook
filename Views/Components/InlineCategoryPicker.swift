import SwiftUI

struct InlineCategoryPicker: View {
    @Binding var selectedExpenseCategory: ExpenseCategory
    @Binding var selectedIncomeCategory: IncomeCategory
    let isIncome: Bool
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        if isIncome {
            // 수입 카테고리 표시
            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(IncomeCategory.allCases, id: \.self) { category in
                    incomeButton(for: category)
                }
            }
        } else {
            // 지출 카테고리 표시
            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(ExpenseCategory.allCases, id: \.self) { category in
                    expenseButton(for: category)
                }
            }
        }
    }
    
    // 지출 카테고리 버튼
    private func expenseButton(for category: ExpenseCategory) -> some View {
        Button(action: {
            selectedExpenseCategory = category
        }) {
            VStack(spacing: 4) {
                ZStack {
                    Circle()
                        .fill(selectedExpenseCategory == category ? Color.red.opacity(0.2) : Color(.systemGray6))
                        .frame(width: 50, height: 50)
                    
                    Text(category.emoji)
                        .font(.title3)
                }
                
                Text(category.rawValue)
                    .font(.caption2)
                    .foregroundColor(selectedExpenseCategory == category ? .red : .secondary)
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    // 수입 카테고리 버튼
    private func incomeButton(for category: IncomeCategory) -> some View {
        Button(action: {
            selectedIncomeCategory = category
        }) {
            VStack(spacing: 4) {
                ZStack {
                    Circle()
                        .fill(selectedIncomeCategory == category ? Color.green.opacity(0.2) : Color(.systemGray6))
                        .frame(width: 50, height: 50)
                    
                    Text(category.emoji)
                        .font(.title3)
                }
                
                Text(category.rawValue)
                    .font(.caption2)
                    .foregroundColor(selectedIncomeCategory == category ? .green : .secondary)
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// 프리뷰
struct InlineCategoryPicker_Previews: PreviewProvider {
    static var previews: some View {
        InlineCategoryPicker(
            selectedExpenseCategory: .constant(.food),
            selectedIncomeCategory: .constant(.salary),
            isIncome: false
        )
    }
}
