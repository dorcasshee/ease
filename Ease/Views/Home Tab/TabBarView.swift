//
//  TabBarView.swift
//  Ease
//
//  Created by Dorcas Shee on 10/12/25.
//

import SwiftUI
import SwiftData

struct TabBarView: View {
    @Query(sort: \Transaction.date, order: .reverse) private var transactions: [Transaction]
    @State private var transactionListVM = TransactionListViewModel()
    @State private var transactionFormVM = TransactionFormViewModel()
    
    var body: some View {
        TabView() {
            Tab(String(), systemImage: "house") {
                DashboardTab(transactionFormVM: transactionFormVM, transactionListVM: transactionListVM)
            }
                        
            Tab(String(), systemImage: "list.bullet") {
                TransactionTab(transactionListVM: transactionListVM, transactionFormVM: transactionFormVM, transactions: transactions)
            }
            
            Tab(String(), systemImage: "gearshape") {
                SettingsTab()
            }
        }
        .tint(.eBlack)
        .onAppear {
            if transactionListVM.currentMonthTransactions.isEmpty {
                transactionListVM.getTransactionsByMonth(transactions: transactions)
            }
        }
        .onChange(of: transactionListVM.currentDate) {
            transactionListVM.getTransactionsByMonth(transactions: transactions)
        }
        .onChange(of: transactions) {
            transactionListVM.getTransactionsByMonth(transactions: transactions)
        }
    }
}

#Preview {
    TabBarView()
}
