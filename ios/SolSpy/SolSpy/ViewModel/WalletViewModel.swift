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
    @Published var showToast: Bool = false
    @Published var toastMessage: String = ""
    
    private var cancellables = Set<AnyCancellable>()
    private var walletAddress: String?
    
    init(address: String? = nil) {
        self.walletAddress = address
        loadWalletData()
    }
    
    // Загрузка данных кошелька из API
    func loadWalletData() {
        isLoading = true
        errorMessage = nil
        
        if let addr = walletAddress {
            Task {
                do {
                    let entity = try await SolSpyAPI.shared.search(address: addr)
                    switch entity {
                    case .wallet(let wallet):
                        await MainActor.run {
                            // Логирование для отладки
                            print("🏦 Wallet data received:")
                            print("  - Address: \(wallet.address)")
                            print("  - SOL Balance: \(wallet.balance.uiAmount) (\(wallet.balance.priceInfo?.totalPrice ?? 0))")
                            print("  - Assets count: \(wallet.assets.count)")
                            print("  - Total Balance: \(wallet.totalBalance)")
                            
                            self.walletData = wallet
                            self.transactions = self.mapTransactions(apiTransactions: wallet.transactions ?? [], walletAddress: wallet.address)
                            self.isLoading = false
                        }
                    default:
                        await MainActor.run {
                            self.errorMessage = "Expected wallet data, received different type."
                            self.isLoading = false
                        }
                    }
                } catch {
                    await MainActor.run {
                        self.errorMessage = error.localizedDescription
                        self.isLoading = false
                    }
                }
            }
        } else {
            // Фоллбэк на локальный мок
            loadMockData()
        }
    }
    
    // Обновление данных при pull-to-refresh
    func refreshData() {
        errorMessage = nil
        
        if let addr = walletAddress {
            Task {
                do {
                    let entity = try await SolSpyAPI.shared.search(address: addr)
                    switch entity {
                    case .wallet(let wallet):
                        await MainActor.run {
                            self.walletData = wallet
                            self.transactions = self.mapTransactions(apiTransactions: wallet.transactions ?? [], walletAddress: wallet.address)
                        }
                    default:
                        await MainActor.run {
                            self.showToast(message: "Expected wallet data, received different type")
                        }
                    }
                } catch {
                    await MainActor.run {
                        self.showToast(message: "Failed to refresh: \(error.localizedDescription)")
                    }
                }
            }
        } else {
            // Fallback к мок-данным, если нет адреса
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
                guard let self = self else { return }
                self.loadMockData(isRefreshing: true)
            }
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
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    self.walletData = try decoder.decode(WalletResponse.self, from: data)
                    self.generateMockTransactions()
                } catch {
                    self.errorMessage = "Failed to decode wallet data: \(error.localizedDescription)"
                    print("Decoding error details: \(error)")
                    if let decodingError = error as? DecodingError {
                        switch decodingError {
                        case .keyNotFound(let key, let context):
                            print("Key '\(key)' not found: \(context.debugDescription)")
                        case .typeMismatch(let type, let context):
                            print("Type '\(type)' mismatch: \(context.debugDescription)")
                        case .valueNotFound(let type, let context):
                            print("Value '\(type)' not found: \(context.debugDescription)")
                        case .dataCorrupted(let context):
                            print("Data corrupted: \(context.debugDescription)")
                        @unknown default:
                            print("Unknown decoding error: \(decodingError)")
                        }
                    }
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
        let transaction1 = Transaction(type: .transfer, amount: 0.00026, tokenSymbol: "SOL", date: now.addingTimeInterval(-2 * day), address: randomAddress, signature: "7rhx...bjnQ", isIncoming: true)
        
        let transaction2 = Transaction(type: .burn, amount: 0.00026, tokenSymbol: "SOL", date: now.addingTimeInterval(-3 * day), address: randomAddress, signature: "8xhm...cpk2")
        
        let transaction3 = Transaction(date: now.addingTimeInterval(-5 * day), address: randomAddress, signature: "9yln...dmr4", fromAmount: 6.94, fromSymbol: "JUP", toAmount: 0.00026, toSymbol: "SOL")
        
        let transaction4 = Transaction.failed(date: now.addingTimeInterval(-7 * day), address: randomAddress, signature: "3zlp...fjk8")
        
        let transaction5 = Transaction(type: .generic, amount: nil, tokenSymbol: nil, date: now.addingTimeInterval(-9 * day), address: randomAddress, signature: "4amq...ghl6")
        
        let transaction6 = Transaction(type: .transfer, amount: 0.00026, tokenSymbol: "SOL", date: now.addingTimeInterval(-11 * day), address: randomAddress, signature: "5bnr...ihj9", isIncoming: false)
        
        transactions = [transaction1, transaction2, transaction3, transaction4, transaction5, transaction6]
    }
    
    // Вспомогательные методы для отображения данных
    
    // Общий баланс кошелька
    var totalBalanceUSD: String {
        guard let data = walletData else { return "$0.00" }
        return String(format: "$%.2f", data.totalBalance)
    }
    
    // Баланс SOL
    var solBalanceFormatted: String {
        guard let data = walletData else { return "0 SOL" }
        return "\(data.balance.uiAmount.formatAsTokenAmount()) SOL"
    }
    
    // Баланс SOL в USD
    var solBalanceUSD: String {
        guard let data = walletData else { return "$0.00" }
        return (data.balance.priceInfo?.totalPrice ?? 0).formatAsCurrency()
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
        let totalPrice = data.assets.map { $0.priceInfo?.totalPrice ?? 0 }.reduce(0, +)
        return totalPrice.formatAsCurrency()
    }
    
    // Информация о стоимости токенов в USD с округлением до 2 знаков
    var tokenBalanceUSDRounded: String {
        guard let data = walletData else { return "$0.00" }
        let totalPrice = data.assets.map { $0.priceInfo?.totalPrice ?? 0 }.reduce(0, +)
        return String(format: "$%.2f", totalPrice)
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
            return "\(usdc.uiAmount.formatAsTokenAmount()) USDC (\((usdc.priceInfo?.totalPrice ?? 0).formatAsCurrency()))"
        }
        // Иначе используем заглушку
        return "View all tokens"
    }
    
    // Маска для USDC без эквивалента в USD (только количество токена)
    var usdcMaskFormattedWithoutUSD: String {
        // Проверяем, есть ли USDC в списке токенов
        if let usdc = walletData?.assets.first(where: { $0.symbol == "USDC" }) {
            // Если есть, показываем только актуальный баланс
            return "\(usdc.uiAmount.formatAsTokenAmount()) USDC"
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
        
        // Используем UniversalLinkService для копирования умной ссылки
        UniversalLinkService.shared.copyWalletLink(address: address)
        
        // Показываем уведомление
        showCopiedToast = true
        
        // Скрываем уведомление через 2 секунды
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
            self?.showCopiedToast = false
        }
    }
    
    // Функция для поделиться ссылкой
    func shareWallet() {
        showShareSheet = true
    }
    
    // Функция для получения массива элементов для ShareSheet
    func getShareItems() -> [Any] {
        guard let address = walletData?.address else { return [] }
        
        // Используем UniversalLinkService для генерации элементов шаринга
        return UniversalLinkService.shared.generateWalletShareItems(
            address: address,
            walletData: walletData
        )
    }
    
    // MARK: - Mapping API → UI transactions
    private func mapTransactions(apiTransactions: [DetailedTransaction], walletAddress: String) -> [Transaction] {
        var result: [Transaction] = []
        for dt in apiTransactions {
            let date = Date(timeIntervalSince1970: TimeInterval(dt.timestamp))
            let typeEnum: TransactionType
            
            // Определяем тип транзакции
            switch dt.type.uppercased() {
            case "TRANSFER": typeEnum = .transfer
            case "BURN": typeEnum = .burn
            case "SWAP": typeEnum = .swap
            default: typeEnum = .generic
            }
            
            // Проверка на ошибку транзакции
            let isFailed = dt.transactionError != nil
            
            // 1. Сначала проверяем токеновые трансферы
            if !dt.tokenTransfers.isEmpty {
                // Берем самый первый токеновый трансфер (обычно основной)
                let tokenTransfer = dt.tokenTransfers[0]
                
                // Определяем направление (входящая/исходящая)
                var isIncoming = false
                if let to = tokenTransfer.toUserAccount {
                    isIncoming = to == walletAddress
                }
                
                // Получаем сумму и символ токена
                let amount = tokenTransfer.amount
                let symbol = tokenTransfer.symbol ?? "Unknown"
                
                // Создаем UI транзакцию
                let tx = Transaction(
                    type: typeEnum,
                    amount: amount,
                    tokenSymbol: symbol,
                    date: date,
                    address: tokenTransfer.fromUserAccount ?? dt.feePayer,
                    signature: dt.signature,
                    isIncoming: isIncoming,
                    isFailed: isFailed
                )
                
                result.append(tx)
                continue // Переходим к следующей транзакции
            }

            // 2. Если нет токеновых, обрабатываем нативные трансферы SOL
            var isIncoming = false
            if let first = dt.nativeTransfers.first {
                isIncoming = first.toUserAccount == walletAddress
            }
            
            // Вычисляем сумму SOL из нативных трансферов
            var amount: Double? = nil
            var symbol: String? = "SOL"
            if isIncoming {
                let incomingLamports = dt.nativeTransfers
                    .filter { $0.toUserAccount == walletAddress }
                    .map { $0.amount }
                    .reduce(0, +)
                
                amount = Double(incomingLamports) / 1_000_000_000.0
            } 
            // Для исходящей - берем самый большой исходящий перевод (не учитывая комиссию)
            else if let outgoingTransfer = dt.nativeTransfers
                .filter({ $0.fromUserAccount == walletAddress && $0.toUserAccount != dt.feePayer })
                .max(by: { $0.amount < $1.amount }) {
                
                amount = Double(outgoingTransfer.amount) / 1_000_000_000.0
            }

            let tx = Transaction(
                type: typeEnum,
                amount: amount,
                tokenSymbol: symbol,
                date: date,
                address: isIncoming ? dt.feePayer : dt.nativeTransfers.first?.toUserAccount ?? "",
                signature: dt.signature,
                isIncoming: isIncoming,
                isFailed: isFailed
            )
            
            result.append(tx)
        }
        // Сортируем по дате убыванию
        return result.sorted { $0.date > $1.date }
    }
    
    // Показывает тост сообщение
    func showToast(message: String) {
        toastMessage = message
        showToast = true
        
        // Автоматически скрываем через 2 секунды
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
            self?.showToast = false
        }
    }
} 
