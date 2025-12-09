import SwiftUI

struct TransactionRow: View {
    let transaction: Transaction

    var body: some View {
        HStack(spacing: 12) {
            // 카테고리 아이콘
            Text(transaction.category.emoji)
                .font(.title2)
                .frame(width: 50, height: 50)
                .background(categoryColor.opacity(0.15))
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 4) {
                Text(transaction.note)
                    .font(.headline)
                    .foregroundColor(.primary)

                Text(transaction.category.displayName)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                Text("\(transaction.isIncome ? "+" : "-")₩\(formatNumber(transaction.amount))")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(transaction.isIncome ? .green : .red)

                Text(transaction.date, style: .date)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
        )
    }

    var categoryColor: Color {
        transaction.isIncome ? .green : .red
    }

    func formatNumber(_ number: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = ","
        return formatter.string(from: NSNumber(value: Int(number))) ?? "0"
    }
}
