import SwiftUI

// Enum, описывающий возможные маршруты внутри приложения.
// Каждый кейс содержит необходимые данные для последующего экрана.
enum AppRoute: Hashable {
    case wallet(address: String)
    case token(address: String)
    case transaction(signature: String)
}

// ObservableObject-координатор хранит NavigationPath и предоставляет
// методы для навигации между экранами.
final class NavigationCoordinator: ObservableObject {
    // Путь навигации. Привязываем его к NavigationStack.
    @Published var path = NavigationPath()

    // MARK: - Public navigation helpers
    func showWallet(address: String) {
        path.append(AppRoute.wallet(address: address))
    }

    func showToken(address: String) {
        path.append(AppRoute.token(address: address))
    }

    func showTransaction(signature: String) {
        path.append(AppRoute.transaction(signature: signature))
    }

    func pop() {
        guard !path.isEmpty else { return }
        path.removeLast()
    }

    func popToRoot() {
        path.removeLast(path.count)
    }
    
    // MARK: - Universal Links navigation methods
    func navigateToWallet(address: String) {
        // Сначала сбрасываем до root, затем переходим к нужному экрану
        popToRoot()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.showWallet(address: address)
        }
    }
    
    func navigateToToken(address: String) {
        popToRoot()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.showToken(address: address)
        }
    }
    
    func navigateToTransaction(signature: String) {
        popToRoot()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.showTransaction(signature: signature)
        }
    }
} 