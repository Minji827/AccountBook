import SwiftUI

struct TransactionRow: View {
    let transaction: Transaction
    
    var body: some View {
        HStack {
            Text(transaction.category.emoji)
                .font(.title2)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(transaction.note)
                    .font(.headline)
                Text(transaction.category.displayName)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text("\(transaction.isIncome ? "+" : "-")₩\(Int(transaction.amount))")
                    .font(.headline)
                    .foregroundColor(transaction.isIncome ? .green : .red)
                Text(transaction.date, style: .date)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}
