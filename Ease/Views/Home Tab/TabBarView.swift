//
//  TabBarView.swift
//  Ease
//
//  Created by Dorcas Shee on 10/12/25.
//

import SwiftUI

struct TabBarView: View {
    @State private var transactionVM = TransactionViewModel()
    
    var body: some View {
        TabView() {
            Tab(String(), systemImage: "house") {
                DashboardTab(transactionVM: transactionVM)
            }
                        
            Tab(String(), systemImage: "list.bullet") {
                TransactionTab(transactionVM: transactionVM)
            }
            
            Tab(String(), systemImage: "gearshape") {
                SettingsTab()
            }
        }
    }
}

#Preview {
    TabBarView()
}
