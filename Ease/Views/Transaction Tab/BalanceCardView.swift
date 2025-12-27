//
//  BalanceCardView.swift
//  Ease
//
//  Created by Dorcas Shee on 27/12/25.
//

import SwiftUI

struct BalanceCardView: View {
    var transactionVM: TransactionViewModel

    var body: some View {
        HStack {
            BalanceItemView(amount: transactionVM.currentMonthIncome, label: "Income", useSmallFont: transactionVM.isSmallerSummary)

            Spacer()

            BalanceItemView(amount: transactionVM.currentMonthExpense, label: "Expense", useSmallFont: transactionVM.isSmallerSummary)

            Spacer()

            BalanceItemView(amount: transactionVM.currentMonthBalance, label: "Balance", useSmallFont: transactionVM.isSmallerSummary)
        }
        .padding(.horizontal, 30)
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
    let useSmallFont: Bool

    var body: some View {
        VStack {
            Text(amount.formatAsCurrency())
                .font(useSmallFont ? .subheadline : .title3)
                .fontWeight(.bold)

            Text(label)
                .font(.caption.weight(.light))
                .foregroundStyle(.secondary)
        }
    }
}

#Preview {
    BalanceCardView(transactionVM: TransactionViewModel())
}
