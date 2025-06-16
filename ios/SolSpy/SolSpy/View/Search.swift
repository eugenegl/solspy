//
//  Search.swift
//  SolSpy
//
//  Created by Евгений Голота on 28.04.2025.
//

import SwiftUI

struct Search: View {
    @State private var isShowing: Bool = false
    @State private var searchText: String = ""
    @State private var isSearching: Bool = false
    @StateObject private var homeViewModel = HomeViewModel()
    // Координатор навигации приходит из родительского NavigationStack
    @EnvironmentObject private var coordinator: NavigationCoordinator
    var background: Color = Color(red: 0.027, green: 0.035, blue: 0.039)
    
    var body: some View {
        ZStack {
            
            // Основной фон
            background.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Верхний контент в ScrollView
                ScrollView {
                    VStack(spacing: 20) {
                        
                        Text("solspy")
                            .font(.system(size: 22, weight: .regular))
                            .foregroundStyle(Color(red: 0.247, green: 0.918, blue: 0.286))
                            .padding(.top, 10)
                        
                        // SOL Price Widget
                        SOLPriceWidget(
                            priceData: homeViewModel.solPrice,
                            isLoading: homeViewModel.isPriceLoading
                        )
                        
                        // MEV Bot Tracker Widget
                        MEVBotTrackerWidget()
                            .environmentObject(coordinator)
                            .environmentObject(homeViewModel)
                        
                        // Swipeable Widgets Container (Latest Transactions + Top Tokens)
                        SwipeableWidgetsContainer(
                            transactions: homeViewModel.latestTransactions,
                            isTransactionsLoading: homeViewModel.isTransactionsLoading,
                            webSocketStatus: homeViewModel.webSocketStatusText,
                            isWebSocketConnected: homeViewModel.isWebSocketConnected,
                            tokens: homeViewModel.topTokens,
                            isTokensLoading: homeViewModel.isTopTokensLoading
                        )
                        .environmentObject(coordinator)
                        
                        // Дополнительное пространство внизу для поисковой строки
                        Spacer(minLength: 80)
                    }
                }
                .refreshable {
                    await homeViewModel.refreshAll()
                }
                
                // Поисковая строка и кнопка в HStack, зафиксированы внизу
                HStack(spacing: 12) {
                    // Строка поиска (модифицированная версия SearchInputView)
                    HStack(spacing: 12) {
                        
                        // Поле вводаи
                        TextField("", text: $searchText)
                            .placeholder(when: searchText.isEmpty) {
                                Text("Search")
                                    .font(.system(size: 15, weight: .regular))
                                    .foregroundStyle(.white.opacity(0.4))
                            }
                            .font(.system(size: 15, weight: .regular))
                            .foregroundStyle(.white)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()
                        
                        // Кнопка очистки
                        if !searchText.isEmpty {
                            Button(action: {
                                searchText = ""
                            }) {
                                Image(systemName: "xmark.circle.fill")
                                    .font(.system(size: 16))
                                    .foregroundStyle(.white.opacity(0.5))
                            }
                        }
                        
                        // Кнопка вставки
                        Button(action: pasteFromClipboard) {
                            Text("Paste")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundStyle(Color(red: 0.247, green: 0.918, blue: 0.286))
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(
                                    RoundedRectangle(cornerRadius: 6)
                                        .fill(Color(red: 0.247, green: 0.918, blue: 0.286).opacity(0.15))
                                )
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 20)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.black.opacity(0.4))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(
                                        searchText.isEmpty ? 
                                        Color.white.opacity(0.1) : 
                                        Color(red: 0.247, green: 0.918, blue: 0.286).opacity(0.5),
                                        lineWidth: 1
                                    )
                            )
                    )
                    
                    // Кнопка поиска
                    Button(action: {
                        performSearch()
                    }) {
                        HStack {
                            if isSearching {
                                LoadingView()
                                    .scaleEffect(0.7)
                            } else {
                                Image(systemName: "magnifyingglass")
                                    .font(.system(size: 20, weight: .regular))
                                    .foregroundStyle(.black)
                            }
                        }
                        .frame(width: 60, height: 60)
                        .background(Color(red: 0.247, green: 0.918, blue: 0.286))
                        .cornerRadius(12)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 30)
                .background(
                    // Градиент для плавного перехода
                    LinearGradient(
                        colors: [
                            background.opacity(0),
                            background.opacity(0.8),
                            background
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .frame(height: 100)
                )
            }
        }
    }
    
    // Функция для вставки текста из буфера обмена
    private func pasteFromClipboard() {
        if let string = UIPasteboard.general.string {
            searchText = string
        }
    }
    
    // Функция для выполнения поиска
    private func performSearch() {
        guard !searchText.isEmpty else { return }
        
        isSearching = true
        Task {
            do {
                let entity = try await SolSpyAPI.shared.search(address: searchText)
                // Прячем индикатор
                isSearching = false

                switch entity {
                case .wallet(let wallet):
                    coordinator.showWallet(address: wallet.address)
                case .token(let token):
                    coordinator.showToken(address: token.address)
                case .transaction(let tx):
                    coordinator.showTransaction(signature: tx.transaction.signature)
                }
                // Очищаем поле ввода
                searchText = ""
            } catch {
                // В случае ошибки просто убираем индикатор
                isSearching = false
                // Можно добавить алерт/текст ошибки
                print("Search error: \(error.localizedDescription)")
            }
        }
    }
}

#Preview {
    Search()
        .environmentObject(NavigationCoordinator())
}
