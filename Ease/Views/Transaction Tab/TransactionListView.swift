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
            ForEach(transactionVM.transactionSections) { section in
                VStack {
                    TransactionHeaderView(date: section.date)
                        .padding(.bottom, 5)
                    
                    ForEach(section.transactions) { transaction in
                        TransactionRowView(transaction: transaction)
                    }
                }
                .padding(.bottom, 30)
            }
        }
        .scrollBounceBehavior(.basedOnSize)
        .scrollIndicators(.hidden)
        .padding(.horizontal, 10)
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
                .font(.headline.weight(.light))
        }
        .padding(.vertical, 5)
    }
}

struct TransactionHeaderView: View {
    var date: Date
    
    var body: some View {
        VStack() {
            HStack {
                Text(date, format: .dateTime.weekday(.wide).day().month(.wide))
                
                Spacer()
                
                Text("$50.00")
            }
            .font(.title3.weight(.medium))
            
            CustomDivider()
        }
    }
}

struct EmptyTransactionListView: View {
    var body: some View {
        Text("No transactions")
    }
}

#Preview {
    let container = ModelContainer.preview
    let context = container.mainContext

    let descriptor = FetchDescriptor<Transaction>(sortBy: [SortDescriptor(\.date, order: .reverse)])
    let transactions = (try? context.fetch(descriptor)) ?? []

    let transactionVM = TransactionViewModel()
    transactionVM.getTransactionsByMonth(transactions: transactions)

    return TransactionListView(transactionVM: transactionVM, transactions: transactions)
        .modelContainer(container)
}
