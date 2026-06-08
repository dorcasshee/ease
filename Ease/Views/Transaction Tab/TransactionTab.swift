//
//  TransactionTab.swift
//  Ease
//
//  Created by Dorcas Shee on 10/12/25.
//

import SwiftUI
import SwiftData

struct TransactionTab: View {
    @Query(sort: \Transaction.date, order: .reverse) private var transactions: [Transaction]
    @Bindable var transactionListVM: TransactionListViewModel
    @Bindable var transactionFormVM: TransactionFormViewModel
    @State private var buttonTapCount: Int = 0
    
    var body: some View {
        VStack {
            MonthPickerView(transactionListVM: transactionListVM)
            
            Text("^[\(transactionListVM.currentMonthTransactions.count) transaction](inflect:true)")
                .font(.callout)
                .foregroundStyle(.secondary)
                .padding(.top, 5)
                .padding(.bottom)
            
            BalanceCardView(transactionListVM: transactionListVM)
                .padding(.horizontal, 10)
            
//            SearchFilterRowView()
            
            TransactionListView(transactionListVM: transactionListVM, transactionFormVM: transactionFormVM, transactions: transactions)
                .padding(.horizontal, -10)
                .overlay(alignment: .bottomTrailing) {
                    Button {
                        buttonTapCount += 1
                        transactionFormVM.resetForm()
                        transactionFormVM.showSheet = true
                    } label: {
                        ZStack {
                            Circle()
                                .foregroundStyle(.eBlack)
                                .frame(width: 60, height: 60)
                            
                            Image(systemName: "plus")
                                .foregroundStyle(.eWhite)
                                .font(.title2.bold())
                        }
                    }
                    .sheet(isPresented: $transactionFormVM.showSheet) {
                        RecordExpenseView(transactionFormVM: transactionFormVM)
                    }
                    .sensoryFeedback(.selection, trigger: buttonTapCount)
                }
        }
        .padding()
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

struct SearchFilterRowView: View {
    var body: some View {
        HStack {
            Spacer()
            
            Button {
                
            } label: {
                Image(systemName: "magnifyingglass")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 24, height: 24)
                    .foregroundStyle(.eBlack)
            }
            
            Button {
                
            } label: {
                Image(systemName: "line.3.horizontal.decrease")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 24, height: 24)
                    .foregroundStyle(.eBlack)
            }
        }
        .padding(.horizontal)
        .padding(.top)
    }
}

#Preview {
    TransactionTab(transactionListVM: TransactionListViewModel(), transactionFormVM: TransactionFormViewModel())
        .modelContainer(.preview)
}
