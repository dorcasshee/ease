//
//  TransactionViewModel.swift
//  Ease
//
//  Created by Dorcas Shee on 6/12/25.
//

import Foundation
import SwiftData

@Observable class TransactionViewModel {
    /*
     This view model contains the following logic for transaction CRUD operations.
     */
    
    private var payeeViewModel: PayeeViewModel
    var amount: Double = 0
    var isSelected: Bool = false
    var date: Date
    var transactionType: TransactionType = .expense
    var selectedCategories: [TransactionType: TransactionCategory] = [:]
    var desc: String = ""
    var payeeName: String = ""
    var isRecurring: Bool = false
    
    var showError: Bool = false
    var valError: AppError?
    
    var showSheet: Bool = false
    
    var category: TransactionCategory? {
        selectedCategories[transactionType]
    }
    
    var currentDate: Date = Date()
    var currentMonthTransactions: [Transaction] = []
    
    init() {
        self.payeeViewModel = PayeeViewModel()
        self.date = Date()
    }
    
    func createTransaction(context: ModelContext) -> Bool {
        showError = false
        valError = nil
        
        do {
            guard let category = selectedCategories[transactionType] else { throw AppError.missingCategory }
            guard amount > 0 else { throw AppError.invalidAmount }
            
            let trimmedName = payeeName.trimmingCharacters(in: .whitespacesAndNewlines)
            let payee = trimmedName.isEmpty ? nil : payeeViewModel.getOrCreatePayee(context: context, name: trimmedName)
            
            let newTransaction = Transaction(amount: amount,
                                             category: category,
                                             desc: desc.isEmpty ? nil : desc,
                                             payee: payee,
                                             date: date,
                                             isRecurring: isRecurring)
            
            context.insert(newTransaction)
            try context.save()
            return true
        } catch let error as AppError {
            valError = error
            showError = true
            return false
        } catch {
            valError = .unexpectedError
            showError = true
            return false
        }
    }
    
    func updateTransaction(context: ModelContext, item: Transaction) -> Bool {
        showError = false
        valError = nil
        
        do {
            guard let category = selectedCategories[transactionType] else { throw AppError.missingCategory }
            guard amount > 0 else { throw AppError.invalidAmount }
            
            let trimmedName = payeeName.trimmingCharacters(in: .whitespacesAndNewlines)
            
            item.amount = amount
            item.category = category
            item.desc = desc.isEmpty ? nil : desc
            item.payee = trimmedName.isEmpty ? nil : payeeViewModel.getOrCreatePayee(context: context, name: trimmedName)
            item.date = date
            item.isRecurring = isRecurring
            
            try context.save()
            return true
        } catch let error as AppError {
            valError = error
            showError = true
            return false
        } catch {
            valError = .unexpectedError
            showError = true
            return false
        }
    }
    
    func deleteTransaction(context: ModelContext, item: Transaction) {
        context.delete(item)
    }
    
    func resetForm() {
        amount = 0
        transactionType = .expense
        selectedCategories.removeAll()
        desc = ""
        payeeName = ""
        date = Date()
        isRecurring = false
    }
    
    func getTransactionsByMonth(transactions: [Transaction]) {
        currentMonthTransactions = transactions.filter { transaction in
            Calendar.current.isDate(transaction.date, equalTo: currentDate, toGranularity: .month)
        }
    }
    
    func getTransactionsByDate(transactions: [Transaction]) {
        
    }
    
    func incrementDate() {
        if let newDate = Calendar.current.date(byAdding: .day, value: 1, to: date) {
            date = newDate
        }
    }
    
    func decrementDate() {
        if let newDate = Calendar.current.date(byAdding: .day, value: -1, to: date) {
            date = newDate
        }
    }
    
    func decrementMonth() {
        if let newDate = Calendar.current.date(byAdding: .month, value: -1, to: currentDate) {
            currentDate = newDate
        }
    }
    
    func incrementMonth() {
        if let newDate = Calendar.current.date(byAdding: .month, value: 1, to: currentDate) {
            currentDate = newDate
        }
    }
}


// MARK: Enums
enum TransactionType: String, Identifiable, Codable {
    case expense, income
    var id: String { rawValue }
    
    static let allCases: [TransactionType] = [.expense, .income]
}
