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
//            ZStack(alignment: .center) {
//                Circle()
//                    .frame(width: 50, height: 50)
//                    .foregroundStyle(transaction.category.transactionType.color)
//                
//                Image(systemName: transaction.category.iconName)
//                    .font(.title3.bold())
//                    .foregroundStyle(.white)
//            }
//            .padding(.trailing, 10)
//            
            CategoryIconView(imageName: transaction.category.iconName, color: transaction.category.transactionType.color)
                .padding(.trailing, 10)
            
            VStack(alignment: .leading) {
                Text(transaction.desc ?? transaction.category.name)
                    .font(.headline.weight(.medium))
                    .foregroundStyle(.eBlack)
                
                if transaction.desc != nil {
                    Text(transaction.category.name)
                        .font(.caption)
                        .foregroundStyle(.eBlack.secondary)
                }
                
                if transaction.payee != nil {
                    Text(transaction.payee?.name ?? "")
                        .font(.caption.bold())
                        .foregroundStyle(.eBlack.secondary)
                }
            }
            .multilineTextAlignment(.leading)
            
            Spacer()
            
            Text(transaction.formattedAmount)
                .font(.headline)
                .fontWeight(transaction.category.transactionType == .income ? .bold : .light)
                .foregroundStyle(transaction.category.transactionType == .income ? .eGreen : .eBlack)
        }
        .padding(.vertical, 5)
    }
}

#Preview {
    let trsn = Transaction(amount: 1000, category: TransactionCategory(name: "Salary", iconName: "dollar", transactionType: .expense), desc: "Salary", payee: Payee(name: "Company A"), date: Date())
    
    TransactionRowView(transaction: trsn)
}
