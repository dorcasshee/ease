//
//  EaseTests.swift
//  EaseTests
//
//  Created by Dorcas Shee on 1/11/25.
//

import Testing
import Foundation
import SwiftData
@testable import Ease

struct EaseTests {

    @Test func createTransactionStoresGivenTransactionType() throws {
        let schema = Schema([Transaction.self, ParentCategory.self, SubCategory.self, Payee.self])
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: schema, configurations: config)
        let context = ModelContext(container)

        let parent = ParentCategory(id: "test.income", name: "Income", iconName: "dollar", isSystemIcon: true, colorName: "eGreen", transactionType: .income)
        let category = SubCategory(id: "test.income.salary", name: "Salary", iconName: "dollar", isSystemIcon: true, isDefault: false, parent: parent)
        context.insert(parent)
        context.insert(category)

        let service = SwiftDataTransactionService()
        try service.createTransaction(amount: 100, category: category, transactionType: .income, desc: nil, payee: nil, date: .now, isRecurring: false, needsReview: false, context: context)
        try service.saveTransaction(context: context)

        let transactions = try context.fetch(FetchDescriptor<Transaction>())
        #expect(transactions.count == 1)
        #expect(transactions.first?.transactionType == .income)
    }

}
