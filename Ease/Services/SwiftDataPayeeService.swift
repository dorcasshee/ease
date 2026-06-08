//
//  SwiftDataPayeeService.swift
//  Ease
//
//  Created by Dorcas Shee on 8/6/26.
//

import Foundation
import SwiftData

class SwiftDataPayeeService: PayeeRepository {
    func getOrCreatePayee(name: String, context: ModelContext) -> Payee {
        let descriptor = FetchDescriptor<Payee>(predicate: #Predicate { $0.name == name })
        
        if let existingPayee = try? context.fetch(descriptor).first {
            return existingPayee // payee exists
        } else {
            // payee doesn't exist so create new payee
            let newPayee = Payee(name: name)
            context.insert(newPayee)
            return newPayee
        }
    }
    
    func deletePayeeIfOrphaned(id: PersistentIdentifier, context: ModelContext) {
        guard let payee = context.model(for: id) as? Payee else { return }
        
        let payeeName = payee.name
        let descriptor = FetchDescriptor<Transaction>(predicate: #Predicate { $0.payee?.name == payeeName })
        let count = try? context.fetchCount(descriptor)
        
        if count == 0 {
            context.delete(payee)
            try? context.save()
        }
    }
}
