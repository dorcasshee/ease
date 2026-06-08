//
//  TabBarView.swift
//  Ease
//
//  Created by Dorcas Shee on 10/12/25.
//

import SwiftUI

struct TabBarView: View {
    @State private var transactionListVM = TransactionListViewModel()
    @State private var transactionFormVM = TransactionFormViewModel()
    
    var body: some View {
        TabView() {
            Tab(String(), systemImage: "house") {
                DashboardTab(transactionListVM: transactionListVM)
            }
                        
            Tab(String(), systemImage: "list.bullet") {
                TransactionTab(transactionListVM: transactionListVM, transactionFormVM: transactionFormVM)
            }
            
            Tab(String(), systemImage: "gearshape") {
                SettingsTab()
            }
        }
        .tint(.eBlack)
    }
}

#Preview {
    TabBarView()
}
