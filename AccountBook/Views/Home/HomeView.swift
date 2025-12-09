import SwiftUI

struct HomeView: View {
    @ObservedObject var viewModel: TransactionViewModel
    @State private var showingAddTransaction = false
    @State private var showingStatistics = false
    @State private var showingBudgetSetting = false
    
    var body: some View {
        NavigationView {
            ZStack {
                NeoColors.background.edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 20) {
                    // 요약 카드
                    SummaryCard(viewModel: viewModel)
                        .padding(.horizontal)
                        .padding(.top)
                    
                    // AI 조언
                    if viewModel.monthlyBudget > 0 {
                        AIAdviceCard(advice: viewModel.getAIAdvice())
                            .padding(.horizontal)
                    }
                    
                    // 검색 바
                    SearchBar(text: $viewModel.searchText)
                        .padding(.horizontal)
                    
                    // 거래 내역 리스트
                    List {
                        ForEach(viewModel.filteredTransactions.sorted(by: { $0.date > $1.date })) { transaction in
                            TransactionRow(transaction: transaction)
                                .listRowBackground(Color.clear)
                                .listRowSeparator(.hidden)
                                .padding(.vertical, 4)
                        }
                        .onDelete(perform: viewModel.deleteTransaction)
                    }
                    .listStyle(PlainListStyle())
                    .background(Color.clear)
                }
            }
            .navigationTitle("가계부")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        showingStatistics = true
                    }) {
                        Image(systemName: "chart.bar.fill")
                            .foregroundColor(.black)
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack {
                        Button(action: {
                            showingBudgetSetting = true
                        }) {
                            Image(systemName: "slider.horizontal.3")
                                .foregroundColor(.black)
                        }
                        
                        Button(action: {
                            showingAddTransaction = true
                        }) {
                            Image(systemName: "plus")
                                .font(.title3.bold())
                                .foregroundColor(.white)
                                .padding(8)
                                .background(NeoColors.primary)
                                .cornerRadius(8)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color.black, lineWidth: 2)
                                )
                                .shadow(color: .black, radius: 0, x: 2, y: 2)
                        }
                    }
                }
            }
            .sheet(isPresented: $showingAddTransaction) {
                AddTransactionView(viewModel: viewModel)
            }
            .sheet(isPresented: $showingStatistics) {
                StatisticsView(viewModel: viewModel)
            }
            .sheet(isPresented: $showingBudgetSetting) {
                BudgetSettingView(viewModel: viewModel)
            }
        }
    }
}

// 요약 카드 컴포넌트
struct SummaryCard: View {
    @ObservedObject var viewModel: TransactionViewModel
    
    var body: some View {
        VStack(spacing: 16) {
            HStack(spacing: 0) {
                SummaryItem(title: "수입", amount: viewModel.totalIncome(), color: NeoColors.success)
                Divider()
                    .frame(width: 2, height: 40)
                    .background(Color.black)
                SummaryItem(title: "지출", amount: viewModel.totalExpense(), color: NeoColors.error)
                Divider()
                    .frame(width: 2, height: 40)
                    .background(Color.black)
                SummaryItem(title: "잔액", amount: viewModel.totalIncome() - viewModel.totalExpense(), color: NeoColors.primary)
            }
            .frame(height: 80)
            
            if viewModel.monthlyBudget > 0 {
                BudgetProgressBar(viewModel: viewModel)
            }
        }
        .neoCard()
    }
}

// 요약 아이템
struct SummaryItem: View {
    let title: String
    let amount: Double
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(.black)
            Text("₩\(Int(amount))")
                .font(.system(size: 18, weight: .black))
                .foregroundColor(color)
                .lineLimit(1)
                .minimumScaleFactor(0.5)
        }
        .frame(maxWidth: .infinity)
    }
}

// 예산 진행 바
struct BudgetProgressBar: View {
    @ObservedObject var viewModel: TransactionViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("월 예산")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.black)
                Spacer()
                Text("₩\(Int(viewModel.totalExpense())) / ₩\(Int(viewModel.monthlyBudget))")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.black)
            }
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color.white)
                        .frame(height: 12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 6)
                                .stroke(Color.black, lineWidth: 2)
                        )
                    
                    Rectangle()
                        .fill(progressColor)
                        .frame(width: min(CGFloat(viewModel.budgetPercentage() / 100) * geometry.size.width, geometry.size.width), height: 12)
                        .cornerRadius(6)
                        .overlay(
                            RoundedRectangle(cornerRadius: 6)
                                .stroke(Color.black, lineWidth: 2)
                        )
                }
            }
            .frame(height: 12)
        }
    }
    
    var progressColor: Color {
        let percentage = viewModel.budgetPercentage()
        if percentage > 100 { return NeoColors.error }
        if percentage > 80 { return NeoColors.warning }
        return NeoColors.success
    }
}

// AI 조언 카드
struct AIAdviceCard: View {
    let advice: String
    
    var body: some View {
        HStack {
            Image(systemName: "sparkles")
                .foregroundColor(.black)
                .font(.title2)
            Text(advice)
                .font(.subheadline)
                .fontWeight(.bold)
                .foregroundColor(.black)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .neoCard(color: NeoColors.warning)
    }
}

// 검색 바
struct SearchBar: View {
    @Binding var text: String
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.black)
            TextField("검색", text: $text)
            if !text.isEmpty {
                Button(action: {
                    text = ""
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.black)
                }
            }
        }
        .padding(12)
        .background(Color.white)
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.black, lineWidth: 2)
        )
        .shadow(color: .black, radius: 0, x: 2, y: 2)
    }
}



