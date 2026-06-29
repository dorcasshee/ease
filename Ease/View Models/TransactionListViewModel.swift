//
//  TransactionListViewModel.swift
//  Ease
//
//  Created by Dorcas Shee on 1/5/26.
//

import Foundation
import SwiftData

@Observable class TransactionListViewModel {
    // repos
    var transactionRepository: TransactionRepository
    var payeeRepository: PayeeRepository
    
    // state
    var currentDate: Date
    var currentMonthTransactions: [Transaction] = []
    var showSheet: Bool = false
    
    // computed properties
    var transactionSections: [TransactionSection] {
        let grouping = Dictionary(grouping: currentMonthTransactions, by: { Calendar.current.startOfDay(for: $0.date) })
        
        return grouping.map { (date, transactions) in
            let sortedTrsns = transactions.sorted { $0.createdAt > $1.createdAt }
            return TransactionSection(date: date, transactions: sortedTrsns)
        }
        .sorted { $0.date > $1.date }
    }
    
    var currentMonthIncome: Double {
        let incomeTrsns = currentMonthTransactions.filter { $0.category.transactionType == .income }
        
        return incomeTrsns.reduce(0) { result, trsn in
            result + trsn.amount
        }
    }
    
    var currentMonthExpense: Double {
        let expTrsns = currentMonthTransactions.filter { $0.category.transactionType == .expense }
        
        return expTrsns.reduce(0) { result, trsn in
            result + trsn.amount
        }
    }
    
    var currentMonthBalance: Double {
        return currentMonthIncome - currentMonthExpense
    }
    
    var maxFigCount: Int {
        return max(
            currentMonthIncome.formatAsCurrency().count,
            currentMonthExpense.formatAsCurrency().count,
            currentMonthBalance.formatAsCurrency().count
        )
    }
    
    var expenseTrsnsByCategory: [(category: SubCategory, total: Double)] {
        let currentMonthExpenses = currentMonthTransactions.filter { $0.category.transactionType == .expense }
        return Dictionary(grouping: currentMonthExpenses, by: \.category)
            .map { (category: $0, total: $1.reduce(0) { $0 + $1.amount }) }
            .sorted { $0.total != $1.total ? $0.total > $1.total : $0.category.id < $1.category.id }
    }
    
    // init
    init(transactionRepository: TransactionRepository = SwiftDataTransactionService(), payeeRepository: PayeeRepository = SwiftDataPayeeService()) {
        self.transactionRepository = transactionRepository
        self.payeeRepository = payeeRepository
        self.currentDate = Date()
    }
    
    // functions
    func deleteTransaction(context: ModelContext, item: Transaction) -> Bool {
        do {
            let payeeID = item.payee?.persistentModelID
            try transactionRepository.deleteTransaction(item, context: context)
            
            if let payeeID {
                payeeRepository.deletePayeeIfOrphaned(id: payeeID, context: context)
            }
            
            currentMonthTransactions.removeAll() { $0.id == item.id }
            return true
        } catch {
            return false
        }
    }
    
    func getTransactionsByMonth(transactions: [Transaction]) {
        currentMonthTransactions = transactions.filter { transaction in
            Calendar.current.isDate(transaction.date, equalTo: currentDate, toGranularity: .month)
        }
    }
    
    func incrementMonth() {
        if let newDate = Calendar.current.date(byAdding: .month, value: 1, to: currentDate) {
            currentDate = newDate
        }
    }
    
    func decrementMonth() {
        if let newDate = Calendar.current.date(byAdding: .month, value: -1, to: currentDate) {
            currentDate = newDate
        }
    }
    
    func getTopXExpensesForThisMonth(x: Int) -> [Transaction] {
        let currentMonthExpenses = currentMonthTransactions.filter { $0.category.transactionType == .expense }
        return Array(currentMonthExpenses.sorted { $0.amount > $1.amount }.prefix(x))
    }

    func getTopXExpenseCategoriesForThisMonth(x: Int) -> [(category: SubCategory, total: Double)] {
        return Array(expenseTrsnsByCategory.prefix(x))
    }
}

