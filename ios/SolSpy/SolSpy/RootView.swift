import SwiftUI

struct RootView: View {
    @StateObject private var coordinator = NavigationCoordinator()

    var body: some View {
        NavigationStack(path: $coordinator.path) {
            // Стартовый экран с анимацией сплеша
            ContentView()
                .environmentObject(coordinator)
                // Декларируем маршруты.
                .navigationDestination(for: AppRoute.self) { route in
                    switch route {
                    case .wallet(let address):
                        Wallet(address: address)
                            .environmentObject(coordinator)
                            .navigationBarBackButtonHidden(true)
                    case .token(let address):
                        Token(address: address)
                            .environmentObject(coordinator)
                            .navigationBarBackButtonHidden(true)
                    case .transaction(let signature):
                        TransactionDetails(transactionSignature: signature)
                            .environmentObject(coordinator)
                            .navigationBarBackButtonHidden(true)
                    }
                }
        }
        .navigationViewStyle(.stack) // iOS 15 совместимость
    }
}

#Preview {
    RootView()
        .preferredColorScheme(.dark)
} 