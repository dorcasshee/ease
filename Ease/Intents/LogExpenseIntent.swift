//
//  LogExpenseIntent.swift
//  Ease
//
//  Created by Dorcas Shee on 18/9/26.
//

import AppIntents
import SwiftData

struct LogExpenseIntent: AppIntent {
    static var title: LocalizedStringResource = "Add New Expense Transaction to Ease"
    static var description = IntentDescription("Logs money paid to Ease.")

    @Parameter(title: "Amount", description: "Transaction amount.")
    var amount: Double

    @Parameter(title: "Paid To", description: "Person/entity who is being paid.")
    var payeeName: String?

    @Parameter(title: "Description", description: "Transaction description.")
    var desc: String?

    @Parameter(title: "Date", description: "Transaction date.")
    var date: Date?

    static var parameterSummary: some ParameterSummary {
        Summary("""
Amount Paid: \(\.$amount)
Paid To:\(\.$payeeName)
Description: \(\.$desc)
""")
    }

    func perform() async throws -> some IntentResult {
        let container = try ModelContainer(for: Transaction.self, ParentCategory.self, SubCategory.self, Payee.self)
        let context = ModelContext(container)

        let uncategorizedID = "scat.expense.uncategorized.uncategorized"
        let uncategorizedDescriptor = FetchDescriptor<SubCategory>(predicate: #Predicate { $0.id == uncategorizedID })
        guard let uncategorized = try context.fetch(uncategorizedDescriptor).first else {
            throw LogTransactionIntentError.missingUncategorizedCategory
        }

        let payeeRepository: PayeeRepository = await SwiftDataPayeeService()
        let trimmedPayeeName = payeeName?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let payee = await trimmedPayeeName.isEmpty ? nil : payeeRepository.getOrCreatePayee(name: trimmedPayeeName, context: context)

        let transactionRepository: TransactionRepository = await SwiftDataTransactionService()
        try await transactionRepository.createTransaction(
            amount: amount,
            category: uncategorized,
            transactionType: .expense,
            desc: desc,
            payee: payee,
            date: Date(),
            isRecurring: false,
            needsReview: true,
            context: context
        )
        try await transactionRepository.saveTransaction(context: context)

        return .result()
    }
}

enum LogTransactionIntentError: Error, LocalizedError {
    case missingUncategorizedCategory

    var errorDescription: String? {
        switch self {
        case .missingUncategorizedCategory:
            return "Open Ease at least once first so it can set up its default categories."
        }
    }
}
