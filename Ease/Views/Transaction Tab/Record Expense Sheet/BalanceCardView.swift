//
//  BalanceCardView.swift
//  Ease
//
//  Created by Dorcas Shee on 27/12/25.
//

import SwiftUI

struct BalanceCardView: View {
    var transactionListVM: TransactionListViewModel
    var font: Font {
        if transactionListVM.maxFigCount >= 11 {
            return .subheadline
        } else if transactionListVM.maxFigCount >= 9 {
            return .headline
        } else {
            return .title3
        }
    }

    var body: some View {
        HStack {
            BalanceItemView(amount: transactionListVM.currentMonthIncome, label: "Income", font: font)

            Spacer()

            BalanceItemView(amount: transactionListVM.currentMonthExpense, label: "Expense", font: font)

            Spacer()

            BalanceItemView(amount: transactionListVM.currentMonthBalance, label: "Balance", font: font)
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
    BalanceCardView(transactionListVM: TransactionListViewModel())
}
