import SwiftUI

struct HomeView: View {
    @ObservedObject var viewModel: TransactionViewModel
    @State private var showingAddTransaction = false
    @State private var showingBudgetList = false
    @State private var showingTransactionList = false

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // 헤더
                    VStack(alignment: .leading, spacing: 4) {
                        Text("안녕하세요 👋")
                            .font(.system(size: 28, weight: .bold))
                        Text(formattedDate())
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal)
                    .padding(.top, 10)

                    // 총 자산 카드
                    TotalAssetsCard(viewModel: viewModel)
                        .padding(.horizontal)

                    // 이번 달 성과 카드
                    MonthlyPerformanceCard(viewModel: viewModel)
                        .padding(.horizontal)

                    // 이번 달 예산
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("이번 달 예산")
                                .font(.title3)
                                .fontWeight(.bold)

                            Spacer()

                            Button(action: {
                                showingBudgetList = true
                            }) {
                                Text("전체보기")
                                    .font(.subheadline)
                                    .foregroundColor(.blue)
                            }
                        }
                        .padding(.horizontal)

                        // 예산이 설정된 카테고리만 표시 (최대 3개)
                        ForEach(viewModel.categoryBudgets.prefix(3), id: \.category) { categoryBudget in
                            BudgetCategoryCard(
                                icon: categoryBudget.category.systemImageName,
                                iconColor: categoryBudget.category.color,
                                category: categoryBudget.category.rawValue,
                                spent: viewModel.expenseByCategory(categoryBudget.category),
                                budget: categoryBudget.budget
                            )
                            .padding(.horizontal)
                        }
                    }

                    // 최근 거래
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("최근 거래")
                                .font(.title3)
                                .fontWeight(.bold)

                            Spacer()

                            Button(action: {
                                showingTransactionList = true
                            }) {
                                Text("전체보기")
                                    .font(.subheadline)
                                    .foregroundColor(.blue)
                            }
                        }
                        .padding(.horizontal)

                        // 최근 거래 5개 표시
                        ForEach(viewModel.transactions.sorted(by: { $0.date > $1.date }).prefix(5)) { transaction in
                            TransactionRow(transaction: transaction)
                                .padding(.horizontal)
                        }
                    }
                }
                .padding(.vertical)
                .padding(.bottom, 100)
            }
            .background(Color(.systemGroupedBackground))
            .navigationBarHidden(true)

            // + 버튼
            Button(action: {
                showingAddTransaction = true
            }) {
                Image(systemName: "plus")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .frame(width: 60, height: 60)
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [Color.purple, Color.blue]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .clipShape(Circle())
                    .shadow(color: Color.purple.opacity(0.3), radius: 10, x: 0, y: 5)
            }
            .padding(.trailing, 20)
            .padding(.bottom, 20)
        }
        .sheet(isPresented: $showingAddTransaction) {
            AddTransactionView(viewModel: viewModel)
        }
        .sheet(isPresented: $showingTransactionList) {
            TransactionListView(viewModel: viewModel)
        }
        .sheet(isPresented: $showingBudgetList) {
            BudgetListView(viewModel: viewModel)
        }
    }

    func formattedDate() -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "yyyy년 MM월 dd일 EEEE"
        return formatter.string(from: Date())
    }
}

// MARK: - Total Assets Card
struct TotalAssetsCard: View {
    @ObservedObject var viewModel: TransactionViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("총 자산")
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.8))

            Text("₩\(formatNumber(viewModel.totalIncome() - viewModel.totalExpense()))")
                .font(.system(size: 36, weight: .bold))
                .foregroundColor(.white)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .background(
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.4, green: 0.49, blue: 0.92),
                    Color(red: 0.46, green: 0.29, blue: 0.63)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
    }

    func formatNumber(_ number: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = ","
        return formatter.string(from: NSNumber(value: Int(number))) ?? "0"
    }
}

// MARK: - Monthly Performance Card
struct MonthlyPerformanceCard: View {
    @ObservedObject var viewModel: TransactionViewModel

    var budgetAchievement: Int {
        // 예산 목표 달성률 계산
        return 78
    }

    var expenseReduction: Int {
        // 지출 감소율 계산
        return 15
    }

    var exchangeSavings: Int {
        // 환율 절약 금액 계산
        return 45200
    }

    var body: some View {
        HStack(spacing: 12) {
            Text("📊")
                .font(.title)

            VStack(alignment: .leading, spacing: 4) {
                Text("이번 달 성과")
                    .font(.subheadline)
                    .fontWeight(.semibold)

                Text("예산 목표 달성률 \(budgetAchievement)% · 지출 \(expenseReduction)% 감소 · 환율 절약 ₩\(formatNumber(exchangeSavings))")
                    .font(.subheadline)
                    .foregroundColor(.primary)
            }

            Spacer()
        }
        .padding(16)
        .background(
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.blue.opacity(0.2),
                    Color.blue.opacity(0.1)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(16)
    }

    func formatNumber(_ number: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = ","
        return formatter.string(from: NSNumber(value: number)) ?? "0"
    }
}

// MARK: - Budget Category Card
struct BudgetCategoryCard: View {
    let icon: String
    let iconColor: Color
    let category: String
    let spent: Double
    let budget: Double

    var progress: Double {
        return spent / budget
    }

    var progressPercentage: Int {
        return Int(progress * 100)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(iconColor)
                    .frame(width: 50, height: 50)
                    .background(iconColor.opacity(0.15))
                    .clipShape(Circle())

                VStack(alignment: .leading, spacing: 4) {
                    Text(category)
                        .font(.headline)

                    Text("\(formatNumber(spent))원")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                }

                Spacer()

                Text("\(formatNumber(budget))원")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }

            // Progress bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.gray.opacity(0.15))
                        .frame(height: 8)

                    RoundedRectangle(cornerRadius: 4)
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [iconColor, iconColor.opacity(0.7)]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: min(CGFloat(progress) * geometry.size.width, geometry.size.width), height: 8)
                }
            }
            .frame(height: 8)

            Text("\(formatNumber(spent))원 사용 (\(progressPercentage)%)")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
        )
    }

    func formatNumber(_ number: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = ","
        return formatter.string(from: NSNumber(value: Int(number))) ?? "0"
    }
}

// MARK: - Transaction List View
struct TransactionListView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var viewModel: TransactionViewModel

    var body: some View {
        NavigationView {
            List {
                ForEach(viewModel.transactions.sorted(by: { $0.date > $1.date })) { transaction in
                    TransactionRow(transaction: transaction)
                }
                .onDelete(perform: viewModel.deleteTransaction)
            }
            .navigationTitle("전체 거래 내역")
            .navigationBarItems(trailing: Button("닫기") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
}

// MARK: - Budget List View
struct BudgetListView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var viewModel: TransactionViewModel

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 16) {
                    BudgetCategoryCard(
                        icon: "fork.knife.circle.fill",
                        iconColor: .pink,
                        category: "외식",
                        spent: 195000,
                        budget: 300000
                    )
                    .padding(.horizontal)

                    BudgetCategoryCard(
                        icon: "cart.fill.badge.plus",
                        iconColor: .blue,
                        category: "쇼핑",
                        spent: 210000,
                        budget: 500000
                    )
                    .padding(.horizontal)

                    BudgetCategoryCard(
                        icon: "car.fill",
                        iconColor: .orange,
                        category: "교통",
                        spent: 80000,
                        budget: 150000
                    )
                    .padding(.horizontal)

                    BudgetCategoryCard(
                        icon: "house.fill",
                        iconColor: .green,
                        category: "주거",
                        spent: 500000,
                        budget: 600000
                    )
                    .padding(.horizontal)
                }
                .padding(.vertical)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("전체 예산")
            .navigationBarItems(trailing: Button("닫기") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
}
