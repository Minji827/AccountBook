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
            ZStack {
                NeoColors.background.edgesIgnoringSafeArea(.all)
                
                ScrollView {
                    VStack(spacing: 24) {
                        // 거래 유형 선택
                        HStack(spacing: 12) {
                            Button(action: { isIncome = false }) {
                                Text("지출")
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 12)
                                    .background(isIncome ? Color.white : NeoColors.error)
                                    .foregroundColor(isIncome ? .black : .white)
                                    .cornerRadius(12)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(Color.black, lineWidth: 2)
                                    )
                                    .shadow(color: .black, radius: 0, x: isIncome ? 2 : 4, y: isIncome ? 2 : 4)
                            }
                            
                            Button(action: { isIncome = true }) {
                                Text("수입")
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 12)
                                    .background(isIncome ? NeoColors.success : Color.white)
                                    .foregroundColor(isIncome ? .white : .black)
                                    .cornerRadius(12)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(Color.black, lineWidth: 2)
                                    )
                                    .shadow(color: .black, radius: 0, x: isIncome ? 4 : 2, y: isIncome ? 4 : 2)
                            }
                        }
                        .padding(.horizontal)
                        
                        // 금액 및 통화
                        VStack(alignment: .leading, spacing: 8) {
                            Text("금액")
                                .font(.headline)
                                .fontWeight(.bold)
                            
                            HStack {
                                TextField("0", text: $amount)
                                    .keyboardType(.decimalPad)
                                    .font(.title2.bold())
                                    .padding()
                                    .background(Color.white)
                                    .cornerRadius(12)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(Color.black, lineWidth: 2)
                                    )
                                
                                Picker("통화", selection: $selectedCurrency) {
                                    ForEach(Currency.allCases) { currency in
                                        Text("\(currency.flag) \(currency.rawValue)").tag(currency)
                                    }
                                }
                                .pickerStyle(MenuPickerStyle())
                                .padding(.horizontal, 12)
                                .padding(.vertical, 14)
                                .background(Color.white)
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.black, lineWidth: 2)
                                )
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
                                        .foregroundColor(.gray)
                                    Spacer()
                                    Text(String(format: "%.2f KRW", exchangeRate))
                                        .font(.caption)
                                        .fontWeight(.bold)
                                }
                            }
                        }
                        .neoCard()
                        .padding(.horizontal)
                        
                        // 영수증 스캔
                        VStack(alignment: .leading, spacing: 8) {
                            Text("스마트 입력")
                                .font(.headline)
                                .fontWeight(.bold)
                            
                            PhotosPicker(selection: $selectedItem, matching: .images) {
                                HStack {
                                    Image(systemName: "camera.viewfinder")
                                    Text("영수증 스캔하여 자동 입력")
                                }
                                .frame(maxWidth: .infinity)
                                .neoButton(color: NeoColors.warning)
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
                                        .foregroundColor(.gray)
                                }
                                .padding(.top, 4)
                            }
                        }
                        .neoCard()
                        .padding(.horizontal)
                        
                        // 카테고리 및 메모
                        VStack(alignment: .leading, spacing: 16) {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("카테고리")
                                    .font(.headline)
                                    .fontWeight(.bold)
                                
                                Button(action: {
                                    showingCategoryPicker = true
                                }) {
                                    HStack {
                                        Text(isIncome ? selectedIncomeCategory.emoji : selectedExpenseCategory.emoji)
                                            .font(.title2)
                                        Text(isIncome ? selectedIncomeCategory.rawValue : selectedExpenseCategory.rawValue)
                                            .foregroundColor(.primary)
                                            .fontWeight(.bold)
                                        Spacer()
                                        Image(systemName: "chevron.right")
                                            .foregroundColor(.black)
                                    }
                                    .padding()
                                    .background(Color.white)
                                    .cornerRadius(12)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(Color.black, lineWidth: 2)
                                    )
                                }
                            }
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text("메모")
                                    .font(.headline)
                                    .fontWeight(.bold)
                                
                                TextField("내용을 입력하세요", text: $note)
                                    .padding()
                                    .background(Color.white)
                                    .cornerRadius(12)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(Color.black, lineWidth: 2)
                                    )
                                
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
                                        .font(.caption)
                                        .foregroundColor(.black)
                                        .padding(8)
                                        .background(NeoColors.warning.opacity(0.3))
                                        .cornerRadius(8)
                                    }
                                }
                            }
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text("날짜")
                                    .font(.headline)
                                    .fontWeight(.bold)
                                
                                DatePicker("날짜", selection: $date, displayedComponents: .date)
                                    .labelsHidden()
                                    .padding()
                                    .background(Color.white)
                                    .cornerRadius(12)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(Color.black, lineWidth: 2)
                                    )
                            }
                        }
                        .neoCard()
                        .padding(.horizontal)
                        
                        // 저장 버튼
                        Button(action: {
                            saveTransaction()
                        }) {
                            Text("저장하기")
                                .frame(maxWidth: .infinity)
                        }
                        .neoButton(color: NeoColors.primary)
                        .foregroundColor(.white)
                        .padding(.horizontal)
                        .padding(.bottom, 20)
                        .disabled(amount.isEmpty)
                        .opacity(amount.isEmpty ? 0.5 : 1.0)
                    }
                    .padding(.top)
                }
            }
            .navigationTitle("거래 추가")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button("취소") {
                    presentationMode.wrappedValue.dismiss()
                }
                .foregroundColor(.black)
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
