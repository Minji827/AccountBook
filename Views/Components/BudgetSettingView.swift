import SwiftUI

struct BudgetSettingView: View {
    @ObservedObject var viewModel: TransactionViewModel
    @Environment(\.presentationMode) var presentationMode
    @State private var budgetInputs: [ExpenseCategory: String] = [:]

    var body: some View {
        NavigationView {
            List {
                Section(header: Text("카테고리별 예산 설정")) {
                    ForEach(ExpenseCategory.allCases, id: \.self) { category in
                        HStack {
                            Text("\(category.emoji) \(category.rawValue)")
                                .frame(width: 100, alignment: .leading)

                            Spacer()

                            TextField("예산", text: budgetBinding(for: category))
                                .keyboardType(.numberPad)
                                .multilineTextAlignment(.trailing)
                                .frame(width: 120)

                            Text("원")
                                .foregroundColor(.secondary)
                        }
                    }
                }

                Section {
                    Button(action: {
                        saveBudgets()
                    }) {
                        Text("저장")
                            .frame(maxWidth: .infinity)
                            .foregroundColor(.blue)
                    }
                }
            }
            .navigationTitle("목표 관리")
            .navigationBarItems(trailing: Button("닫기") {
                presentationMode.wrappedValue.dismiss()
            })
            .onAppear {
                loadCurrentBudgets()
            }
        }
    }

    private func budgetBinding(for category: ExpenseCategory) -> Binding<String> {
        return Binding(
            get: { budgetInputs[category] ?? "" },
            set: { budgetInputs[category] = $0 }
        )
    }

    private func loadCurrentBudgets() {
        for category in ExpenseCategory.allCases {
            let budget = viewModel.getCategoryBudget(for: category)
            if budget > 0 {
                budgetInputs[category] = String(Int(budget))
            }
        }
    }

    private func saveBudgets() {
        for (category, budgetText) in budgetInputs {
            if let budget = Double(budgetText), budget > 0 {
                viewModel.setCategoryBudget(category: category, budget: budget)
            }
        }
        presentationMode.wrappedValue.dismiss()
    }
}
