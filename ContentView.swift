import SwiftUI

struct ContentView: View {
    @StateObject private var transactionViewModel = TransactionViewModel()
    
    var body: some View {
        TabView {
            HomeView(viewModel: transactionViewModel)
                .tabItem {
                    Label("홈", systemImage: "house.fill")
                }
            
            AIChatView()
                .tabItem {
                    Label("AI 코칭", systemImage: "message.fill")
                }
            
            StatisticsView(viewModel: transactionViewModel)
                .tabItem {
                    Label("통계", systemImage: "chart.bar.fill")
                }
            
            GoalView()
                .tabItem {
                    Label("목표", systemImage: "target")
                }
        }
    }
}
