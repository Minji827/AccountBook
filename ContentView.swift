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
    @State private var showingProfile = false
    @State private var showingCurrency = false
    @State private var showingNotification = false
    @State private var showingBackup = false
    @State private var showingAppInfo = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Header
                VStack(alignment: .leading, spacing: 4) {
                    Text("설정 ⚙️")
                        .font(.system(size: 32, weight: .bold))
                    Text("앱 설정 및 관리")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal)
                .padding(.top, 10)

                // Settings cards
                SettingsCard(
                    icon: "👤",
                    iconColor: Color(red: 0.7, green: 0.85, blue: 1.0),
                    title: "프로필 설정",
                    action: { showingProfile = true }
                )
                .padding(.horizontal)

                SettingsCard(
                    icon: "💱",
                    iconColor: Color(red: 1.0, green: 0.9, blue: 0.9),
                    title: "통화 설정",
                    action: { showingCurrency = true }
                )
                .padding(.horizontal)

                SettingsCard(
                    icon: "🔔",
                    iconColor: Color(red: 0.9, green: 1.0, blue: 0.9),
                    title: "알림 설정",
                    action: { showingNotification = true }
                )
                .padding(.horizontal)

                SettingsCard(
                    icon: "🎯",
                    iconColor: Color(red: 1.0, green: 0.9, blue: 1.0),
                    title: "목표 관리",
                    subtitle: "이번 달 예산 정하기",
                    action: { showingBudget = true }
                )
                .padding(.horizontal)

                SettingsCard(
                    icon: "☁️",
                    iconColor: Color(red: 1.0, green: 0.95, blue: 0.85),
                    title: "백업 & 동기화",
                    action: { showingBackup = true }
                )
                .padding(.horizontal)

                SettingsCard(
                    icon: "ℹ️",
                    iconColor: Color(red: 0.95, green: 0.95, blue: 0.95),
                    title: "앱 정보",
                    subtitle: "v1.0.0",
                    action: { showingAppInfo = true }
                )
                .padding(.horizontal)
            }
            .padding(.vertical)
            .padding(.bottom, 100)
        }
        .background(Color(.systemGroupedBackground))
        .sheet(isPresented: $showingBudget) {
            BudgetSettingView(viewModel: viewModel)
        }
        .sheet(isPresented: $showingProfile) {
            ProfileSettingsView()
        }
        .sheet(isPresented: $showingCurrency) {
            CurrencySettingsView()
        }
        .sheet(isPresented: $showingNotification) {
            NotificationSettingsView()
        }
        .alert("백업 & 동기화", isPresented: $showingBackup) {
            Button("iCloud 백업", action: {})
            Button("데이터 내보내기", action: {})
            Button("취소", role: .cancel, action: {})
        } message: {
            Text("데이터를 백업하거나 내보낼 수 있습니다.")
        }
        .alert("앱 정보", isPresented: $showingAppInfo) {
            Button("확인", role: .cancel, action: {})
        } message: {
            Text("AccountBook v1.0.0\n\n환율 기반 가계부 앱\n\n© 2024 AccountBook")
        }
    }
}

// MARK: - Settings Card
struct SettingsCard: View {
    let icon: String
    let iconColor: Color
    let title: String
    var subtitle: String? = nil
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                // 이모지 아이콘을 배경색 위에 표시
                Text(icon)
                    .font(.system(size: 28))
                    .frame(width: 56, height: 56)
                    .background(iconColor)
                    .clipShape(RoundedRectangle(cornerRadius: 14))

                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.primary)

                    if let subtitle = subtitle {
                        Text(subtitle)
                            .font(.system(size: 13))
                            .foregroundColor(.secondary)
                    }
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.gray)
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.systemBackground))
                    .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 4)
            )
        }
    }
}

// MARK: - Profile Settings View
struct ProfileSettingsView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var name = "사용자"
    @State private var email = "user@example.com"
    @State private var phoneNumber = ""

    var body: some View {
        NavigationView {
            List {
                Section(header: Text("개인 정보")) {
                    TextField("이름", text: $name)
                    TextField("이메일", text: $email)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                    TextField("전화번호", text: $phoneNumber)
                        .keyboardType(.phonePad)
                }

                Section(header: Text("프로필 이미지")) {
                    Button("사진 선택") {
                        // Photo picker
                    }
                }

                Section {
                    Button("저장") {
                        presentationMode.wrappedValue.dismiss()
                    }
                    .frame(maxWidth: .infinity)
                    .foregroundColor(.blue)
                }
            }
            .navigationTitle("프로필 설정")
            .navigationBarItems(trailing: Button("닫기") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
}

// MARK: - Currency Settings View
struct CurrencySettingsView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var mainCurrency: Currency = .krw
    @State private var selectedCurrencies: Set<Currency> = [.usd, .eur, .jpy]

    var body: some View {
        NavigationView {
            List {
                Section(header: Text("기본 통화")) {
                    Picker("기본 통화", selection: $mainCurrency) {
                        ForEach(Currency.allCases) { currency in
                            Text("\(currency.flag) \(currency.rawValue)")
                                .tag(currency)
                        }
                    }
                }

                Section(header: Text("표시할 통화")) {
                    ForEach(Currency.allCases) { currency in
                        Toggle("\(currency.flag) \(currency.rawValue)", isOn: Binding(
                            get: { selectedCurrencies.contains(currency) },
                            set: { isOn in
                                if isOn {
                                    selectedCurrencies.insert(currency)
                                } else {
                                    selectedCurrencies.remove(currency)
                                }
                            }
                        ))
                    }
                }

                Section {
                    Button("저장") {
                        presentationMode.wrappedValue.dismiss()
                    }
                    .frame(maxWidth: .infinity)
                    .foregroundColor(.blue)
                }
            }
            .navigationTitle("통화 설정")
            .navigationBarItems(trailing: Button("닫기") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
}

// MARK: - Notification Settings View
struct NotificationSettingsView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var budgetAlerts = true
    @State private var transactionReminders = true
    @State private var exchangeRateAlerts = true
    @State private var goalReminders = true
    @State private var weeklyReport = true

    var body: some View {
        NavigationView {
            List {
                Section(header: Text("알림 설정")) {
                    Toggle("예산 초과 알림", isOn: $budgetAlerts)
                    Toggle("거래 알림", isOn: $transactionReminders)
                    Toggle("환율 변동 알림", isOn: $exchangeRateAlerts)
                    Toggle("목표 달성 알림", isOn: $goalReminders)
                }

                Section(header: Text("리포트")) {
                    Toggle("주간 리포트", isOn: $weeklyReport)
                }

                Section(header: Text("환율 알림 설정")) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("환율이 설정한 값에 도달하면 알림을 받을 수 있습니다")
                            .font(.caption)
                            .foregroundColor(.secondary)

                        Button("알림 설정 추가") {
                            // Add exchange rate alert
                        }
                        .foregroundColor(.blue)
                    }
                }
            }
            .navigationTitle("알림 설정")
            .navigationBarItems(trailing: Button("닫기") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
}
