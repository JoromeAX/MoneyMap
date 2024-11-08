//
//  ContentView.swift
//  MoneyMap
//
//  Created by Roman Khancha on 05.11.2024.
//

import SwiftUI

struct ContentView: View {
    @Environment(\.modelContext) private var context
    @EnvironmentObject var appState: AppState
    @State private var viewModel: TransactionViewModel?

    var body: some View {
        TabView(selection: $appState.selectedTab) {
            if let viewModel = viewModel {
                TransactionListView(viewModel: viewModel)
                    .tabItem {
                        Label("Транзакции", systemImage: "list.bullet")
                    }
                    .tag(0)

                AddTransactionView(viewModel: viewModel)
                    .tabItem {
                        Label("Добавить", systemImage: "plus")
                    }
                    .tag(1)

                ReportsView(viewModel: viewModel)
                    .tabItem {
                        Label("Отчеты", systemImage: "chart.pie")
                    }
                    .tag(2)
            }
        }
        .onAppear {
            viewModel = TransactionViewModel(context: context)
            viewModel?.fetchTransactions()
        }
    }
}
