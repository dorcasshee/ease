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
    @Bindable var transactionVM: TransactionViewModel
    @State private var buttonTapCount: Int = 0
    
    var body: some View {
        VStack {
            MonthPickerView(transactionVM: transactionVM)
            
            Text("^[\(transactionVM.currentMonthTransactions.count) transaction](inflect:true)")
                .font(.callout)
                .foregroundStyle(.secondary)
                .padding(.top, 5)
                .padding(.bottom)
            
            BalanceCardView(transactionVM: transactionVM)
                .padding(.horizontal, 10)
            
//            SearchFilterRowView()
            
            TransactionListView(transactionVM: transactionVM, transactions: transactions)
                .padding(.horizontal, -10)
                .overlay(alignment: .bottomTrailing) {
                    Button {
                        buttonTapCount += 1
                        transactionVM.showSheet = true
                        transactionVM.trsnMode = .create
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
                    .sheet(isPresented: $transactionVM.showSheet) {
                        RecordExpenseView(transactionVM: transactionVM)
                    }
                    .sensoryFeedback(.selection, trigger: buttonTapCount)
                }
        }
        .padding()
        .onAppear {
            if transactionVM.currentMonthTransactions.isEmpty {
                transactionVM.getTransactionsByMonth(transactions: transactions)
            }
        }
        .onChange(of: transactionVM.currentDate) {
            transactionVM.getTransactionsByMonth(transactions: transactions)
        }
        .onChange(of: transactions) {
            transactionVM.getTransactionsByMonth(transactions: transactions)
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
    TransactionTab(transactionVM: TransactionViewModel())
        .modelContainer(.preview)
}
