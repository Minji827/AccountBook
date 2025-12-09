import SwiftUI
import Charts

struct StatisticView: View {
    @ObservedObject var viewModel: TransactionViewModel
    @Environment(\.presentationMode) var presentationMode
    @State private var selectedPeriod: Period = .monthly

    enum Period: String, CaseIterable {
        case weekly = "주간"
        case monthly = "월간"
        case yearly = "연간"
    }

    var statisticsViewModel: StatisticsViewModel {
        StatisticsViewModel(transactions: viewModel.transactions)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // 헤더
                VStack(alignment: .leading, spacing: 8) {
                    Text("통계 📊")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    Text("지출 분석 및 트렌드")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                .padding(.horizontal)

                // 카테고리별 지출 카드
                ExpenseCategoryCard(
                    data: statisticsViewModel.expenseCategoryData(),
                    selectedPeriod: $selectedPeriod
                )
                .padding(.horizontal)
            }
            .padding(.top)
            .padding(.bottom, 100)
        }
        .background(Color(.systemGroupedBackground))
    }
}

// 카테고리별 지출 카드
struct ExpenseCategoryCard: View {
    let data: [(category: ExpenseCategory, amount: Double)]
    @Binding var selectedPeriod: StatisticView.Period

    var totalAmount: Double {
        data.reduce(0) { $0 + $1.amount }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // 제목과 기간 선택
            HStack {
                Text("카테고리별 지출")
                    .font(.title2)
                    .fontWeight(.bold)
                Spacer()
            }

            // 기간 선택 버튼
            HStack(spacing: 12) {
                ForEach(StatisticView.Period.allCases, id: \.self) { period in
                    PeriodButton(
                        title: period.rawValue,
                        isSelected: selectedPeriod == period
                    ) {
                        selectedPeriod = period
                    }
                }
            }

            if data.isEmpty {
                Text("데이터가 없습니다")
                    .foregroundColor(.gray)
                    .frame(maxWidth: .infinity, minHeight: 200, alignment: .center)
            } else {
                // 도넛 차트
                DonutChart(data: data, totalAmount: totalAmount)
                    .frame(height: 250)
                    .padding(.vertical)

                // 카테고리 범례
                VStack(spacing: 16) {
                    ForEach(data, id: \.category) { item in
                        CategoryLegendRow(
                            category: item.category,
                            amount: item.amount,
                            percentage: totalAmount > 0 ? (item.amount / totalAmount) * 100 : 0
                        )
                    }
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.05), radius: 15, x: 0, y: 5)
        )
    }
}

// 기간 선택 버튼
struct PeriodButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .fontWeight(isSelected ? .semibold : .regular)
                .foregroundColor(isSelected ? .white : .gray)
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(isSelected ? Color.blue : Color(.systemGray6))
                )
        }
    }
}

// 도넛 차트
struct DonutChart: View {
    let data: [(category: ExpenseCategory, amount: Double)]
    let totalAmount: Double

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(Array(data.enumerated()), id: \.element.category) { index, item in
                    let startAngle = calculateStartAngle(for: index)
                    let endAngle = calculateEndAngle(for: index)

                    DonutSlice(
                        startAngle: startAngle,
                        endAngle: endAngle,
                        color: item.category.color
                    )
                }
            }
            .frame(width: min(geometry.size.width, geometry.size.height),
                   height: min(geometry.size.width, geometry.size.height))
            .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
        }
    }

    private func calculateStartAngle(for index: Int) -> Angle {
        var angle: Double = 0
        for i in 0..<index {
            angle += (data[i].amount / totalAmount) * 360
        }
        return Angle(degrees: angle - 90)
    }

    private func calculateEndAngle(for index: Int) -> Angle {
        var angle: Double = 0
        for i in 0...index {
            angle += (data[i].amount / totalAmount) * 360
        }
        return Angle(degrees: angle - 90)
    }
}

// 도넛 슬라이스
struct DonutSlice: View {
    let startAngle: Angle
    let endAngle: Angle
    let color: Color

    var body: some View {
        GeometryReader { geometry in
            Path { path in
                let center = CGPoint(x: geometry.size.width / 2, y: geometry.size.height / 2)
                let radius = min(geometry.size.width, geometry.size.height) / 2
                let innerRadius = radius * 0.6

                path.addArc(
                    center: center,
                    radius: radius,
                    startAngle: startAngle,
                    endAngle: endAngle,
                    clockwise: false
                )

                path.addArc(
                    center: center,
                    radius: innerRadius,
                    startAngle: endAngle,
                    endAngle: startAngle,
                    clockwise: true
                )

                path.closeSubpath()
            }
            .fill(color)
        }
    }
}

// 카테고리 범례 행
struct CategoryLegendRow: View {
    let category: ExpenseCategory
    let amount: Double
    let percentage: Double

    var body: some View {
        HStack {
            // 색상 인디케이터
            Circle()
                .fill(category.color)
                .frame(width: 12, height: 12)

            // 카테고리 이름
            Text("\(category.emoji) \(category.rawValue)")
                .font(.body)

            Spacer()

            // 금액과 퍼센트
            VStack(alignment: .trailing, spacing: 2) {
                Text("₩\(formatNumber(Int(amount)))")
                    .font(.headline)
                Text("(\(Int(percentage))%)")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
    }

    private func formatNumber(_ number: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = ","
        return formatter.string(from: NSNumber(value: number)) ?? "\(number)"
    }
}

// 프리뷰
struct StatisticView_Previews: PreviewProvider {
    static var previews: some View {
        let viewModel = TransactionViewModel()

        // 샘플 데이터 추가
        viewModel.addTransaction(Transaction(
            amount: 420000,
            category: .expense(.food),
            note: "외식비",
            date: Date()
        ))
        viewModel.addTransaction(Transaction(
            amount: 280000,
            category: .expense(.shopping),
            note: "쇼핑",
            date: Date()
        ))
        viewModel.addTransaction(Transaction(
            amount: 210000,
            category: .expense(.transport),
            note: "교통비",
            date: Date()
        ))
        viewModel.addTransaction(Transaction(
            amount: 490000,
            category: .expense(.other),
            note: "기타",
            date: Date()
        ))

        return StatisticView(viewModel: viewModel)
    }
}
