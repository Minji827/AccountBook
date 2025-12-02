import SwiftUI

@main
struct AccountBookApp: App {
    @StateObject private var transactionViewModel = TransactionViewModel()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
