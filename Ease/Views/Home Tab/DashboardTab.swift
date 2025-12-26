//
//  DashboardTab.swift
//  Ease
//
//  Created by Dorcas Shee on 10/12/25.
//

import SwiftUI
import SwiftData

struct DashboardTab: View {
    var transactionVM: TransactionViewModel
    
    var body: some View {
        VStack {
            MonthPickerView(transactionVM: transactionVM)
            
            Spacer()
            
            Text("Dashboard")
            
            Spacer()
        }
        .padding()
    }
}

#Preview {
    DashboardTab(transactionVM: TransactionViewModel())
        .modelContainer(.preview)
}
