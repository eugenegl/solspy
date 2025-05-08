import Foundation
import SwiftUI
import Combine

class WalletViewModel: ObservableObject {
    @Published var walletData: WalletResponse?
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var transactions: [Transaction] = [] // Пример транзакций
    
    // Новые свойства для уведомлений
    @Published var showShareSheet = false
    @Published var showCopiedToast = false
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        // Загрузить данные при инициализации
        loadWalletData()
    }
    
    // Загрузка данных кошелька из API
    func loadWalletData() {
        isLoading = true
        errorMessage = nil
        
        // В реальном приложении здесь был бы сетевой запрос к API
        // Для демонстрации загрузим тестовые данные
        loadMockData()
    }
    
    // Обновление данных при pull-to-refresh
    func refreshData() {
        // В реальном приложении здесь был бы повторный запрос к API
        // Для демонстрации просто перезагрузим тестовые данные с небольшой задержкой
        // Не показываем индикатор загрузки на весь экран при обновлении
        errorMessage = nil
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
            guard let self = self else { return }
            
            self.loadMockData(isRefreshing: true)
        }
    }
    
    // Загрузка тестовых данных из локального JSON-файла
    private func loadMockData(isRefreshing: Bool = false) {
        // Имитация задержки сети (короче при refreshing)
        let delay: TimeInterval = isRefreshing ? 0.3 : 0.5
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) { [weak self] in
            guard let self = self else { return }
            
            // Создаем тестовые данные
            let jsonData = self.loadMockJSONData()
            if let data = jsonData {
                do {
                    let decoder = JSONDecoder()
                    self.walletData = try decoder.decode(WalletResponse.self, from: data)
                    self.generateMockTransactions()
                } catch {
                    self.errorMessage = "Failed to decode wallet data: \(error.localizedDescription)"
                }
            }
            
            self.isLoading = false
        }
    }
    
    // Генерация тестовых данных JSON (как в примере Wallet.json)
    private func loadMockJSONData() -> Data? {
        let jsonString = """
        {
            "address": "9Xt9Zj9HoAh13MpoB6hmY9UZz37L4Jabtyn8zE7AAsL",
            "type": "WALLET",
            "balance": {
                "address": "So11111111111111111111111111111111111111112",
                "amount": 4763081,
                "uiAmount": 0.004763081,
                "decimals": 9,
                "symbol": "SOL",
                "name": "Solana",
                "logo": "https://light.dangervalley.com/static/sol.png",
                "priceInfo": {
                    "pricePerToken": 148.17837524414062,
                    "totalPrice": 0.7057856037362366
                }
            },
            "assets": [
                {
                    "address": "Es9vMFrzaCERmJfrF4H2FYD4KCoNkY11McCe8BenwNYB",
                    "amount": 3783,
                    "uiAmount": 0.003783,
                    "decimals": 6,
                    "symbol": "USDT",
                    "name": "USDT",
                    "supply": 2389929355.404684,
                    "priceInfo": {
                        "pricePerToken": 1.000294,
                        "totalPrice": 0.003784
                    }
                },
                {
                    "address": "Em9zr2tgSmGgRbz3kxyQeRXjRi9oc13wMu6cKam4zWFW",
                    "amount": 74500000,
                    "uiAmount": 74.5,
                    "decimals": 6,
                    "symbol": "NAMI",
                    "name": "Thief Cat",
                    "supply": 951351677.604807,
                    "priceInfo": {
                        "pricePerToken": 0.0000291888,
                        "totalPrice": 0.002175
                    }
                },
                {
                    "address": "SoLiDMWBct5TurG1LNcocemBK7QmTn4P33GSrRrcd2n",
                    "amount": 1500000,
                    "uiAmount": 0.0015,
                    "decimals": 9,
                    "symbol": "SOLID",
                    "name": "Solana ID",
                    "description": "Solana ID is your key to enter an infinite world of personal perks on-chain.",
                    "logo": "https://arweave.net/DoW2h0aZyuFn-riGH_2LwXl-CX9qEnPbV3pKpA6nGsg",
                    "supply": 999996445.4037399,
                    "priceInfo": {
                        "pricePerToken": 0.002971314,
                        "totalPrice": 0.000004
                    }
                },
                {
                    "address": "EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v",
                    "amount": 1,
                    "uiAmount": 0.000001,
                    "decimals": 6,
                    "symbol": "USDC",
                    "name": "USD Coin",
                    "logo": "https://raw.githubusercontent.com/solana-labs/token-list/main/assets/mainnet/EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v/logo.png",
                    "supply": 10457952163.141838,
                    "priceInfo": {
                        "pricePerToken": 1.000015,
                        "totalPrice": 0.000001
                    }
                }
            ]
        }
        """
        
        return jsonString.data(using: .utf8)
    }
    
    // Генерация примеров транзакций для демонстрации
    private func generateMockTransactions() {
        let now = Date()
        let day: TimeInterval = 86400 // 24 часа
        let randomAddress = "5KV9Z32iNZoDLSzBg8xzBB7JkvKUgvjSyhn"
        
        // Пример транзакций разных типов
        let transaction1 = Transaction(type: .transfer, amount: 0.00026, tokenSymbol: "SOL", date: now.addingTimeInterval(-2 * day), address: randomAddress, isIncoming: true)
        
        let transaction2 = Transaction(type: .burn, amount: 0.00026, tokenSymbol: "SOL", date: now.addingTimeInterval(-3 * day), address: randomAddress)
        
        let transaction3 = Transaction(date: now.addingTimeInterval(-5 * day), address: randomAddress, fromAmount: 6.94, fromSymbol: "JUP", toAmount: 0.00026, toSymbol: "SOL")
        
        let transaction4 = Transaction.failed(date: now.addingTimeInterval(-7 * day), address: randomAddress)
        
        let transaction5 = Transaction(type: .generic, amount: nil, tokenSymbol: nil, date: now.addingTimeInterval(-9 * day), address: randomAddress)
        
        let transaction6 = Transaction(type: .transfer, amount: 0.00026, tokenSymbol: "SOL", date: now.addingTimeInterval(-11 * day), address: randomAddress, isIncoming: false)
        
        transactions = [transaction1, transaction2, transaction3, transaction4, transaction5, transaction6]
    }
    
    // Вспомогательные методы для отображения данных
    
    // Общий баланс кошелька
    var totalBalanceUSD: String {
        guard let data = walletData else { return "$0.00" }
        return data.totalBalance.formatAsCurrency()
    }
    
    // Баланс SOL
    var solBalanceFormatted: String {
        guard let data = walletData else { return "0 SOL" }
        return "\(data.balance.uiAmount.formatAsTokenAmount()) SOL"
    }
    
    // Баланс SOL в USD
    var solBalanceUSD: String {
        guard let data = walletData else { return "$0.00" }
        return data.balance.priceInfo.totalPrice.formatAsCurrency()
    }
    
    // Количество токенов
    var tokenCountFormatted: String {
        guard let data = walletData else { return "0 Tokens" }
        let tokenCount = data.assets.count
        // Если 1 токен, то "Token", иначе "Tokens"
        let tokenWord = tokenCount == 1 ? "Token" : "Tokens"
        return "\(tokenCount) \(tokenWord)"
    }
    
    // Информация о стоимости токенов в USD
    var tokenBalanceUSD: String {
        guard let data = walletData else { return "$0.00" }
        let totalPrice = data.assets.map(\.priceInfo.totalPrice).reduce(0, +)
        return totalPrice.formatAsCurrency()
    }
    
    // Короткий формат адреса
    var walletAddressShort: String {
        return walletData?.shortAddress ?? "Unknown"
    }
    
    // Полный адрес кошелька
    var walletAddressFull: String {
        return walletData?.address ?? "Unknown"
    }
    
    // Проверка на пустой баланс
    var isEmptyBalance: Bool {
        guard let data = walletData else { return true }
        return data.totalBalance <= 0.0001 // С учетом погрешности для малых значений
    }
    
    // Маска для примера USDC в UI элементе
    var usdcMaskFormatted: String {
        // Проверяем, есть ли USDC в списке токенов
        if let usdc = walletData?.assets.first(where: { $0.symbol == "USDC" }) {
            // Если есть, показываем актуальный баланс и эквивалент в USD
            return "\(usdc.uiAmount.formatAsTokenAmount()) USDC (\(usdc.priceInfo.totalPrice.formatAsCurrency()))"
        }
        // Иначе используем заглушку
        return "View all tokens"
    }
    
    // Получение URL логотипа токена по его символу
    func getTokenLogo(symbol: String) -> String {
        // Сначала проверяем SOL
        if symbol == "SOL" && walletData?.balance.symbol == "SOL" {
            return walletData?.balance.logo ?? ""
        }
        
        // Затем ищем в других токенах
        if let token = walletData?.assets.first(where: { $0.symbol == symbol }) {
            return token.logo ?? ""
        }
        
        // Если не нашли, возвращаем пустую строку
        return ""
    }
    
    // Функция возврата на предыдущий экран
    func goBack() {
        // В реальном приложении здесь будет логика навигации
        print("Navigating back")
    }
    
    // Функция для копирования ссылки
    func copyWalletLink() {
        guard let address = walletData?.address else { return }
        
        // Формируем ссылку на кошелек
        let link = "solspy://wallet/\(address)"
        
        // Копируем в буфер обмена
        UIPasteboard.general.string = link
        
        // Показываем уведомление
        showCopiedToast = true
        
        // Скрываем уведомление через 2 секунды
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
            self?.showCopiedToast = false
        }
    }
    
    // Функция для генерации ссылки на App Store
    func getAppStoreLink() -> URL? {
        // В реальном приложении здесь должен быть реальный ID приложения
        let appStoreId = "123456789"
        let appStoreURL = URL(string: "https://apps.apple.com/app/id\(appStoreId)")
        return appStoreURL
    }
    
    // Функция для генерации Universal Link или Deep Link
    func getDeepLink() -> URL? {
        guard let address = walletData?.address else { return nil }
        
        // Формирование Universal Link (в реальном приложении должен быть настроен домен)
        // например, https://solspy.app/wallet/адрес_кошелька
        let universalLink = URL(string: "https://solspy.app/wallet/\(address)")
        return universalLink
    }
    
    // Функция для поделиться ссылкой
    func shareWallet() {
        showShareSheet = true
    }
    
    // Функция для получения массива элементов для ShareSheet
    func getShareItems() -> [Any] {
        var items: [Any] = []
        
        // Добавляем текстовое описание
        let walletTitle = "Кошелек Solana"
        items.append(walletTitle)
        
        // Добавляем сам адрес кошелька
        if let address = walletData?.address {
            items.append("Адрес: \(address)")
        }
        
        // Добавляем Deep Link или Universal Link если есть
        if let deepLink = getDeepLink() {
            items.append(deepLink)
        }
        
        return items
    }
} 
