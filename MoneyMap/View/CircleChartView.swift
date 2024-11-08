//
//  CircleChartView.swift
//  MoneyMap
//
//  Created by Roman Khancha on 06.11.2024.
//

import SwiftUI
import Charts

struct CircleChartView: View {
    @ObservedObject var viewModel: TransactionViewModel
    @State private var selectedCount: Int?
    @Binding var selectedCategory: Transaction?
    var isExpense: Bool
    var selectedPeriod: Period
    var selectedDate: Date
    
    private var totalAmountForSelectedCaregoty: Int {
        viewModel.amountTransactions(for: selectedPeriod, selectedDate: selectedDate, category: selectedCategory, isExpense: isExpense)
    }
    
    private var filteredTransactions: [Transaction] {
        viewModel.filteredTransactions(for: selectedPeriod, selectedDate: selectedDate, isExpense: isExpense)
    }
    
    var body: some View {
        if filteredTransactions.isEmpty {
            Text("Здесь еще нет \(isExpense ? "расходов".localized : "доходов".localized)")
            Spacer()
        } else {
            Chart(filteredTransactions) { transaction in
                SectorMark(
                    angle: .value("Сумма", transaction.amount),
                    innerRadius: .ratio(0.65),
                    outerRadius: selectedCategory?.category.name == transaction.category.name ? 175 : 150,
                    angularInset: 1
                )
                .foregroundStyle(Color(hex: transaction.category.color))
                .cornerRadius(10)
            }
            .chartBackground { _ in
                if let selectedCategory {
                    VStack {
                        Image(systemName: "circle.fill")
                            .foregroundStyle(Color(hex: selectedCategory.category.color))
                        
                        Text(selectedCategory.category.name.localized)
                            
                        Text("\(totalAmountForSelectedCaregoty)")
                        
                    }
                }
            }
            .onChange(of: selectedCount) { oldValue, newValue in
                if let newValue {
                    withAnimation {
                        getSelectedCategory(value: newValue)
                    }
                }
            }
            .chartAngleSelection(value: $selectedCount)
            .padding()
        }
    }
    
    private func getSelectedCategory(value: Int) {
        var cumulativeTotal = 0
        _ = filteredTransactions.first { transaction in
            cumulativeTotal += transaction.amount
            if value <= cumulativeTotal {
                selectedCategory = transaction
                return true
            }
            return false
        }
    }
}
