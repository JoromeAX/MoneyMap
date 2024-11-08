//
//  ReportsView.swift
//  MoneyMap
//
//  Created by Roman Khancha on 05.11.2024.
//

import SwiftUI

struct ReportsView: View {
    @Environment(\.modelContext) private var context
    @StateObject var viewModel: TransactionViewModel
    @State private var isExpense = true
    @State private var selectedPeriod: Period = .day
    @State private var selectedDate: Date = Date()
    @State private var selectedCategory: Transaction?
    
    var body: some View {
        if viewModel.transactions.isEmpty {
            Text("Здесь еще нет транзакций")
                .padding()
        } else {
            VStack {
                VStack {
                    Section("Тип транзакции") {
                        Picker("Тип транзакции", selection: $isExpense) {
                            Text("Расход").tag(true)
                            Text("Доход").tag(false)
                        }
                        .pickerStyle(SegmentedPickerStyle())
                    }
                    
                    Section("Период") {
                        VStack(spacing: 20) {
                            Picker("Период", selection: $selectedPeriod) {
                                ForEach(Period.allCases, id: \.self) { period in
                                    Text(period.localized).tag(period)
                                }
                            }
                            .pickerStyle(SegmentedPickerStyle())
                            
                            HStack {
                                Button {
                                    shiftDate(by: -1)
                                } label: {
                                    Image(systemName: "chevron.left")
                                }
                                
                                Text(periodText(for: selectedPeriod))
                                
                                Button {
                                    shiftDate(by: 1)
                                } label: {
                                    Image(systemName: "chevron.right")
                                }
                            }
                        }
                    }
                }
                .padding()
                .padding(.top, 50)
                
                Section("Отчеты и аналитика") {
                    CircleChartView(viewModel: viewModel, selectedCategory: $selectedCategory, isExpense: isExpense, selectedPeriod: selectedPeriod, selectedDate: selectedDate)
                        .padding()
                }                
            }
            .onChange(of: selectedPeriod) {
                viewModel.filterTransactions(by: selectedPeriod)
            }
            .onChange(of: isExpense) {
                selectedCategory = nil
            }
        }
    }
    
    private func periodText(for period: Period) -> String {
        let dateFormatter: DateFormatter = {
            let formatter = DateFormatter()
            
            switch selectedPeriod {
            case .day:
                formatter.dateFormat = "d MMM"
            case .week:
                formatter.dateFormat = "d MMM"
            case .month:
                formatter.dateFormat = "MMMM"
            case .year:
                formatter.dateFormat = "YYYY"
            }
            return formatter
        }()
        
        switch period {
        case .day:
            return dateFormatter.string(from: selectedDate)
        case .week:
            let startOfWeek = Calendar.current.date(from: Calendar.current.dateComponents([.yearForWeekOfYear, .weekOfYear], from: selectedDate))!
            let endOfWeek = Calendar.current.date(byAdding: .day, value: 6, to: startOfWeek)!
            return "\(dateFormatter.string(from: startOfWeek)) - \(dateFormatter.string(from: endOfWeek))"
        case .month, .year:
            return dateFormatter.string(from: selectedDate)
        }
    }
    
    private func shiftDate(by offset: Int) {
        selectedCategory = nil
        
        let calendar = Calendar.current
        switch selectedPeriod {
        case .day:
            selectedDate = calendar.date(byAdding: .day, value: offset, to: selectedDate) ?? selectedDate
        case .week:
            selectedDate = calendar.date(byAdding: .weekOfYear, value: offset, to: selectedDate) ?? selectedDate
        case .month:
            selectedDate = calendar.date(byAdding: .month, value: offset, to: selectedDate) ?? selectedDate
        case .year:
            selectedDate = calendar.date(byAdding: .year, value: offset, to: selectedDate) ?? selectedDate
        }
    }
}
