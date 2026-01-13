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
     This view model manages transaction CRUD operations.
     */
    
    private var payeeViewModel: PayeeViewModel
    var amount: Double? = nil
    var isSelected: Bool = false
    var date: Date
    var transactionType: TransactionType = .expense
    var selectedCategories: [TransactionType: TransactionCategory] = [:]
    var desc: String = ""
    var payeeName: String = ""
    var isRecurring: Bool = false
    
    var showError: Bool = false
    var valError: AppError?
    
    var currentDate: Date = Date()
    var currentMonthTransactions: [Transaction] = []
    
    var showSheet: Bool = false
    
    var isEdit: Bool = false
    var trsnToEdit: Transaction? = nil
    var trsnMode: TransactionMode = .create
    
    var suggestions: [String] = []
    var payeeSuggestions: [String] = []
    var descSuggestions: [String] = []
    var showSuggestions: Bool = false
    var isSuggestionSelected: Bool = false
    
    // computed properties
    var category: TransactionCategory? {
        selectedCategories[transactionType]
    }
    
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
    
    enum TransactionMode: Equatable {
        case create, update
    }
    
    // init
    init() {
        self.payeeViewModel = PayeeViewModel()
        self.date = Date()
    }
    
    // functions
    func saveTransaction(context: ModelContext) -> Bool {
        showError = false
        valError = nil
        
        do {
            guard let category = selectedCategories[transactionType] else { throw AppError.missingCategory }
            guard let amount = amount, amount > 0 else { throw AppError.invalidAmount }
            
            let trimmedName = payeeName.trimmingCharacters(in: .whitespacesAndNewlines)
            let payee = trimmedName.isEmpty ? nil : payeeViewModel.getOrCreatePayee(context: context, name: trimmedName)
            
            if trsnMode == .create {
                let newTransaction = Transaction(amount: amount, category: category, desc: desc.isEmpty ? nil : desc, payee: payee, date: date, isRecurring: isRecurring)
                context.insert(newTransaction)
            } else if trsnMode == .update, let editingTrsn = trsnToEdit {
                let oldPayeeID = editingTrsn.payee?.persistentModelID
                
                editingTrsn.amount = amount
                editingTrsn.category = category
                editingTrsn.desc = desc.isEmpty ? nil : desc
                editingTrsn.payee = payee
                editingTrsn.date = date
                editingTrsn.isRecurring = isRecurring
                
                try context.save()
                
                if let oldPayeeID = oldPayeeID, oldPayeeID != payee?.persistentModelID {
                    payeeViewModel.deletePayeeIfOrphaned(context: context, payeeID: oldPayeeID)
                }
            }

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
        currentMonthTransactions.removeAll { $0.id == item.id }
        
        guard let payee = item.payee else {
            context.delete(item)
            return
        }
        
        let payeeID = payee.persistentModelID
        
        context.delete(item)
        try? context.save()
        
        payeeViewModel.deletePayeeIfOrphaned(context: context, payeeID: payeeID)
    }
    
    func loadTransaction(trsn: Transaction, forEditing: Bool) {
        resetForm()
        
        amount = trsn.amount
        transactionType = trsn.category.transactionType
        selectedCategories = [transactionType: trsn.category]
        desc = trsn.desc ?? ""
        payeeName = trsn.payee?.name ?? ""
        date = trsn.date
        isRecurring = trsn.isRecurring
        
        if forEditing {
            trsnMode = .update
            isEdit = true
            trsnToEdit = trsn
        } else {
            isEdit = false
            trsnToEdit = nil
        }
    }
    
    func resetForm() {
        isEdit = false
        trsnToEdit = nil
        trsnMode = .create
        
        amount = nil
        transactionType = .expense
        selectedCategories.removeAll()
        desc = ""
        payeeName = ""
        date = Date()
        isRecurring = false
        
        payeeSuggestions = []
        descSuggestions = []
    }
    
    func saveAndResetForAnother(context: ModelContext, categoryVM: CategoryViewModel) -> Bool {
        let success = saveTransaction(context: context)
        
        if success {
            let lastSavedDate = date
            resetForm()
            date = lastSavedDate
            selectedCategories[transactionType] = try? categoryVM.getDefaultCategory(for: transactionType, context: context)
            return true
        } else {
            return false
        }
    }
    
    func getTransactionsByMonth(transactions: [Transaction]) {
        currentMonthTransactions = transactions.filter { transaction in
            Calendar.current.isDate(transaction.date, equalTo: currentDate, toGranularity: .month)
        }
    }
    
    func getAutocompleteSuggestions(for searchText: String, from items: [String]) -> [String]{
        if isSuggestionSelected {
            isSuggestionSelected = false
            return []
        }
        
        guard !searchText.isEmpty else {
            return []
        }
        
        let uniqueItems = Set(items)
        
        return uniqueItems
            .filter { $0.localizedCaseInsensitiveContains(searchText) }
            .sorted()
            .prefix(3)
            .map { String($0) }
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
