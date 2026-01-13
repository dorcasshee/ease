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
                        Button {
                            transactionVM.loadTransaction(trsn: transaction, forEditing: true)
                            transactionVM.showSheet = true
                        } label: {
                            TransactionRowView(transaction: transaction)
                        }
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.clear)
                        .listRowInsets(EdgeInsets(top: 10, leading: 10, bottom: 5, trailing: 10))
                        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                            Button(role: .destructive) {
                                transactionVM.deleteTransaction(context: context, item: transaction)
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                            .tint(.eRed)
                            
                            Button {
                                transactionVM.loadTransaction(trsn: transaction, forEditing: false)
                                transactionVM.showSheet = true
                            } label: {
                                Label("Duplicate", systemImage: "document.on.document")
                            }
                            .tint(.accent)
                        }
                    }
                } header: {
                    TransactionHeaderView(date: section.date.formatRelativeDate(), amount: section.formattedTotal)
                        .listRowInsets(EdgeInsets())
                }
                .listSectionSpacing(30)
                .listSectionSeparator(.hidden)
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
            .scrollIndicators(.hidden)
            .scrollBounceBehavior(.basedOnSize)
            .padding(.horizontal, 10)
            .contentMargins(.top, 0, for: .scrollContent)
            .safeAreaInset(edge: .bottom) {
                Color.clear.frame(height: 40)
            }
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
