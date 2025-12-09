import SwiftUI

struct CategoryPicker: View {
    @Binding var selectedExpenseCategory: ExpenseCategory
    @Binding var selectedIncomeCategory: IncomeCategory
    let isIncome: Bool
    @Environment(\.presentationMode) var presentationMode
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 20) {
                    if isIncome {
                        ForEach(IncomeCategory.allCases, id: \.self) { category in
                            IncomeCategoryButton(
                                category: category,
                                isSelected: selectedIncomeCategory == category,
                                action: {
                                    selectedIncomeCategory = category
                                    presentationMode.wrappedValue.dismiss()
                                }
                            )
                        }
                    } else {
                        ForEach(ExpenseCategory.allCases, id: \.self) { category in
                            ExpenseCategoryButton(
                                category: category,
                                isSelected: selectedExpenseCategory == category,
                                action: {
                                    selectedExpenseCategory = category
                                    presentationMode.wrappedValue.dismiss()
                                }
                            )
                        }
                    }
                }
                .padding()
            }
            .navigationTitle(isIncome ? "수입 카테고리" : "지출 카테고리")
            .navigationBarItems(trailing: Button("닫기") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
}

// 지출 카테고리 버튼
struct ExpenseCategoryButton: View {
    let category: ExpenseCategory
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(isSelected ? Color.red.opacity(0.2) : Color(.systemGray5))
                        .frame(width: 70, height: 70)
                    
                    Text(category.emoji)
                        .font(.system(size: 35))
                }
                
                Text(category.rawValue)
                    .font(.caption)
                    .fontWeight(isSelected ? .bold : .regular)
                    .foregroundColor(isSelected ? .red : .primary)
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// 수입 카테고리 버튼
struct IncomeCategoryButton: View {
    let category: IncomeCategory
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(isSelected ? Color.green.opacity(0.2) : Color(.systemGray5))
                        .frame(width: 70, height: 70)
                    
                    Text(category.emoji)
                        .font(.system(size: 35))
                }
                
                Text(category.rawValue)
                    .font(.caption)
                    .fontWeight(isSelected ? .bold : .regular)
                    .foregroundColor(isSelected ? .green : .primary)
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// 프리뷰
struct CategoryPicker_Previews: PreviewProvider {
    static var previews: some View {
        CategoryPicker(
            selectedExpenseCategory: .constant(.food),
            selectedIncomeCategory: .constant(.salary),
            isIncome: false
        )
    }
}
