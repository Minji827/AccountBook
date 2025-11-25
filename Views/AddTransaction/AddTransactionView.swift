import SwiftUI
import PhotosUI

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
    
    // Currency & OCR
    @State private var selectedCurrency: Currency = .krw
    @State private var exchangeRate: Double = 1.0
    @State private var selectedItem: PhotosPickerItem?
    @State private var selectedImage: UIImage?
    @State private var isAnalyzingReceipt: Bool = false
    
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
                
                Section(header: Text("금액 및 통화")) {
                    HStack {
                        TextField("금액", text: $amount)
                            .keyboardType(.decimalPad)
                        
                        Picker("통화", selection: $selectedCurrency) {
                            ForEach(Currency.allCases) { currency in
                                Text("\(currency.flag) \(currency.rawValue)").tag(currency)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                        .onChange(of: selectedCurrency) { newCurrency in
                            Task {
                                await updateExchangeRate(for: newCurrency)
                            }
                        }
                    }
                    
                    if selectedCurrency != .krw {
                        HStack {
                            Text("환율 (1 \(selectedCurrency.rawValue) =)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Spacer()
                            Text(String(format: "%.2f KRW", exchangeRate))
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                Section(header: Text("영수증 스캔 (AI)")) {
                    PhotosPicker(selection: $selectedItem, matching: .images) {
                        HStack {
                            Image(systemName: "camera.viewfinder")
                            Text("영수증 불러오기")
                        }
                    }
                    .onChange(of: selectedItem) { newItem in
                        Task {
                            if let data = try? await newItem?.loadTransferable(type: Data.self),
                               let image = UIImage(data: data) {
                                selectedImage = image
                                await analyzeReceipt(image)
                            }
                        }
                    }
                    
                    if isAnalyzingReceipt {
                        HStack {
                            ProgressView()
                            Text("AI가 영수증을 분석 중입니다...")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
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
    
    private func updateExchangeRate(for currency: Currency) async {
        if currency == .krw {
            exchangeRate = 1.0
        } else {
            exchangeRate = await ExchangeRateService.shared.getRate(for: currency)
        }
    }
    
    private func analyzeReceipt(_ image: UIImage) async {
        isAnalyzingReceipt = true
        do {
            let draft = try await AIService.analyzeReceipt(image: image)
            
            await MainActor.run {
                self.amount = String(Int(draft.amount)) // Simple int conversion for now
                self.selectedCurrency = draft.currency
                self.date = draft.date
                self.note = draft.note
                
                if case .expense(let cat) = draft.category {
                    self.isIncome = false
                    self.selectedExpenseCategory = cat
                } else if case .income(let cat) = draft.category {
                    self.isIncome = true
                    self.selectedIncomeCategory = cat
                }
                
                self.isAnalyzingReceipt = false
            }
            
            // Update rate if needed
            if draft.currency != .krw {
                await updateExchangeRate(for: draft.currency)
            }
            
        } catch {
            print("Receipt analysis failed: \(error)")
            isAnalyzingReceipt = false
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
            currency: selectedCurrency,
            exchangeRate: exchangeRate,
            category: category,
            note: note.isEmpty ? category.displayName : note,
            date: date
        )
        
        viewModel.addTransaction(transaction)
        presentationMode.wrappedValue.dismiss()
    }
}
