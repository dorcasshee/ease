//
//  TransactionFormViewModel.swift
//  Ease
//
//  Created by Dorcas Shee on 1/5/26.
//

import Foundation
import SwiftData

@Observable class TransactionFormViewModel {
    // repositories
    var transactionRepository: TransactionRepository
    var payeeRepository: PayeeRepository
    
    // form inputs
    var amount: Double?
    var transactionType: TransactionType = .expense
    var date: Date = Date()
    var selectedCategories: [TransactionType: SubCategory] = [:]
    var desc: String = ""
    var payeeName: String = ""
    var isRecurring: Bool = false
    
    // editing
    var transactionToEdit: Transaction? = nil
    
    // UI state
    var showSheet: Bool = false
    var showError: Bool = false
    var validationError: AppError? = nil
    
    // autocompletion
    var payeeSuggestions: [String] = []
    var descSuggestions: [String] = []
    var isSuggestionSelected: Bool = false
    
    // computed properties
    var category: SubCategory? {
        selectedCategories[transactionType]
    }
    
    var isEditing: Bool {
        transactionToEdit != nil
    }
    
    init(transactionRepository: TransactionRepository = SwiftDataTransactionService(),
         payeeRepository: PayeeRepository = SwiftDataPayeeService()) {
        self.transactionRepository = transactionRepository
        self.payeeRepository = payeeRepository
    }
    
    func saveTransaction(context: ModelContext) -> Bool {
        do {
            // form validation
            showError = false
            validationError = nil

            guard let category = selectedCategories[transactionType] else { throw AppError.missingCategory }
            let amount = amount ?? 0.0

            let trimmedName = payeeName.trimmingCharacters(in: .whitespacesAndNewlines)
            let payee = trimmedName.isEmpty ? nil : payeeRepository.getOrCreatePayee(name: trimmedName, context: context)

            if isEditing, let editingTrsn = transactionToEdit {
                let oldPayeeID = editingTrsn.payee?.persistentModelID

                editingTrsn.amount = amount
                editingTrsn.category = category
                editingTrsn.transactionType = transactionType
                editingTrsn.desc = desc.isEmpty ? nil : desc
                editingTrsn.payee = payee
                editingTrsn.date = date
                editingTrsn.isRecurring = isRecurring
                editingTrsn.needsReview = false

                try transactionRepository.saveTransaction(context: context)
                
                if let oldPayeeID = oldPayeeID, oldPayeeID != payee?.persistentModelID {
                    payeeRepository.deletePayeeIfOrphaned(id: oldPayeeID, context: context)
                }
            } else {
                try transactionRepository.createTransaction(amount: amount, category: category, transactionType: transactionType, desc: desc.isEmpty ? nil : desc, payee: payee, date: date, isRecurring: isRecurring, context: context)
            }

            return true
        } catch let error as AppError {
            validationError = error
            showError = true
            return false
        } catch {
            validationError = .unexpectedError
            showError = true
            return false
        }
    }
    
    func deleteTransaction(context: ModelContext, item: Transaction) -> Bool {
        showError = false
        validationError = nil

        do {
            let payeeID = item.payee?.persistentModelID

            try transactionRepository.deleteTransaction(item, context: context)

            if let payeeID = payeeID {
                payeeRepository.deletePayeeIfOrphaned(id: payeeID, context: context)
            }

            if transactionToEdit?.id == item.id {
                resetForm()
            }

            return true
        } catch let error as AppError {
            validationError = error
            showError = true
            return false
        } catch {
            validationError = .unexpectedError
            showError = true
            return false
        }
    }
    
    func resetForm() {
        amount = nil
        transactionType = .expense
        selectedCategories.removeAll()
        desc = ""
        payeeName = ""
        date = Date()
        isRecurring = false
        
        payeeSuggestions = []
        descSuggestions = []
        
        transactionToEdit = nil
    }
    
    func loadTransactionForEditing(_ transaction: Transaction) {
        resetForm()
        
        amount = transaction.amount
        transactionType = transaction.category.transactionType
        selectedCategories = [transactionType: transaction.category]
        desc = transaction.desc ?? ""
        payeeName = transaction.payee?.name ?? ""
        isRecurring = transaction.isRecurring
        date = transaction.date
        
        transactionToEdit = transaction
    }
    
    func loadTransactionForDuplication(_ transaction: Transaction) {
        resetForm()
        
        amount = transaction.amount
        transactionType = transaction.category.transactionType
        selectedCategories = [transactionType: transaction.category]
        desc = transaction.desc ?? ""
        payeeName = transaction.payee?.name ?? ""
        isRecurring = transaction.isRecurring
    }
    
    func saveAndResetForAnother(context: ModelContext, categoryVM: CategoryViewModel) -> Bool {
        let success = saveTransaction(context: context)
        
        if success {
            let lastSavedDate = date
            resetForm()
            date = lastSavedDate
            selectedCategories[transactionType] = try? categoryVM.getDefaultCategory(for: transactionType, context: context)
        }
        
        return success
    }

    func getAutocompleteSuggestions(for searchText: String, from items: [String]) -> [String] {
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
}
