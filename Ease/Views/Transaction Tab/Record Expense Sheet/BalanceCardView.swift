//
//  BalanceCardView.swift
//  Ease
//
//  Created by Dorcas Shee on 27/12/25.
//

import SwiftUI

struct BalanceCardView: View {
    var transactionVM: TransactionViewModel
    var font: Font {
        if transactionVM.maxFigCount >= 11 {
            return .subheadline
        } else if transactionVM.maxFigCount >= 9 {
            return .headline
        } else {
            return .title3
        }
    }

    var body: some View {
        HStack {
            BalanceItemView(amount: transactionVM.currentMonthIncome, label: "Income", font: font)

            Spacer()

            BalanceItemView(amount: transactionVM.currentMonthExpense, label: "Expense", font: font)

            Spacer()

            BalanceItemView(amount: transactionVM.currentMonthBalance, label: "Balance", font: font)
        }
        .padding(.horizontal, 25) 
        .padding(.vertical)
        .background {
            RoundedRectangle(cornerRadius: 12)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .foregroundStyle(Color(.secondarySystemFill))
        }
    }
}

struct BalanceItemView: View {
    let amount: Double
    let label: String
    var font: Font

    var body: some View {
        VStack {
            Text(amount.formatAsCurrency())
                .font(font)
                .fontWeight(.bold)

            Text(label)
                .font(.callout.weight(.light))
                .foregroundStyle(Color(.systemGray))
        }
    }
}

#Preview {
    BalanceCardView(transactionVM: TransactionViewModel())
}
