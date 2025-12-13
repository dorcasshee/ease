//
//  PayeeViewModel.swift
//  Ease
//
//  Created by Dorcas Shee on 7/12/25.
//

import Foundation
import SwiftData

@Observable
class PayeeViewModel {
    /*
     This view model contains manages create, update, and delete operations for Payees.
     */
    
    func getOrCreatePayee(context: ModelContext, name: String) -> Payee {
        //check database if payee exist
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
}
