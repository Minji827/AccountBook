import SwiftUI

struct SettingsView: View {
    @ObservedObject var viewModel: TransactionViewModel
    @State private var showingGoals = false
    @State private var showingBudget = false
    @State private var showingProfile = false
    @State private var showingCurrency = false
    @State private var showingNotification = false
    @State private var showingBackup = false
    @State private var showingAppInfo = false

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
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
                        icon: "person.circle.fill",
                        iconColor: .blue,
                        title: "프로필 설정",
                        action: { showingProfile = true }
                    )

                    SettingsCard(
                        icon: "dollarsign.circle.fill",
                        iconColor: .pink,
                        title: "통화 설정",
                        action: { showingCurrency = true }
                    )

                    SettingsCard(
                        icon: "bell.fill",
                        iconColor: .green,
                        title: "알림 설정",
                        action: { showingNotification = true }
                    )

                    SettingsCard(
                        icon: "target",
                        iconColor: .purple,
                        title: "목표 관리",
                        action: { showingGoals = true }
                    )

                    SettingsCard(
                        icon: "dollarsign.square.fill",
                        iconColor: .indigo,
                        title: "예산 설정",
                        action: { showingBudget = true }
                    )

                    SettingsCard(
                        icon: "icloud.fill",
                        iconColor: .orange,
                        title: "백업 & 동기화",
                        action: { showingBackup = true }
                    )

                    SettingsCard(
                        icon: "info.circle.fill",
                        iconColor: .gray,
                        title: "앱 정보",
                        subtitle: "v1.0.0",
                        action: { showingAppInfo = true }
                    )
                }
                .padding(.vertical)
                .padding(.bottom, 100)
            }
            .background(Color(.systemGroupedBackground))
            .navigationBarHidden(true)
            .sheet(isPresented: $showingGoals) {
                GoalView()
            }
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
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(iconColor)
                    .frame(width: 50, height: 50)
                    .background(iconColor.opacity(0.15))
                    .clipShape(Circle())

                Text(title)
                    .font(.headline)
                    .foregroundColor(.primary)

                Spacer()

                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                } else {
                    Image(systemName: "chevron.right")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.systemBackground))
                    .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
            )
            .padding(.horizontal)
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
            Form {
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
            Form {
                Section(header: Text("기본 통화")) {
                    Picker("기본 통화", selection: $mainCurrency) {
                        ForEach(Currency.allCases) { currency in
                            HStack {
                                Text(currency.flag)
                                Text(currency.name)
                            }
                            .tag(currency)
                        }
                    }
                }

                Section(header: Text("표시할 통화")) {
                    ForEach(Currency.allCases) { currency in
                        Toggle(isOn: Binding(
                            get: { selectedCurrencies.contains(currency) },
                            set: { isOn in
                                if isOn {
                                    selectedCurrencies.insert(currency)
                                } else {
                                    selectedCurrencies.remove(currency)
                                }
                            }
                        )) {
                            HStack {
                                Text(currency.flag)
                                Text(currency.name)
                            }
                        }
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
            Form {
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

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView(viewModel: TransactionViewModel())
    }
}
