//
//  EaseApp.swift
//  Ease
//
//  Created by Dorcas Shee on 1/11/25.
//

import SwiftUI
import SwiftData

@main
struct EaseApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: [Transaction.self, Payee.self, TransactionCategory.self], onSetup: { result in
            switch result {
                case .success(let container):
                    do {
                        try TransactionCategory.seedDefaultCategories(in: container.mainContext)
                    } catch {
                        print("Error occurred while seeding data: \(error.localizedDescription)")
                    }
                case .failure(let error):
                    print("Error creating container: \(error.localizedDescription)")
            }
        })
    }
}
