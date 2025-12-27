//
//  MonthPickerView.swift
//  Ease
//
//  Created by Dorcas Shee on 27/12/25.
//

import SwiftUI

struct MonthPickerView: View {
    var transactionVM: TransactionViewModel
    
    var body: some View {
        HStack {
            Button {
                transactionVM.decrementMonth()
            } label: {
                Image(systemName: "chevron.left")
                    .foregroundStyle(.eBlack)
            }
            
            Spacer()
            
            Text(transactionVM.currentDate, format: .dateTime.month(.wide).year())
                .blackButtonStyle(font: .title3.weight(.bold))
            
            Spacer()
            
            Button {
                transactionVM.incrementMonth()
            } label: {
                Image(systemName: "chevron.right")
                    .foregroundStyle(.eBlack)
            }
        }
        .padding(.horizontal)
    }
}

#Preview {
    MonthPickerView(transactionVM: TransactionViewModel())
}
