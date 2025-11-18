import SwiftUI
import Charts

struct StatisticsView: View {
    @ObservedObject var viewModel: TransactionViewModel
    @Environment(\.presentationMode) var presentationMode
    @State private var selectedTab: StatisticsTab = .expense
    
    enum StatisticsTab {
        case expense, income
    }
    
    var statisticsViewModel: StatisticsViewModel {
        StatisticsViewModel(transactions: viewModel.transactions)
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // 탭 선택
                    Picker("", selection: $selectedTab) {
                        Text("지출").tag(StatisticsTab.expense)
                        Text("수입").tag(StatisticsTab.income)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding()
                    
                    if selectedTab == .expense {
                        // 지출 통계
                        ExpenseCategoryChart(data: statisticsViewModel.expenseCategoryData())
                            .padding()
                        
                        WeeklyExpenseChart(data: statisticsViewModel.recentWeekExpenses())
                            .padding()
                        
                        ExpenseCategoryDetailList(data: statisticsViewModel.expenseCategoryData())
                            .padding()
                    } else {
                        // 수입 통계
                        IncomeCategoryChart(data: statisticsViewModel.incomeCategoryData())
                            .padding()
                        
                        WeeklyIncomeChart(data: statisticsViewModel.recentWeekIncome())
                            .padding()
                        
                        IncomeCategoryDetailList(data: statisticsViewModel.incomeCategoryData())
                            .padding()
                    }
                }
            }
            .navigationTitle("통계")
            .navigationBarItems(trailing: Button("닫기") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
}

// 지출 카테고리별 차트
struct ExpenseCategoryChart: View {
    let data: [(category: ExpenseCategory, amount: Double)]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("카테고리별 지출")
                .font(.headline)
            
            if #available(iOS 16.0, *) {
                Chart {
                    ForEach(data, id: \.category) { item in
                        BarMark(
                            x: .value("금액", item.amount),
                            y: .value("카테고리", "\(item.category.emoji) \(item.category.rawValue)")
                        )
                        .foregroundStyle(Color.red.gradient)
                    }
                }
                .frame(height: max(CGFloat(data.count) * 40, 200))
            } else {
                VStack(spacing: 8) {
                    ForEach(data, id: \.category) { item in
                        SimpleExpenseBar(category: item.category, amount: item.amount, maxAmount: data.first?.amount ?? 1)
                    }
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.1), radius: 10)
        )
    }
}

// 수입 카테고리별 차트
struct IncomeCategoryChart: View {
    let data: [(category: IncomeCategory, amount: Double)]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("카테고리별 수입")
                .font(.headline)
            
            if #available(iOS 16.0, *) {
                Chart {
                    ForEach(data, id: \.category) { item in
                        BarMark(
                            x: .value("금액", item.amount),
                            y: .value("카테고리", "\(item.category.emoji) \(item.category.rawValue)")
                        )
                        .foregroundStyle(Color.green.gradient)
                    }
                }
                .frame(height: max(CGFloat(data.count) * 40, 200))
            } else {
                VStack(spacing: 8) {
                    ForEach(data, id: \.category) { item in
                        SimpleIncomeBar(category: item.category, amount: item.amount, maxAmount: data.first?.amount ?? 1)
                    }
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.1), radius: 10)
        )
    }
}

// 간단한 지출 막대 그래프
struct SimpleExpenseBar: View {
    let category: ExpenseCategory
    let amount: Double
    let maxAmount: Double
    
    var body: some View {
        HStack {
            Text("\(category.emoji) \(category.rawValue)")
                .font(.caption)
                .frame(width: 80, alignment: .leading)
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 20)
                    
                    Rectangle()
                        .fill(Color.red)
                        .frame(width: CGFloat(amount / maxAmount) * geometry.size.width, height: 20)
                }
            }
            .frame(height: 20)
            
            Text("₩\(Int(amount))")
                .font(.caption)
                .frame(width: 70, alignment: .trailing)
        }
    }
}

// 간단한 수입 막대 그래프
struct SimpleIncomeBar: View {
    let category: IncomeCategory
    let amount: Double
    let maxAmount: Double
    
    var body: some View {
        HStack {
            Text("\(category.emoji) \(category.rawValue)")
                .font(.caption)
                .frame(width: 80, alignment: .leading)
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 20)
                    
                    Rectangle()
                        .fill(Color.green)
                        .frame(width: CGFloat(amount / maxAmount) * geometry.size.width, height: 20)
                }
            }
            .frame(height: 20)
            
            Text("₩\(Int(amount))")
                .font(.caption)
                .frame(width: 70, alignment: .trailing)
        }
    }
}

// 주간 지출 차트
struct WeeklyExpenseChart: View {
    let data: [(date: Date, amount: Double)]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("최근 7일 지출")
                .font(.headline)
            
            if #available(iOS 16.0, *) {
                Chart {
                    ForEach(data, id: \.date) { item in
                        LineMark(
                            x: .value("날짜", item.date, unit: .day),
                            y: .value("금액", item.amount)
                        )
                        .foregroundStyle(Color.red.gradient)
                        .interpolationMethod(.catmullRom)
                        
                        PointMark(
                            x: .value("날짜", item.date, unit: .day),
                            y: .value("금액", item.amount)
                        )
                        .foregroundStyle(Color.red)
                    }
                }
                .frame(height: 200)
            } else {
                Text("iOS 16 이상에서 차트를 볼 수 있습니다")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .frame(height: 100)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.1), radius: 10)
        )
    }
}

// 주간 수입 차트
struct WeeklyIncomeChart: View {
    let data: [(date: Date, amount: Double)]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("최근 7일 수입")
                .font(.headline)
            
            if #available(iOS 16.0, *) {
                Chart {
                    ForEach(data, id: \.date) { item in
                        LineMark(
                            x: .value("날짜", item.date, unit: .day),
                            y: .value("금액", item.amount)
                        )
                        .foregroundStyle(Color.green.gradient)
                        .interpolationMethod(.catmullRom)
                        
                        PointMark(
                            x: .value("날짜", item.date, unit: .day),
                            y: .value("금액", item.amount)
                        )
                        .foregroundStyle(Color.green)
                    }
                }
                .frame(height: 200)
            } else {
                Text("iOS 16 이상에서 차트를 볼 수 있습니다")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .frame(height: 100)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.1), radius: 10)
        )
    }
}

// 지출 카테고리별 상세 리스트
struct ExpenseCategoryDetailList: View {
    let data: [(category: ExpenseCategory, amount: Double)]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("카테고리별 상세")
                .font(.headline)
            
            ForEach(data, id: \.category) { item in
                HStack {
                    Text(item.category.emoji)
                        .font(.title2)
                    Text(item.category.rawValue)
                        .font(.body)
                    Spacer()
                    Text("₩\(Int(item.amount))")
                        .font(.headline)
                        .foregroundColor(.red)
                }
                .padding(.vertical, 4)
                
                if item.category != data.last?.category {
                    Divider()
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.1), radius: 10)
        )
    }
}

// 수입 카테고리별 상세 리스트
struct IncomeCategoryDetailList: View {
    let data: [(category: IncomeCategory, amount: Double)]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("카테고리별 상세")
                .font(.headline)
            
            ForEach(data, id: \.category) { item in
                HStack {
                    Text(item.category.emoji)
                        .font(.title2)
                    Text(item.category.rawValue)
                        .font(.body)
                    Spacer()
                    Text("₩\(Int(item.amount))")
                        .font(.headline)
                        .foregroundColor(.green)
                }
                .padding(.vertical, 4)
                
                if item.category != data.last?.category {
                    Divider()
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.1), radius: 10)
        )
    }
}

// 프리뷰
struct StatisticsView_Previews: PreviewProvider {
    static var previews: some View {
        StatisticsView(viewModel: TransactionViewModel())
    }
}
