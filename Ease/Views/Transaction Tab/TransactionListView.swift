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
            List(transactionVM.transactionSections) { section in
                Section {
                    ForEach(section.transactions) { transaction in
                        TransactionRowView(transaction: transaction)
                            .listRowSeparator(.hidden)
                            .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 10, trailing: 0))
                            .listRowBackground(Color.clear)
                            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                Button(role: .destructive) {
                                    transactionVM.deleteTransaction(context: context, item: transaction)
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                                .tint(.eRed)
                                
                                Button {
                                    transactionVM.duplicateTransaction(item: transaction)
                                    transactionVM.showSheet = true
                                } label: {
                                    Label("Duplicate", systemImage: "document.on.document")
                                }
                                .tint(Color.eBlue)
                            }
                    }
                } header: {
                    TransactionHeaderView(date: section.formattedDate, amount: section.formattedTotal)
                        .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 13, trailing: 0))
                }
                .listSectionSpacing(25)
                .listSectionSeparator(.hidden)
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
            .scrollIndicators(.hidden)
            .scrollBounceBehavior(.basedOnSize)
            .padding(.horizontal, 10)
            .contentMargins(.top, 0, for: .scrollContent)
            .sheet(isPresented: $transactionVM.showSheet) {
                RecordExpenseView(transactionVM: transactionVM)
            }
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
