//
//  TransactionListView.swift
//  MoneyMap
//
//  Created by Roman Khancha on 05.11.2024.
//

import SwiftUI

struct TransactionListView: View {
    @Environment(\.modelContext) private var context
    @StateObject var viewModel: TransactionViewModel
    
    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    Text("Общий баланс")
                    Text("\(viewModel.totalBalance)")
                        .foregroundColor(viewModel.totalBalance >= 0 ? .green : .red)
                }
                .font(.title2)
                .padding()
                
                List {
                    let groupedTransactions = Dictionary(grouping: viewModel.transactions) { transaction in
                        Calendar.current.startOfDay(for: transaction.date)
                    }
                    
                    ForEach(groupedTransactions.keys.sorted(by: >), id: \.self) { date in
                        Section(header: Text(date, style: .date)) {
                            ForEach(groupedTransactions[date] ?? []) { transaction in
                                HStack {
                                    VStack(alignment: .leading) {
                                        HStack {
                                            Text(transaction.category.name.localized)
                                                .font(.headline)
                                            
                                            Image(systemName: "circle.fill")
                                                .foregroundStyle(Color(hex: transaction.category.color))
                                        }
                                        
                                        if let note = transaction.note {
                                            if note != "" {
                                                Text(note)
                                                    .font(.subheadline)
                                                    .foregroundStyle(.gray)
                                            }
                                        }
                                    }
                                    
                                    Spacer()
                                    
                                    Text("\(transaction.amount)")
                                        .foregroundColor(transaction.category.type == .expense ? .red : .green)
                                }
                            }
                            .onDelete { indexSet in
                                let transactionsForDate = groupedTransactions[date] ?? []
                                indexSet.forEach { index in
                                    let transaction = transactionsForDate[index]
                                    viewModel.deleteTransaction(transaction)
                                }
                            }
                        }
                    }
                }
                .clipShape(RoundedRectangle(cornerRadius: 15))
                .navigationTitle("Транзакции")
            }
        }
        .onAppear {
            viewModel.fetchTransactions()
        }
    }
}
