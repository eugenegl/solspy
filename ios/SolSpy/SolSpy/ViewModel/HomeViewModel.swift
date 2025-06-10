import Foundation
import Combine

@MainActor
class HomeViewModel: ObservableObject {
    @Published var solPrice: SOLPriceDisplay?
    @Published var latestTransactions: [LatestTransaction] = []
    @Published var topTokens: [TopToken] = []
    @Published var isPriceLoading: Bool = false
    @Published var isTransactionsLoading: Bool = false
    @Published var isTopTokensLoading: Bool = false
    @Published var webSocketState: WebSocketState = .disconnected
    
    private var priceTimer: Timer?
    private var tokensTimer: Timer?
    private var webSocketManager = SolanaWebSocketManager.shared
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        loadInitialData()
        startTimers()
        setupWebSocketSubscriptions()
    }
    
    deinit {
        priceTimer?.invalidate()
        priceTimer = nil
        
        tokensTimer?.invalidate()
        tokensTimer = nil
        
        // Вызываем disconnect в Task для совместимости с @MainActor
        Task { @MainActor in
            webSocketManager.disconnect()
        }
        
        cancellables.removeAll()
    }
    
    // MARK: - Initial Data Loading
    private func loadInitialData() {
        Task {
            await fetchSOLPrice()
            await fetchTopTokens()
            startWebSocketConnection()
        }
    }
    
    // MARK: - SOL Price Methods
    func fetchSOLPrice() async {
        isPriceLoading = true
        print("🔄 Starting SOL price fetch...")
        
        do {
            let priceData = try await BinanceAPI.shared.fetchSOLPrice()
            solPrice = priceData
            print("✅ SOL price loaded: \(priceData.formattedPrice), change: \(priceData.formattedChange)")
        } catch {
            print("❌ Failed to fetch SOL price: \(error)")
            
            // Устанавливаем nil чтобы показать placeholder вместо устаревших данных
            solPrice = nil
            print("🔄 Price data cleared due to API error")
        }
        
        isPriceLoading = false
    }
    
    // MARK: - WebSocket Methods
    private func setupWebSocketSubscriptions() {
        print("🔗 Setting up WebSocket subscriptions...")
        
        // Подписываемся на события WebSocket
        webSocketManager.eventPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] event in
                guard let self = self else { 
                    print("❌ Self is nil in WebSocket event handler")
                    return 
                }
                
                print("📨 Received WebSocket event: \(event)")
                
                switch event {
                case .newTransaction(let transaction):
                    print("🆕 New transaction event received: \(transaction.shortSignature)")
                    // Обновляем список транзакций
                    let oldCount = self.latestTransactions.count
                    self.latestTransactions = self.webSocketManager.latestTransactions
                    print("📊 Updated transactions: \(oldCount) -> \(self.latestTransactions.count)")
                    
                case .connectionStateChanged(let state):
                    print("🔌 WebSocket state changed: \(state)")
                    self.webSocketState = state
                    
                case .blockUpdate(let blockNumber):
                    print("📦 New block: \(blockNumber)")
                }
            }
            .store(in: &cancellables)
        
        print("✅ WebSocket subscriptions set up, cancellables count: \(cancellables.count)")
    }
    
    private func startWebSocketConnection() {
        isTransactionsLoading = true
        
        // Загружаем начальные mock данные
        latestTransactions = MockTransactionsProvider.generateMockTransactions()
        
        // Подключаемся к WebSocket для реалтайм обновлений
        webSocketManager.connect()
        
        isTransactionsLoading = false
    }
    
    private func refreshTransactions() {
        // Для WebSocket подключения просто переподключаемся
        Task { @MainActor in
            webSocketManager.disconnect()
            
            // Переподключаемся через секунду
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                Task { @MainActor in
                    self.webSocketManager.connect()
                }
            }
        }
    }
    
    // MARK: - Timer Management
    private func startTimers() {
        // Обновление цены SOL каждые 5 секунд (Binance API более стабильный)
        priceTimer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { _ in
            Task { @MainActor in
                await self.fetchSOLPrice()
            }
        }
        
        // Обновление топ токенов каждые 5 секунд
        tokensTimer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { _ in
            Task { @MainActor in
                await self.fetchTopTokens()
            }
        }
        
        // WebSocket обеспечивает реалтайм обновления транзакций
    }
    
    func stopTimers() {
        priceTimer?.invalidate()
        priceTimer = nil
        
        tokensTimer?.invalidate()
        tokensTimer = nil
        
        // Отключаем WebSocket
        Task { @MainActor in
            webSocketManager.disconnect()
        }
    }
    
    // MARK: - Top Tokens Methods
    func fetchTopTokens() async {
        isTopTokensLoading = true
        print("🔄 Starting top tokens fetch...")
        
        do {
            let tokens = try await SolSpyAPI.shared.fetchTopTokens()
            
            // Проверяем что получили валидные данные
            if !tokens.isEmpty {
                topTokens = tokens
                print("✅ Top tokens loaded: \(tokens.count) tokens with real logos")
                
                // Обновляем базовые данные для следующих обновлений
                TopToken.mockTokens = tokens
            } else {
                print("⚠️ Received empty tokens list, keeping current data")
            }
        } catch {
            print("❌ Failed to fetch top tokens: \(error)")
            // В случае ошибки показываем последние данные если они есть, иначе mock
            if topTokens.isEmpty {
                print("📋 Using fallback mock data")
                topTokens = TopToken.mockTokens
            } else {
                print("📋 Keeping last successful data")
            }
        }
        
        isTopTokensLoading = false
    }
    
    // MARK: - Pull to Refresh
    func refreshAll() async {
        await fetchSOLPrice()
        await fetchTopTokens()
        refreshTransactions()
    }
    
    // MARK: - Testing Methods
    func createTestTransaction() async {
        await webSocketManager.createTestTransaction()
    }
    
    // MARK: - WebSocket Status
    var isWebSocketConnected: Bool {
        switch webSocketState {
        case .connected:
            return true
        default:
            return false
        }
    }
    
    var webSocketStatusText: String {
        switch webSocketState {
        case .disconnected:
            return "Disconnected"
        case .connecting:
            return "Connecting..."
        case .connected:
            return "Live"
        case .error(let error):
            return "Error: \(error.localizedDescription)"
        }
    }
} 