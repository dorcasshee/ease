//
//  DateRowView.swift
//  Ease
//
//  Created by Dorcas Shee on 9/1/26.
//

import SwiftUI

struct DateRowView: View {
    @Bindable var transactionVM: TransactionViewModel
    
    var body: some View {
        HStack {
            Image(systemName: "calendar")
            
            ZStack(alignment: .leading) {
                DatePicker("", selection: $transactionVM.date, displayedComponents: .date)
                    .labelsHidden()
                    .blendMode(.destinationOver)
                
                Text(transactionVM.date.formatRelativeDate())
                    .font(.title3)
                    .allowsHitTesting(false)
            }
            
            Spacer()
            
            Button {
                transactionVM.decrementDate()
            } label: {
                Image(systemName: "chevron.left")
                    .foregroundStyle(.eBlack)
            }
            .padding(.trailing)
            .sensoryFeedback(.selection, trigger: transactionVM.date)
            
            Button {
                transactionVM.incrementDate()
            } label: {
                Image(systemName: "chevron.right")
                    .foregroundStyle(.eBlack)
            }
        }
    }
}

#Preview {
    DateRowView(transactionVM: TransactionViewModel())
}
