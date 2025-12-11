//
//  TabBarView.swift
//  Ease
//
//  Created by Dorcas Shee on 10/12/25.
//

import SwiftUI

struct TabBarView: View {
    var body: some View {
        TabView() {
            Tab(String(), systemImage: "house") {
                DashboardTab()
            }
                        
            Tab(String(), systemImage: "list.bullet") {
                TransactionTab()
            }
            
            Tab(String(), systemImage: "plus.circle") {
                RecordExpenseView()
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
