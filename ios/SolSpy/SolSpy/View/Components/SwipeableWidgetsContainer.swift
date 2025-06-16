import SwiftUI

struct SwipeableWidgetsContainer: View {
    // Данные для транзакций
    let transactions: [LatestTransaction]
    let isTransactionsLoading: Bool
    let webSocketStatus: String
    let isWebSocketConnected: Bool
    
    // Данные для токенов
    let tokens: [TopToken]
    let isTokensLoading: Bool
    
    @EnvironmentObject private var coordinator: NavigationCoordinator
    @State private var selectedTab = 0
    
    var body: some View {
        VStack(spacing: 12) {
            // Контейнер с фиксированной высотой для свайпера
            TabView(selection: $selectedTab) {
                // Страница 1: Latest Transactions
                LatestTransactionsWidget(
                    transactions: transactions,
                    isLoading: isTransactionsLoading,
                    webSocketStatus: webSocketStatus,
                    isWebSocketConnected: isWebSocketConnected
                )
                .environmentObject(coordinator)
                .padding(.horizontal, 0) // Убираем padding, так как он уже есть внутри виджета
                .tag(0)
                
                // Страница 2: Top Tokens
                TopTokensWidget(
                    tokens: tokens,
                    isLoading: isTokensLoading
                )
                .environmentObject(coordinator)
                .padding(.horizontal, 0) // Убираем padding, так как он уже есть внутри виджета
                .tag(1)
            }
            .tabViewStyle(.page(indexDisplayMode: .never)) // Убираем встроенный индикатор
            .frame(height: 250) // Фиксированная высота контейнера
            
            // Кастомный индикатор страниц
            HStack(spacing: 8) {
                ForEach(0..<2, id: \.self) { index in
                    Circle()
                        .fill(selectedTab == index ? 
                              Color(red: 0.247, green: 0.918, blue: 0.286) : 
                              Color.white.opacity(0.3))
                        .frame(width: 8, height: 8)
                        .animation(.easeInOut(duration: 0.2), value: selectedTab)
                }
            }
        }
    }
    

}

#Preview {
    SwipeableWidgetsContainer(
        transactions: MockTransactionsProvider.generateMockTransactions(),
        isTransactionsLoading: false,
        webSocketStatus: "Live",
        isWebSocketConnected: true,
        tokens: TopToken.mockTokens,
        isTokensLoading: false
    )
    .environmentObject(NavigationCoordinator())
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color(red: 0.027, green: 0.035, blue: 0.039))
} 