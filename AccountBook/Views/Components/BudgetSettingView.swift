import SwiftUI

struct BudgetSettingView: View {
    @ObservedObject var viewModel: TransactionViewModel
    @Environment(\.presentationMode) var presentationMode
    @State private var budgetText: String = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("월 예산 설정")) {
                    TextField("예산 금액", text: $budgetText)
                        .keyboardType(.decimalPad)
                    
                    Text("현재 예산: ₩\(Int(viewModel.monthlyBudget))")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Section {
                    Button(action: {
                        saveBudget()
                    }) {
                        Text("저장")
                            .frame(maxWidth: .infinity)
                            .foregroundColor(.blue)
                    }
                }
            }
            .navigationTitle("예산 설정")
            .navigationBarItems(trailing: Button("닫기") {
                presentationMode.wrappedValue.dismiss()
            })
            .onAppear {
                budgetText = String(Int(viewModel.monthlyBudget))
            }
        }
    }
    
    private func saveBudget() {
        if let budget = Double(budgetText) {
            viewModel.setBudget(budget)
            presentationMode.wrappedValue.dismiss()
        }
    }
}
