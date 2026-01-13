//
//  MonthPickerView.swift
//  Ease
//
//  Created by Dorcas Shee on 27/12/25.
//

import SwiftUI

struct MonthPickerView: View {
    @State private var buttonTapCount: Int = 0
    var transactionVM: TransactionViewModel
    
    var body: some View {
        HStack {
            Button {
                buttonTapCount += 1
                transactionVM.decrementMonth()
            } label: {
                Image(systemName: "chevron.left")
                    .foregroundStyle(.eBlack)
            }
            
            Spacer()
            
            Button {
                // TODO: MONTH PICKER D:
            } label: {
                Text(transactionVM.currentDate, format: .dateTime.month(.wide).year())
                    .roundButtonStyle(font: .title3.weight(.bold))
            }
            
            Spacer()
            
            Button {
                buttonTapCount += 1
                transactionVM.incrementMonth()
            } label: {
                Image(systemName: "chevron.right")
                    .foregroundStyle(.eBlack)
            }
        }
        .padding(.horizontal)
        .sensoryFeedback(.selection, trigger: buttonTapCount)
    }
}

#Preview {
    MonthPickerView(transactionVM: TransactionViewModel())
}
