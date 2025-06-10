import Foundation
import Network
import Combine

// MARK: - WebSocket Connection States
enum WebSocketState: Equatable {
    case disconnected
    case connecting
    case connected
    case error(Error)
    
    static func == (lhs: WebSocketState, rhs: WebSocketState) -> Bool {
        switch (lhs, rhs) {
        case (.disconnected, .disconnected),
             (.connecting, .connecting),
             (.connected, .connected):
            return true
        case (.error(let lhsError), .error(let rhsError)):
            return lhsError.localizedDescription == rhsError.localizedDescription
        default:
            return false
        }
    }
    

}

// MARK: - WebSocket Events
enum SolanaWebSocketEvent {
    case newTransaction(LatestTransaction)
    case blockUpdate(Int)
    case connectionStateChanged(WebSocketState)
}

// MARK: - Solana WebSocket Manager
@MainActor
class SolanaWebSocketManager: ObservableObject {
    static let shared = SolanaWebSocketManager()
    
    @Published var connectionState: WebSocketState = .disconnected
    @Published var latestTransactions: [LatestTransaction] = []
    
    private var webSocketTask: URLSessionWebSocketTask?
    private var urlSession: URLSession
    private let eventSubject = PassthroughSubject<SolanaWebSocketEvent, Never>()
    
    // Throttling для ограничения частоты создания транзакций
    private var lastTransactionTime: Date = Date.distantPast
    private let transactionInterval: TimeInterval = 5.0 // 5 секунд между транзакциями
    
    // Public publisher для подписки на события
    var eventPublisher: AnyPublisher<SolanaWebSocketEvent, Never> {
        eventSubject.eraseToAnyPublisher()
    }
    
    private var isConnected: Bool {
        webSocketTask?.state == .running
    }
    
    private init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForResource = 30
        self.urlSession = URLSession(configuration: config)
    }
    
    // MARK: - Public Interface
    
    /// Подключается к Solana WebSocket для получения последних транзакций
    func connect() {
        guard !isConnected else {
            print("🔌 WebSocket already connected")
            return
        }
        
        disconnect() // Закрываем предыдущее соединение если есть
        
        // Используем публичный Solana RPC WebSocket
        guard let url = URL(string: "wss://api.mainnet-beta.solana.com") else {
            updateConnectionState(.error(WebSocketError.invalidURL))
            return
        }
        
        print("🔌 Connecting to Solana WebSocket: \(url)")
        updateConnectionState(.connecting)
        
        webSocketTask = urlSession.webSocketTask(with: url)
        webSocketTask?.resume()
        
        // Начинаем слушать сообщения
        startListening()
        
        // Подписываемся на логи для получения транзакций
        subscribeToRecentTransactions()
        
        updateConnectionState(.connected)
    }
    
    /// Отключается от WebSocket
    func disconnect() {
        print("🔌 Disconnecting WebSocket")
        webSocketTask?.cancel(with: .goingAway, reason: nil)
        webSocketTask = nil
        updateConnectionState(.disconnected)
    }
    
    /// Создает тестовую транзакцию для проверки UI (только для разработки)
    func createTestTransaction() async {
        print("🧪 Creating manual test transaction...")
        let testTransaction = createTransactionFromLogs(["Manual test transaction"], signature: nil)
        await addNewTransaction(testTransaction)
    }
    
    /// Настройка интервала между транзакциями (в секундах)
    func setTransactionInterval(_ interval: TimeInterval) {
        print("⚙️ Setting transaction interval to \(interval) seconds")
        // Мы не можем изменить let константу, но можем добавить эту возможность в будущем
    }
    
    // MARK: - Private Methods
    
    private func updateConnectionState(_ state: WebSocketState) {
        connectionState = state
        eventSubject.send(.connectionStateChanged(state))
    }
    
    private func startListening() {
        guard let webSocketTask = webSocketTask else { return }
        
        webSocketTask.receive { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let message):
                Task { @MainActor in
                    await self.handleWebSocketMessage(message)
                    self.startListening() // Продолжаем слушать
                }
            case .failure(let error):
                Task { @MainActor in
                    print("❌ WebSocket error: \(error)")
                    self.updateConnectionState(.error(error))
                    self.attemptReconnection()
                }
            }
        }
    }
    
    private func handleWebSocketMessage(_ message: URLSessionWebSocketTask.Message) async {
        switch message {
        case .string(let text):
            await parseWebSocketMessage(text)
        case .data(let data):
            if let text = String(data: data, encoding: .utf8) {
                await parseWebSocketMessage(text)
            }
        @unknown default:
            print("⚠️ Unknown WebSocket message type")
        }
    }
    
    private func parseWebSocketMessage(_ text: String) async {
        print("📥 Received WebSocket message: \(String(text.prefix(200)))...")
        
        // Парсим JSON ответ от Solana RPC
        do {
            let data = text.data(using: .utf8) ?? Data()
            let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
            
            print("🔍 Parsing JSON structure...")
            
            // Проверяем разные варианты структуры ответа
            if let params = json?["params"] as? [String: Any],
               let result = params["result"] as? [String: Any] {
                print("✅ Found params.result structure")
                
                if let context = result["context"] as? [String: Any],
                   let value = result["value"] as? [String: Any] {
                    print("✅ Found context and value")
                    
                    // Извлекаем подпись транзакции
                    if let signature = value["signature"] as? String {
                        print("✅ Found transaction signature: \(signature)")
                        
                        // Определяем тип инструкции из логов
                        var instructionType = "transfer"
                        if let logs = value["logs"] as? [String] {
                            instructionType = determineInstructionType(from: logs)
                        }
                        
                        let newTransaction = LatestTransaction(
                            signature: signature,
                            blockNumber: (context["slot"] as? Int) ?? Int.random(in: 345870650...345870700),
                            timeAgo: "just now",
                            instructionType: instructionType,
                            instructionCount: 1
                        )
                        
                        await addNewTransaction(newTransaction)
                        return
                    }
                }
            }
            
            // Проверяем метод подписки
            if let method = json?["method"] as? String {
                if method == "logsNotification",
                   let params = json?["params"] as? [String: Any],
                   let result = params["result"] as? [String: Any],
                   let value = result["value"] as? [String: Any],
                   let signature = value["signature"] as? String {
                    
                    print("✅ Found logsNotification with signature: \(signature)")
                    
                    var instructionType = "transfer"
                    if let logs = value["logs"] as? [String] {
                        instructionType = determineInstructionType(from: logs)
                    }
                    
                    let newTransaction = LatestTransaction(
                        signature: signature,
                        blockNumber: Int.random(in: 345870650...345870700),
                        timeAgo: "just now",
                        instructionType: instructionType,
                        instructionCount: 1
                    )
                    
                    await addNewTransaction(newTransaction)
                    return
                }
            }
            
            // Если структура не распознана, логируем её для отладки
            print("❌ Unrecognized JSON structure:")
            if let jsonData = try? JSONSerialization.data(withJSONObject: json ?? [:], options: .prettyPrinted),
               let jsonString = String(data: jsonData, encoding: .utf8) {
                print(jsonString)
            }
            
        } catch {
            print("❌ Failed to parse WebSocket message: \(error)")
        }
    }
    
    // Определяет тип инструкции на основе логов
    private func determineInstructionType(from logs: [String]) -> String {
        for log in logs {
            if log.contains("Transfer") {
                return "transfer"
            } else if log.contains("SetComputeUnitLimit") {
                return "SetComputeUnitLimit"
            } else if log.contains("swap") || log.contains("Swap") {
                return "swap"
            } else if log.contains("burn") || log.contains("Burn") {
                return "burn"
            } else if log.contains("mint") || log.contains("Mint") {
                return "mint"
            }
        }
        return "transfer" // default
    }
    
    private func subscribeToRecentTransactions() {
        // Подписываемся на логи новых блоков для отслеживания транзакций
        let subscription = """
        {
            "jsonrpc": "2.0",
            "id": 1,
            "method": "logsSubscribe",
            "params": [
                "all",
                {
                    "commitment": "finalized"
                }
            ]
        }
        """
        
        sendWebSocketMessage(subscription)
    }
    
    private func sendWebSocketMessage(_ message: String) {
        guard let webSocketTask = webSocketTask else {
            print("❌ Cannot send message: WebSocket not connected")
            return
        }
        
        let message = URLSessionWebSocketTask.Message.string(message)
        webSocketTask.send(message) { error in
            if let error = error {
                print("❌ Failed to send WebSocket message: \(error)")
            } else {
                print("📤 Sent WebSocket subscription")
            }
        }
    }
    

    
    private func createTransactionFromLogs(_ logs: [String], signature: String?) -> LatestTransaction {
        // Генерируем реалистичную транзакцию на основе логов
        let instructionTypes = ["transfer", "SetComputeUnitLimit", "swap", "burn", "mint"]
        let randomInstruction = instructionTypes.randomElement() ?? "transfer"
        
        // Используем реальную подпись если есть, иначе генерируем полную фиктивную
        let finalSignature: String
        if let realSignature = signature {
            finalSignature = realSignature
        } else {
            // Генерируем полную реалистичную подпись (44 символа base58)
            let chars = "123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz"
            finalSignature = String((0..<44).map { _ in chars.randomElement()! })
        }
        
        return LatestTransaction(
            signature: finalSignature,
            blockNumber: Int.random(in: 345870650...345870700),
            timeAgo: "just now",
            instructionType: randomInstruction,
            instructionCount: Int.random(in: 1...5)
        )
    }
    
    private func addNewTransaction(_ transaction: LatestTransaction) async {
        // Проверяем throttling - добавляем транзакцию только если прошло достаточно времени
        let now = Date()
        let timeSinceLastTransaction = now.timeIntervalSince(lastTransactionTime)
        
        if timeSinceLastTransaction < transactionInterval {
            print("⏱️ Throttling: Skipping transaction (only \(String(format: "%.1f", timeSinceLastTransaction))s since last)")
            return
        }
        
        // Обновляем время последней транзакции
        lastTransactionTime = now
        
        // Добавляем новую транзакцию в начало списка
        latestTransactions.insert(transaction, at: 0)
        
        // Ограничиваем список до 10 последних транзакций
        if latestTransactions.count > 10 {
            latestTransactions = Array(latestTransactions.prefix(10))
        }
        
        // Уведомляем подписчиков
        eventSubject.send(.newTransaction(transaction))
        
        print("🆕 New transaction added: \(transaction.shortSignature) - \(transaction.instructionType)")
    }
    
    private func attemptReconnection() {
        print("🔄 Attempting WebSocket reconnection in 5 seconds...")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) { [weak self] in
            guard let self = self else { return }
            
            if case .connected = self.connectionState {
                // Уже подключены, не нужно переподключаться
            } else {
                self.connect()
            }
        }
    }
}

// MARK: - WebSocket Errors
enum WebSocketError: Error, LocalizedError {
    case invalidURL
    case connectionFailed
    case subscriptionFailed
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid WebSocket URL"
        case .connectionFailed:
            return "WebSocket connection failed"
        case .subscriptionFailed:
            return "Failed to subscribe to events"
        }
    }
} 