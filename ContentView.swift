import SwiftUI

struct ContentView: View {
    @StateObject private var transactionViewModel = TransactionViewModel()

    var body: some View {
        TabView {
            HomeView(viewModel: transactionViewModel)
                .tabItem {
                    Label("홈", systemImage: "house.fill")
                }

            StatisticView(viewModel: transactionViewModel)
                .tabItem {
                    Label("통계", systemImage: "chart.bar.fill")
                }

            ExchangeRateFullView()
                .tabItem {
                    Label("실시간 환율", systemImage: "dollarsign.circle.fill")
                }

            SettingsTabView(viewModel: transactionViewModel)
                .tabItem {
                    Label("설정", systemImage: "gearshape.fill")
                }
        }
    }
}

// MARK: - Exchange Rate Full View
struct ExchangeRateFullView: View {
    @StateObject private var service = ExchangeRateService.shared
    @State private var searchText = ""

    var filteredRates: [ExchangeRate] {
        if searchText.isEmpty {
            return service.exchangeRates
        } else {
            return service.exchangeRates.filter {
                $0.currencyCode.localizedCaseInsensitiveContains(searchText) ||
                $0.currencyName.localizedCaseInsensitiveContains(searchText) ||
                $0.displayName.localizedCaseInsensitiveContains(searchText)
            }
        }
    }

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Header
                    VStack(alignment: .leading, spacing: 4) {
                        Text("실시간 환율 💱")
                            .font(.system(size: 32, weight: .bold))
                        Text("한국 수출입은행 기준")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal)
                    .padding(.top, 10)

                    // Search bar
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.secondary)
                        TextField("통화 검색 (예: USD, 달러)", text: $searchText)
                            .autocapitalization(.allCharacters)
                        if !searchText.isEmpty {
                            Button(action: { searchText = "" }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .padding(12)
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                    .padding(.horizontal)

                    // Last updated
                    if let lastUpdated = service.lastUpdated {
                        HStack {
                            Image(systemName: "clock")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text("마지막 업데이트: \(formatUpdateTime(lastUpdated))")
                                .font(.caption)
                                .foregroundColor(.secondary)

                            Spacer()

                            Button(action: {
                                Task {
                                    await service.fetchExchangeRates()
                                }
                            }) {
                                HStack(spacing: 4) {
                                    Image(systemName: "arrow.clockwise")
                                    Text("새로고침")
                                }
                                .font(.caption)
                                .foregroundColor(.blue)
                            }
                        }
                        .padding(.horizontal)
                    }

                    // Exchange rates list
                    if service.isLoading {
                        HStack {
                            Spacer()
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle())
                            Spacer()
                        }
                        .padding(.vertical, 40)
                    } else if let error = service.errorMessage {
                        VStack(spacing: 12) {
                            Image(systemName: "exclamationmark.triangle")
                                .font(.system(size: 50))
                                .foregroundColor(.orange)
                            Text(error)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                            Button("다시 시도") {
                                Task {
                                    await service.fetchExchangeRates()
                                }
                            }
                            .foregroundColor(.blue)
                        }
                        .padding(.vertical, 40)
                    } else if service.exchangeRates.isEmpty {
                        VStack(spacing: 12) {
                            Image(systemName: "chart.line.uptrend.xyaxis")
                                .font(.system(size: 50))
                                .foregroundColor(.gray)
                            Text("환율 정보를 불러올 수 없습니다")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        .padding(.vertical, 40)
                    } else if filteredRates.isEmpty {
                        VStack(spacing: 12) {
                            Image(systemName: "magnifyingglass")
                                .font(.system(size: 50))
                                .foregroundColor(.gray)
                            Text("검색 결과가 없습니다")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            Text("다른 검색어를 시도해보세요")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding(.vertical, 40)
                    } else {
                        VStack(spacing: 12) {
                            ForEach(filteredRates) { rate in
                                ExchangeRateDetailCard(rate: rate)
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.vertical)
                .padding(.bottom, 100)
            }
            .background(Color(.systemGroupedBackground))
            .navigationBarHidden(true)
            .onAppear {
                Task {
                    await service.fetchExchangeRates()
                }
            }
        }
    }

    private func formatUpdateTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "MM월 dd일 HH:mm"
        return formatter.string(from: date)
    }
}

// MARK: - Exchange Rate Detail Card
struct ExchangeRateDetailCard: View {
    let rate: ExchangeRate

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack(spacing: 12) {
                Text(rate.flag)
                    .font(.system(size: 40))

                VStack(alignment: .leading, spacing: 4) {
                    Text(rate.displayName)
                        .font(.title2)
                        .fontWeight(.bold)

                    Text(rate.currencyName)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }

                Spacer()
            }

            Divider()

            // Rates
            VStack(spacing: 12) {
                RateRow(title: "기준율", value: rate.baseRate, isMain: true)

                if let buyRate = rate.buyRate, buyRate > 0 {
                    RateRow(title: "살 때 (송금 보낼 때)", value: buyRate)
                }

                if let sellRate = rate.sellRate, sellRate > 0 {
                    RateRow(title: "팔 때 (송금 받을 때)", value: sellRate)
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
        )
    }
}

// MARK: - Rate Row
struct RateRow: View {
    let title: String
    let value: Double
    var isMain: Bool = false

    var body: some View {
        HStack {
            Text(title)
                .font(isMain ? .headline : .subheadline)
                .foregroundColor(isMain ? .primary : .secondary)

            Spacer()

            Text("₩ \(formatRate(value))")
                .font(isMain ? .title3 : .subheadline)
                .fontWeight(isMain ? .bold : .semibold)
                .foregroundColor(isMain ? .blue : .primary)
        }
    }

    private func formatRate(_ rate: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = ","
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        return formatter.string(from: NSNumber(value: rate)) ?? "0.00"
    }
}

// MARK: - Settings Tab View
struct SettingsTabView: View {
    @ObservedObject var viewModel: TransactionViewModel
    @State private var showingBudget = false

    var body: some View {
        NavigationView {
            List {
                Section(header: Text("예산 설정")) {
                    Button(action: { showingBudget = true }) {
                        HStack {
                            Image(systemName: "dollarsign.circle.fill")
                                .foregroundColor(.green)
                            Text("월간 예산 관리")
                        }
                    }
                }

                Section(header: Text("앱 정보")) {
                    HStack {
                        Text("버전")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("설정")
            .sheet(isPresented: $showingBudget) {
                BudgetSettingView(viewModel: viewModel)
            }
        }
    }
}
