//
//  TransactionListView.swift
//  Ease
//
//  Created by Dorcas Shee on 10/12/25.
//

import SwiftUI
import SwiftData

struct TransactionListView: View {
    @Environment(\.modelContext) private var context
    @Bindable var transactionVM: TransactionViewModel
    var transactions: [Transaction]
    
    var body: some View {
        ScrollView {
            ForEach(transactionVM.currentMonthTransactions) { transaction in
                TransactionRowView(transaction: transaction)
            }
        }
        .scrollBounceBehavior(.basedOnSize)
        .scrollIndicators(.hidden)
        .padding(.horizontal)
    }
}

struct TransactionRowView: View {
    var transaction: Transaction
    
    var body: some View {
        HStack(alignment: .top) {
            Image(systemName: transaction.category.iconName)
                .resizable()
                .scaledToFit()
                .frame(width: 40, height: 40)
                .foregroundStyle(Color(hex: transaction.category.colorHex))
                .padding(.trailing, 10)
            
            VStack(alignment: .leading) {
                Text(transaction.desc ?? transaction.category.name)
                    .font(.headline)
                
                if transaction.desc != nil {
                    Text(transaction.category.name)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                if transaction.payee != nil {
                    Text(transaction.payee?.name ?? "")
                        .font(.caption.bold())
                        .foregroundStyle(.secondary)
                }
            }
            
            Spacer()
            
            Text(transaction.amount, format: .currency(code: Locale.current.currency?.identifier ?? "USD"))
        }
        .padding(.vertical, 10)
    }
}

struct EmptyTransactionListView: View {
    var body: some View {
        Text("No transactions")
    }
}

#Preview {
    @Previewable @Query(sort: \Transaction.date, order: .reverse) var transactions: [Transaction]
    TransactionListView(transactionVM: TransactionViewModel(), transactions: transactions)
        .modelContainer(.preview)
}
