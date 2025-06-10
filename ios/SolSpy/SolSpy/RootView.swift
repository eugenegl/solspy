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
        .onReceive(NotificationCenter.default.publisher(for: .handleUniversalLink)) { notification in
            if let url = notification.object as? URL {
                handleIncomingURL(url)
            }
        }
    }
    
    // Обработка входящих Universal Links и Deep Links
    private func handleIncomingURL(_ url: URL) {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: true) else { return }
        
        // Обработка solspy:// схемы
        if url.scheme == "solspy" {
            handleDeepLink(url)
        }
        // Обработка Universal Links https://solspy.app/
        else if url.host == "solspy.app" {
            handleUniversalLink(url)
        }
    }
    
    private func handleDeepLink(_ url: URL) {
        let path = url.path.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
        let components = path.components(separatedBy: "/")
        
        guard components.count >= 2 else { return }
        
        switch components[0] {
        case "wallet":
            coordinator.navigateToWallet(address: components[1])
        case "token":
            coordinator.navigateToToken(address: components[1])
        case "transaction", "tx":
            coordinator.navigateToTransaction(signature: components[1])
        default:
            break
        }
    }
    
    private func handleUniversalLink(_ url: URL) {
        let path = url.path.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
        let components = path.components(separatedBy: "/")
        
        guard components.count >= 2 else { return }
        
        switch components[0] {
        case "wallet":
            coordinator.navigateToWallet(address: components[1])
        case "token":
            coordinator.navigateToToken(address: components[1])
        case "tx", "transaction":
            coordinator.navigateToTransaction(signature: components[1])
        default:
            break
        }
    }
}

// Notification для Universal Links
extension Notification.Name {
    static let handleUniversalLink = Notification.Name("handleUniversalLink")
}

#Preview {
    RootView()
        .preferredColorScheme(.dark)
} 