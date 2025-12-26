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
    
    var body: some View {
        VStack {
            MonthPickerView(transactionVM: transactionVM)
            
            Text("^[\(transactionVM.currentMonthTransactions.count) transaction](inflect:true)")
                .font(.caption)
                .foregroundStyle(.secondary)
                .padding(.top, 5)
                .padding(.bottom)
            
            BalanceCardView()
                .padding(.horizontal, 10)
            
            SearchFilterRowView()
            
            TransactionListView(transactionVM: transactionVM, transactions: transactions)
                .overlay(alignment: .bottomTrailing) {
                    Button {
                        transactionVM.showSheet = true
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
                }
            
            Spacer()
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

struct MonthPickerView: View {
    var transactionVM: TransactionViewModel
    
    var body: some View {
        HStack {
            Button {
                transactionVM.decrementMonth()
            } label: {
                Image(systemName: "chevron.left")
                    .foregroundStyle(.eBlack)
            }
            
            Spacer()
            
            Text(transactionVM.currentDate, format: .dateTime.month(.wide).year())
                .blackButtonStyle(font: .title3.weight(.bold))
            
            Spacer()
            
            Button {
                transactionVM.incrementMonth()
            } label: {
                Image(systemName: "chevron.right")
                    .foregroundStyle(.eBlack)
            }
        }
        .padding(.horizontal)
    }
}

struct BalanceCardView: View {
    var body: some View {
        HStack {
            VStack {
                Text("$4,500")
                    .font(.title2.bold())
                
                Text("Income")
                    .font(.caption)
                    .fontWeight(.light)
            }
            
            Spacer()
            
            VStack {
                Text("$60")
                    .font(.title2.bold())
                
                Text("Expense")
                    .font(.caption)
                    .fontWeight(.light)
            }
            
            Spacer()
            
            VStack {
                Text("$100,400")
                    .font(.title2.bold())
                
                Text("Balance")
                    .font(.caption)
                    .fontWeight(.light)
            }
        }
        .padding()
        .padding(.horizontal, 10)
        .background {
            RoundedRectangle(cornerRadius: 12)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .foregroundStyle(Color(.secondarySystemFill))
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
        .padding()
    }
}

#Preview {
    TransactionTab(transactionVM: TransactionViewModel())
        .modelContainer(.preview)
}
