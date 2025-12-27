//
//  BalanceCardView.swift
//  Ease
//
//  Created by Dorcas Shee on 27/12/25.
//

import SwiftUI

struct BalanceCardView: View {
    var body: some View {
        HStack {
            VStack {
                Text("$4,500")
                    .font(.title2.bold())
                
                Text("Income")
                    .font(.caption)
                    .fontWeight(.light)
            }
            
            Spacer()
            
            VStack {
                Text("$60")
                    .font(.title2.bold())
                
                Text("Expense")
                    .font(.caption)
                    .fontWeight(.light)
            }
            
            Spacer()
            
            VStack {
                Text("$100,400")
                    .font(.title2.bold())
                
                Text("Balance")
                    .font(.caption)
                    .fontWeight(.light)
            }
        }
        .padding()
        .padding(.horizontal, 10)
        .background {
            RoundedRectangle(cornerRadius: 12)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .foregroundStyle(Color(.secondarySystemFill))
        }
    }
}

#Preview {
    BalanceCardView()
}
