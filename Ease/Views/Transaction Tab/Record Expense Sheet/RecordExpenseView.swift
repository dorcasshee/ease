//
//  RecordExpenseView.swift
//  Ease
//
//  Created by Dorcas Shee on 10/12/25.
//

import SwiftUI
import SwiftData

struct RecordExpenseView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    
    @Query private var categories: [Category]
    
    @State private var categoryVM = CategoryViewModel()
    @Bindable var transactionVM: TransactionViewModel
    
    @State private var buttonTapCount: Int = 0
    @FocusState private var focusedField: FocusField?
    
    enum FocusField: Hashable {
        case amount, payee, desc
    }
    
    var body: some View {
        ScrollView {
            DismissButton()
            
            Text( transactionVM.trsnMode == .create ? "New Transaction" : "Edit Transaction")
                .font(.headline).fontWeight(.regular)
            
            TextField("$0.00", value: $transactionVM.amount, format: .currency(code: Locale.current.currency?.identifier ?? "USD"))
                .focused($focusedField, equals: .amount)
                .font(.system(size: 50, weight: .bold))
                .keyboardType(.decimalPad)
                .multilineTextAlignment(.center)
                .minimumScaleFactor(0.6)
                .padding()
            
            Picker("Select transaction type", selection: $transactionVM.transactionType) {
                ForEach(TransactionType.allCases) { type in
                    Text(type.rawValue.capitalized)
                        .tag(type)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)
            .padding(.bottom)
            .frame(width: 250)
            
            RecordExpenseBodyView(categoryVM: categoryVM, transactionVM: transactionVM, focusedField: $focusedField)
        }
        .scrollIndicators(.hidden)
        .scrollBounceBehavior(.basedOnSize)
        .padding(.top)
        .padding(.horizontal)
        .dismissKeyboardOnTap()
        .alert(transactionVM.valError?.errorTitle ?? "Error", isPresented: $transactionVM.showError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(transactionVM.valError?.errorMessage ?? "An unexpected error has occurred. Please try again.")
        }
        .onAppear {
            if transactionVM.trsnMode == .create {
                focusedField = .amount
            }
            
            if transactionVM.category == nil {
                transactionVM.selectedCategories[transactionVM.transactionType] = try? categoryVM.getDefaultCategory(for: transactionVM.transactionType, context: context)
            }
        }
        .onChange(of: transactionVM.transactionType) { _, newValue in
            if transactionVM.selectedCategories[newValue] == nil {
                transactionVM.selectedCategories[newValue] = try? categoryVM.getDefaultCategory(for: newValue, context: context)
            }
        }
        .onDisappear {
            transactionVM.resetForm()
        }
        .overlayPreferenceValue(BoundsPreferenceKey.self) { preferences in
            GeometryReader { geometry in
                if let field = focusedField, let anchor = preferences[field] {
                    autocompleteDropdown(for: field, at: geometry[anchor])
                }
            }
            .animation(.easeInOut(duration: 0.25), value: transactionVM.payeeSuggestions)
            .animation(.easeInOut(duration: 0.25), value: transactionVM.descSuggestions)
        }
        .safeAreaInset(edge: .bottom) {
            if focusedField == .amount {
                HStack {
                    Spacer()
                    
                    Button {
                        buttonTapCount += 1
                        focusedField = nil
                    } label: {
                        Image(systemName: "checkmark.circle.fill")
                            .resizable()
                            .scaledToFit()
                            .foregroundStyle(.eBlack)
                            .frame(width: 36)
                            .padding()
                    }
                }
                .sensoryFeedback(.selection, trigger: buttonTapCount)
            }
        }
    }
    
    @ViewBuilder
    private func autocompleteDropdown(for field: FocusField, at frame: CGRect) -> some View {
        let suggestions = (focusedField == .payee) ? transactionVM.payeeSuggestions :
        (focusedField == .desc) ? transactionVM.descSuggestions : []
        
        if !suggestions.isEmpty {
            VStack {
                ForEach(suggestions, id: \.self) { item in
                    Button {
                        if field == .payee {
                            transactionVM.payeeName = item
                            transactionVM.payeeSuggestions = []
                        } else if field == .desc {
                            transactionVM.desc = item
                            transactionVM.descSuggestions = []
                        }
                        
                        transactionVM.isSuggestionSelected = true
                    } label: {
                        AutocompleteRowView(text: item)
                    }
                    
                    if item != suggestions.last {
                        CustomDivider()
                            .padding(.vertical, 5)
                    }
                }
            }
            .padding()
            .background {
                RoundedRectangle(cornerRadius: 20)
                    .foregroundStyle(Color(.secondarySystemBackground))
                    .shadow(color: .eBlack.opacity(0.1), radius: 5, x: 5, y: 5)
            }
            .frame(width: frame.width + 3)
            .offset(x: frame.minX - 3, y: frame.maxY + 7)
            .transition(.asymmetric(
                insertion: .opacity.combined(with: .slide),
                removal: .opacity
            ))
        }
    }
}

struct BoundsPreferenceKey: PreferenceKey {
    typealias Value = [RecordExpenseView.FocusField: Anchor<CGRect>]
    
    static var defaultValue: Value = [:]
    
    static func reduce(value: inout Value, nextValue: () -> Value) {
        value.merge(nextValue()) { $1 }
    }
}

struct AutocompleteRowView: View {
    var text: String
    
    var body: some View {
        HStack {
            Text(text)
                .foregroundStyle(.eBlack)
                .font(.subheadline)
                .multilineTextAlignment(.leading)
            
            Spacer()
        }
    }
}

struct DismissButton: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        HStack {
            Spacer()
            
            Button {
                dismiss()
            } label: {
                Image(systemName: "x.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .symbolRenderingMode(.palette)
                    .foregroundStyle(Color(.systemGray2), Color(.secondarySystemBackground))
                    .frame(width: 32)
            }
        }
    }
}

struct RoundButtonStyle: ViewModifier {
    let font: Font
    let color: Color
    
    func body(content: Content) -> some View {
        content
            .font(font)
            .foregroundStyle(.eWhite)
            .padding(.vertical, 10)
            .padding(.horizontal)
            .background {
                Capsule()
                    .foregroundStyle(color)
            }
    }
}

extension View {
    func roundButtonStyle(font: Font = .headline, color: Color = .eBlack) -> some View {
        modifier(RoundButtonStyle(font: font, color: color))
    }
    
    func dismissKeyboardOnTap() -> some View {
        self
            .contentShape(Rectangle())
            .onTapGesture {
                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
            }
    }
}

private struct RecordExpensePreviewWrapper: View {
    @State private var transactionVM = TransactionViewModel()

    var body: some View {
        RecordExpenseView(transactionVM: transactionVM)
    }
}

#Preview {
    RecordExpensePreviewWrapper()
        .modelContainer(.preview)
}
