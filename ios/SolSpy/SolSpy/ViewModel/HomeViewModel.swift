import Foundation
import Combine

@MainActor
class HomeViewModel: ObservableObject {
    @Published var solPrice: SOLPriceDisplay?
    @Published var latestTransactions: [LatestTransaction] = []
    @Published var topTokens: [TopToken] = []
    @Published var mevStats: SandwichStats?
    @Published var lastMEVAttackTime: Date?
    @Published var isPriceLoading: Bool = false
    @Published var isTransactionsLoading: Bool = false
    @Published var isTopTokensLoading: Bool = false
    @Published var isMEVLoading: Bool = false
    @Published var webSocketState: WebSocketState = .disconnected
    
    private var priceTimer: Timer?
    private var tokensTimer: Timer?
    private var mevTimer: Timer?
    private var webSocketManager = SolanaWebSocketManager.shared
    private var mevAPIService = MEVAPIService.shared
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
        
        mevTimer?.invalidate()
        mevTimer = nil
        
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
            await fetchMEVStats()
            startWebSocketConnection()
        }
    }
    
    // MARK: - SOL Price Methods
    func fetchSOLPrice() async {
        guard !isPriceLoading else { return }
        
        isPriceLoading = true
        
        do {
            let price = try await BinanceAPI.shared.fetchSOLPrice()
            solPrice = price
        } catch {
            print("❌ Error fetching SOL price: \(error)")
        }
        
        isPriceLoading = false
    }
    
    // MARK: - WebSocket Methods
    private func setupWebSocketSubscriptions() {
        webSocketManager.$connectionState
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                self?.webSocketState = state
            }
            .store(in: &cancellables)
        
        webSocketManager.$latestTransactions
            .receive(on: DispatchQueue.main)
            .sink { [weak self] transactions in
                self?.latestTransactions = transactions
            }
            .store(in: &cancellables)
    }
    
    private func startWebSocketConnection() {
        Task { @MainActor in
            webSocketManager.connect()
        }
    }
    
    var webSocketStatusText: String {
        switch webSocketState {
        case .connected:
            return "Connected"
        case .connecting:
            return "Connecting..."
        case .disconnected:
            return "Disconnected"
        case .error:
            return "Connection Error"
        }
    }
    
    var isWebSocketConnected: Bool {
        webSocketState == .connected
    }
    
    func refreshAll() async {
        // Параллельные обновления для лучшей производительности
        async let priceTask: Void = fetchSOLPrice()
        async let tokensTask: Void = fetchTopTokens()
        async let mevTask: Void = fetchMEVStats()
        
        // Ждем завершения всех задач
        _ = await (priceTask, tokensTask, mevTask)
        
        // Обновляем транзакции через WebSocket переподключение
        refreshTransactions()
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
    
    // MARK: - MEV Methods
    func fetchMEVStats() async {
        guard !isMEVLoading else { return }
        
        isMEVLoading = true
        
        do {
            // Используем 7 дней для более свежих данных
            let response = try await mevAPIService.fetchSandwiches(days: .sevenDays)
            mevStats = response.stats
            
            // Сохраняем время последней атаки для определения устаревших данных
            if let latestAttack = response.sandwiches.first {
                print("📊 Latest MEV attack: \(latestAttack.createdAt)")
                let formatter = ISO8601DateFormatter()
                formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
                if let attackDate = formatter.date(from: latestAttack.createdAt) {
                    lastMEVAttackTime = attackDate
                    let hoursAgo = Date().timeIntervalSince(attackDate) / 3600
                    print("⏰ Latest attack was \(String(format: "%.1f", hoursAgo)) hours ago")
                    
                    if hoursAgo > 2 {
                        print("⚠️ MEV data seems stale (>2 hours old)")
                    }
                }
            }
            
        } catch {
            print("❌ Error fetching MEV stats: \(error)")
        }
        
        isMEVLoading = false
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
        
        // Обновление MEV статистики каждые 2 минуты (данные не так критичны для реалтайма)
        mevTimer = Timer.scheduledTimer(withTimeInterval: 120.0, repeats: true) { _ in
            Task { @MainActor in
                await self.fetchMEVStats()
            }
        }
        
        // WebSocket обеспечивает реалтайм обновления транзакций
    }
    
    func stopTimers() {
        priceTimer?.invalidate()
        priceTimer = nil
        
        tokensTimer?.invalidate()
        tokensTimer = nil
        
        mevTimer?.invalidate()
        mevTimer = nil
        
        // Отключаем WebSocket
        Task { @MainActor in
            webSocketManager.disconnect()
        }
    }
    
    // MARK: - Top Tokens Methods
    func fetchTopTokens() async {
        guard !isTopTokensLoading else { return }
        
        isTopTokensLoading = true
        
        do {
            let tokens = try await SolSpyAPI.shared.fetchTopTokens()
            topTokens = tokens
        } catch {
            print("❌ Error fetching top tokens: \(error)")
            topTokens = TopToken.mockTokens
        }
        
        isTopTokensLoading = false
    }
    
    // MARK: - Testing Methods
    func createTestTransaction() async {
        await webSocketManager.createTestTransaction()
    }
    
    // Computed property для проверки устаревших MEV данных
    var isMEVDataStale: Bool {
        guard let lastAttack = lastMEVAttackTime else { return true }
        let hoursAgo = Date().timeIntervalSince(lastAttack) / 3600
        return hoursAgo > 2.0 // Считаем устаревшими если старше 2 часов
    }
} 