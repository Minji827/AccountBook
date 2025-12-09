import SwiftUI

struct TransactionRow: View {
    let transaction: Transaction
    
    var body: some View {
        HStack {
            Text(transaction.category.emoji)
                .font(.title2)
                .padding(10)
                .background(Color.white)
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.black, lineWidth: 2)
                )
            
            VStack(alignment: .leading, spacing: 4) {
                Text(transaction.note)
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.black)
                Text(transaction.date, style: .date)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text("₩\(Int(transaction.amount))")
                    .font(.headline)
                    .fontWeight(.black)
                    .foregroundColor(transaction.isIncome ? NeoColors.success : NeoColors.error)
                
                if transaction.currency != .krw {
                    Text("\(transaction.currency.symbol)\(Int(transaction.originalAmount))")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.black, lineWidth: 2)
        )
        .shadow(color: .black, radius: 0, x: 4, y: 4)
    }
}
