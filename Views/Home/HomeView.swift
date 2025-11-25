import SwiftUI

struct HomeView: View {
    @ObservedObject var viewModel: TransactionViewModel
    @State private var showingAddTransaction = false
    @State private var showingStatistics = false
    @State private var showingBudgetSetting = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // 요약 카드
                SummaryCard(viewModel: viewModel)
                    .padding()
                
                // AI 조언
                if viewModel.monthlyBudget > 0 {
                    AIAdviceCard(advice: viewModel.getAIAdvice())
                        .padding(.horizontal)
                        .padding(.bottom)
                }
                
                // 검색 바
                SearchBar(text: $viewModel.searchText)
                    .padding(.horizontal)
                
                // 거래 내역 리스트
                List {
                    ForEach(viewModel.filteredTransactions.sorted(by: { $0.date > $1.date })) { transaction in
                        TransactionRow(transaction: transaction)
                    }
                    .onDelete(perform: viewModel.deleteTransaction)
                }
                .listStyle(PlainListStyle())
            }
            .navigationTitle("가계부")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        showingStatistics = true
                    }) {
                        Image(systemName: "chart.bar.fill")
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack {
                        Button(action: {
                            showingBudgetSetting = true
                        }) {
                            Image(systemName: "slider.horizontal.3")
                        }
                        
                        Button(action: {
                            showingAddTransaction = true
                        }) {
                            Image(systemName: "plus.circle.fill")
                                .font(.title2)
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
        VStack(spacing: 12) {
            HStack(spacing: 20) {
                SummaryItem(title: "수입", amount: viewModel.totalIncome(), color: .green)
                Divider()
                SummaryItem(title: "지출", amount: viewModel.totalExpense(), color: .red)
                Divider()
                SummaryItem(title: "잔액", amount: viewModel.totalIncome() - viewModel.totalExpense(), color: .blue)
            }
            .frame(height: 80)
            
            if viewModel.monthlyBudget > 0 {
                BudgetProgressBar(viewModel: viewModel)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 2)
        )
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
                .foregroundColor(.secondary)
            Text("₩\(Int(amount))")
                .font(.system(size: 18, weight: .bold))
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
                    .foregroundColor(.secondary)
                Spacer()
                Text("₩\(Int(viewModel.totalExpense())) / ₩\(Int(viewModel.monthlyBudget))")
                    .font(.caption)
                    .fontWeight(.medium)
            }
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 8)
                        .cornerRadius(4)
                    
                    Rectangle()
                        .fill(progressColor)
                        .frame(width: min(CGFloat(viewModel.budgetPercentage() / 100) * geometry.size.width, geometry.size.width), height: 8)
                        .cornerRadius(4)
                }
            }
            .frame(height: 8)
        }
    }
    
    var progressColor: Color {
        let percentage = viewModel.budgetPercentage()
        if percentage > 100 { return .red }
        if percentage > 80 { return .orange }
        return .green
    }
}

// AI 조언 카드
struct AIAdviceCard: View {
    let advice: String
    
    var body: some View {
        HStack {
            Image(systemName: "sparkles")
                .foregroundColor(.yellow)
            Text(advice)
                .font(.subheadline)
                .foregroundColor(.primary)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.yellow.opacity(0.1))
        )
    }
}

// 검색 바
struct SearchBar: View {
    @Binding var text: String
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
            TextField("검색", text: $text)
            if !text.isEmpty {
                Button(action: {
                    text = ""
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                }
            }
        }
        .padding(10)
        .background(Color(.systemGray6))
        .cornerRadius(10)
    }
}
