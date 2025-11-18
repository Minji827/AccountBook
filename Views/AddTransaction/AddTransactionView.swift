import SwiftUI

struct AddTransactionView: View {
    @ObservedObject var viewModel: TransactionViewModel
    @Environment(\.presentationMode) var presentationMode
    
    @State private var amount: String = ""
    @State private var selectedExpenseCategory: ExpenseCategory = .food
    @State private var selectedIncomeCategory: IncomeCategory = .salary
    @State private var note: String = ""
    @State private var date: Date = Date()
    @State private var isIncome: Bool = false
    @State private var isLoadingSuggestion: Bool = false
    @State private var showingCategoryPicker: Bool = false
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("거래 유형")) {
                    Picker("유형", selection: $isIncome) {
                        Text("지출").tag(false)
                        Text("수입").tag(true)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                
                Section(header: Text("금액")) {
                    TextField("금액을 입력하세요", text: $amount)
                        .keyboardType(.decimalPad)
                }
                
                Section(header: Text("메모")) {
                    TextField("메모 입력", text: $note)
                    
                    if !note.isEmpty {
                        Button(action: {
                            suggestCategoryFromNote()
                        }) {
                            HStack {
                                Image(systemName: "sparkles")
                                Text("AI 카테고리 추천")
                                if isLoadingSuggestion {
                                    ProgressView()
                                        .padding(.leading, 4)
                                }
                            }
                        }
                    }
                }
                
                Section(header: Text("카테고리")) {
                    Button(action: {
                        showingCategoryPicker = true
                    }) {
                        HStack {
                            Text(isIncome ? selectedIncomeCategory.emoji : selectedExpenseCategory.emoji)
                                .font(.title2)
                            Text(isIncome ? selectedIncomeCategory.rawValue : selectedExpenseCategory.rawValue)
                                .foregroundColor(.primary)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.gray)
                        }
                    }
                }
                
                Section(header: Text("날짜")) {
                    DatePicker("날짜", selection: $date, displayedComponents: .date)
                }
            }
            .navigationTitle("거래 추가")
            .navigationBarItems(
                leading: Button("취소") {
                    presentationMode.wrappedValue.dismiss()
                },
                trailing: Button("저장") {
                    saveTransaction()
                }
                .disabled(amount.isEmpty)
            )
            .sheet(isPresented: $showingCategoryPicker) {
                CategoryPicker(
                    selectedExpenseCategory: $selectedExpenseCategory,
                    selectedIncomeCategory: $selectedIncomeCategory,
                    isIncome: isIncome
                )
            }
        }
    }
    
    private func suggestCategoryFromNote() {
        isLoadingSuggestion = true
        Task {
            if isIncome {
                let suggested = await AIService.suggestIncomeCategory(from: note)
                await MainActor.run {
                    selectedIncomeCategory = suggested
                    isLoadingSuggestion = false
                }
            } else {
                let suggested = await AIService.suggestExpenseCategory(from: note)
                await MainActor.run {
                    selectedExpenseCategory = suggested
                    isLoadingSuggestion = false
                }
            }
        }
    }
    
    private func saveTransaction() {
        guard let amountValue = Double(amount) else { return }
        
        let category: TransactionCategory = isIncome
            ? .income(selectedIncomeCategory)
            : .expense(selectedExpenseCategory)
        
        let transaction = Transaction(
            amount: amountValue,
            category: category,
            note: note.isEmpty ? category.displayName : note,
            date: date
        )
        
        viewModel.addTransaction(transaction)
        presentationMode.wrappedValue.dismiss()
    }
}

// 프리뷰
struct AddTransactionView_Previews: PreviewProvider {
    static var previews: some View {
        AddTransactionView(viewModel: TransactionViewModel())
    }
}
