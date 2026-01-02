//
//  TransactionHeaderView.swift
//  Ease
//
//  Created by Dorcas Shee on 28/12/25.
//

import SwiftUI

struct TransactionHeaderView: View {
    var date: String
    var amount: String
    
    var body: some View {
        VStack() {
            HStack {                
                Text(date)
                
                Spacer()
                
                Text(amount)
            }
            .font(.headline.weight(.heavy))
            .multilineTextAlignment(.leading)
            .foregroundStyle(.eBlack)
            
            CustomDivider()
        }
        .background(.eWhite)
    }
}

#Preview {
    TransactionHeaderView(date: "Sunday, 28 December 2025", amount: "$10.00")
}
