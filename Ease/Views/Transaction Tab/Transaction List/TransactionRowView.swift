//
//  TransactionRowView.swift
//  Ease
//
//  Created by Dorcas Shee on 28/12/25.
//

import SwiftUI

struct TransactionRowView: View {
    var transaction: Transaction
    
    var body: some View {
        HStack(alignment: .top) {
            CategoryIconView(imageName: transaction.category.iconName, color: transaction.category.transactionType.color)
                .padding(.trailing, 10)
            
            VStack(alignment: .leading) {
                Text(transaction.desc ?? transaction.category.name)
                    .font(.title3.weight(.medium))
                    .foregroundStyle(.eBlack)
                
                if transaction.desc != nil {
                    Text(transaction.category.name)
                        .font(.callout)
                        .foregroundStyle(.eBlack.secondary)
                }
                
                if transaction.payee != nil {
                    Text(transaction.payee?.name ?? "")
                        .font(.callout.bold())
                        .foregroundStyle(.eBlack.secondary)
                }
            }
            .multilineTextAlignment(.leading)
            
            Spacer()
            
            Text(transaction.formattedAmount)
                .font(.title3)
                .fontWeight(transaction.category.transactionType == .income ? .bold : .light)
                .foregroundStyle(transaction.category.transactionType == .income ? .eGreen : .eBlack)
        }
        .padding(.bottom, 5)
    }
}

#Preview {
    let trsn = Transaction(amount: 1000, category: Category(name: "Salary", iconName: "dollar", transactionType: .expense), desc: "Salary", payee: Payee(name: "Company A"), date: Date())
    
    TransactionRowView(transaction: trsn)
}
