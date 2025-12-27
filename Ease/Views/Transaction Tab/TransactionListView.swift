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
        if transactionVM.currentMonthTransactions.isEmpty {
            ContentUnavailableView("No Transactions", systemImage: "tray", description: Text("Start tracking your expenses by tapping the + button."))
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else {
            ScrollView {
                ForEach(transactionVM.transactionSections) { section in
                    VStack {
                        TransactionHeaderView(date: section.formattedDate, amount: section.formattedTotal)
                            .padding(.bottom, 5)
                        
                        ForEach(section.transactions) { transaction in
                            Button {
                                
                            } label: {
                                TransactionRowView(transaction: transaction)
                            }
                            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                Button(role: .destructive) {
                                    transactionVM.deleteTransaction(context: context, item: transaction)
                                } label: {
                                    Image(systemName: "trash")
                                }
                                .tint(.red)
                            }
                        }
                    }
                    .padding(.bottom, 30)
                }
                
                Spacer()
            }
            .scrollBounceBehavior(.basedOnSize)
            .scrollIndicators(.hidden)
            .padding(.horizontal, 10)
        }
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
