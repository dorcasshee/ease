//
//  DashboardTab.swift
//  Ease
//
//  Created by Dorcas Shee on 10/12/25.
//

import SwiftUI
import SwiftData
import Charts

struct DashboardTab: View {
    var transactionListVM: TransactionListViewModel
    
    var body: some View {
        VStack {
            MonthPickerView(transactionListVM: transactionListVM)
            
            Spacer()
            
            if !transactionListVM.expenseTrsnsByCategory.isEmpty {
                HStack {
                    Text("Expenses By Category")
                        .font(.title3.bold())
                    
                    Spacer()
                }
                
                Chart(transactionListVM.expenseTrsnsByCategory, id: \.category.id) { trsn in
                    SectorMark(angle: .value(trsn.category.name, trsn.total),
                               innerRadius: .ratio(0.6),
                               angularInset: 2)
                        .cornerRadius(5)
                        .foregroundStyle(Color(trsn.category.colorName))
                }
                .scaledToFit()
            } else {
                Text("Dashboard")
            }
            
            Spacer()
        }
        .padding()
    }
}

#Preview {
    DashboardTab(transactionListVM: TransactionListViewModel())
        .modelContainer(.preview)
}
