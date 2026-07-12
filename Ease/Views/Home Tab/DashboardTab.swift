//
//  DashboardTab.swift
//  Ease
//
//  Created by Dorcas Shee on 10/12/25.
//

import SwiftUI
import SwiftData
import Charts

struct DashboardTab: View {
    @State private var selectedCategoryID: String?
    @State private var showTransactionSheet = false
    @Bindable var transactionFormVM: TransactionFormViewModel
    var transactionListVM: TransactionListViewModel

    private var totalSpent: Double {
        transactionListVM.expenseTrsnsByCategory.reduce(0) { $0 + $1.total }
    }

    private var selectedEntry: (category: SubCategory, total: Double)? {
        guard let id = selectedCategoryID else { return nil }
        return transactionListVM.expenseTrsnsByCategory.first { $0.category.id == id }
    }
    
    // SectorMark starts at 12 o'clock and goes clockwise.
    // atan2(dx, -dy) gives a clockwise angle from the top; map that to a cumulative data value.
    private func handleChartTap(location: CGPoint, frame: CGRect) {
        let center = CGPoint(x: frame.midX, y: frame.midY)
        let dx = location.x - center.x
        let dy = location.y - center.y
        
        let outerRadius = min(frame.width, frame.height) / 2
        let innerRadius = outerRadius * 0.6
        let distance = sqrt(dx * dx + dy * dy)
        guard distance >= innerRadius && distance <= outerRadius else {
            selectedCategoryID = nil
            return
        }
        
        let angle = atan2(dx, -dy)
        let normalizedAngle = (angle + 2 * .pi).truncatingRemainder(dividingBy: 2 * .pi)
        let targetValue = (normalizedAngle / (2 * .pi)) * totalSpent
        
        var cumulative = 0.0
        for item in transactionListVM.expenseTrsnsByCategory {
            cumulative += item.total
            if targetValue <= cumulative {
                selectedCategoryID = selectedCategoryID == item.category.id ? nil : item.category.id
                return
            }
        }
    }
    
    var body: some View {
        VStack {
            MonthPickerView(transactionListVM: transactionListVM)
                .padding(.bottom)
            if !transactionListVM.expenseTrsnsByCategory.isEmpty {
                ScrollView {
                    VStack {
                        VStack(alignment: .leading) {
                            HStack {
                                Text("Expenses By Category")
                                    .font(.title)
                                    .fontWeight(.bold)
                                
                                Spacer()
                            }
                            .padding(.top, 10)
                            
                            Text("Top category spent: \(transactionListVM.expenseTrsnsByCategory.first!.category.name), $\(String(format: "%.2f", transactionListVM.expenseTrsnsByCategory.first!.total))")
                                .font(.headline)
                                .fontWeight(.light)
                                .italic()
                        }
                        .padding(.bottom)
                        
                        Chart(transactionListVM.expenseTrsnsByCategory, id: \.category.id) { trsn in
                            SectorMark(angle: .value(trsn.category.name, trsn.total),
                                       innerRadius: .ratio(0.6),
                                       angularInset: 2)
                            .cornerRadius(10)
                            .foregroundStyle(Color(trsn.category.colorName))
                            .opacity(selectedCategoryID == nil || selectedCategoryID == trsn.category.id ? 1.0 : 0.6)
                        }
                        .scaledToFit()
                        .sensoryFeedback(.impact(flexibility: .soft), trigger: selectedCategoryID)
                        .chartLegend(.hidden)
                        .chartBackground { chartProxy in
                            GeometryReader { geo in
                                if let anchor = chartProxy.plotFrame {
                                    let frame = geo[anchor]
                                    PieChartTitleView(
                                        isSystemIcon: selectedEntry?.category.isSystemIcon ?? true,
                                        iconName: selectedEntry?.category.iconName ?? "dollarsign",
                                        label: selectedEntry?.category.name ?? "Total Spent",
                                        amount: selectedEntry?.total ?? totalSpent
                                    )
                                    .position(x: frame.midX, y: frame.midY)
                                }
                            }
                        }
                        .chartOverlay { proxy in
                            GeometryReader { geo in
                                if let anchor = proxy.plotFrame {
                                    let frame = geo[anchor]
                                    Color.clear
                                        .contentShape(Rectangle())
                                        .onTapGesture { location in
                                            handleChartTap(location: location, frame: frame)
                                        }
                                }
                            }
                        }
                    }
                    .padding(.bottom, 30)
                    
                    Top5ExpenseTransactionsView(trsns: transactionListVM.getTopXExpensesForThisMonth(x: 5),
                                                transactionFormVM: transactionFormVM,
                                                showSheet: $showTransactionSheet)
                    
                    Spacer()
                }
            } else {
                ContentUnavailableView("No Transactions",
                                       systemImage: "tray",
                                       description: Text("Start tracking your expenses by tapping the + button in the Transaction Tab."))
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .padding()
        .padding(.horizontal, 10)
        .scrollContentBackground(.hidden)
        .scrollIndicators(.hidden)
        .sheet(isPresented: $showTransactionSheet) {
            RecordExpenseView(transactionFormVM: transactionFormVM)
        }
    }
}

struct PieChartTitleView: View {
    var isSystemIcon: Bool
    var iconName: String
    var label: String
    var amount: Double

    var body: some View {
        VStack(spacing: 4) {
            Group {
                if isSystemIcon {
                    Image(systemName: iconName)
                        .resizable()
                        .scaledToFit()
                } else {
                    Image(iconName)
                        .resizable()
                        .scaledToFit()
                        
                }
            }
            .frame(width: 50, height: 50)
            .foregroundStyle(.eBlack)
            
            Text(label)
                .font(.title3)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)

            Text(amount.formatted(.currency(code: "SGD")))
                .font(.headline)
                .fontWeight(.regular)
                .foregroundStyle(.secondary)
        }
    }
}

struct Top5ExpenseTransactionsView: View {
    var trsns: [Transaction]
    @Bindable var transactionFormVM: TransactionFormViewModel
    @Binding var showSheet: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Top 5 Expense Transactions")
                .font(.title2)
                .fontWeight(.bold)

            ForEach(trsns) { trsn in
                Button {
                    transactionFormVM.loadTransactionForEditing(trsn)
                    showSheet = true
                } label: {
                    HStack(alignment: .center) {
                        Group {
                            if trsn.category.isSystemIcon {
                                Image(systemName: trsn.category.iconName)
                                    .font(.system(size: 24))
                            } else {
                                Image(trsn.category.iconName)
                                    .resizable()
                                    .scaledToFit()
                                
                            }
                        }
                        .frame(width: 30, height: 30)
                        .foregroundStyle(Color(trsn.category.colorName))
                        
                        VStack(alignment: .leading, spacing: 0) {
                            Text(trsn.desc ?? trsn.category.name)
                                .multilineTextAlignment(.leading)
                                .lineLimit(2)
                                .font(.headline)
                                .fontWeight(.regular)
                            
                            if let payeeName = trsn.payee?.name {
                                Text(payeeName)
                                    .font(.callout)
                                    .foregroundStyle(.secondary)
                                    .italic()
                            }
                        }
                        
                        Spacer()
                        
                        Text(trsn.formattedAmount)
                            .font(.headline)
                            .fontWeight(.regular)
                    }
                    .padding(.vertical)
                }
                
                Divider()
            }
        }
    }
}

#Preview {
    DashboardTab(transactionFormVM: TransactionFormViewModel(), transactionListVM: TransactionListViewModel())
        .modelContainer(.preview)
}
