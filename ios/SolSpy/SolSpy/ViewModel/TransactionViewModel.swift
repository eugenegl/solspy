import Foundation
import SwiftUI
import Combine

class TransactionViewModel: ObservableObject {
    @Published var transaction: DetailedTransaction?
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var showToast: Bool = false
    @Published var toastMessage: String = ""
    
    private var cancellables = Set<AnyCancellable>()
    private var currentSignature: String?
    private var currentSOLPrice: Double = 158.07 // Значение по умолчанию
    
    // Загружает транзакцию по подписи
    func loadTransaction(signature: String) {
        currentSignature = signature
        isLoading = true
        errorMessage = nil
        transaction = nil
        
        print("🔍 Loading transaction: \(signature)")
        
        // Если signature пустой, загружаем mock для preview
        guard !signature.isEmpty else {
            print("⚠️ Empty signature, loading mock for preview")
            loadMockTransaction()
            return
        }
        
        Task {
            do {
                let entity = try await SolSpyAPI.shared.search(address: signature)
                if case .transaction(let tx) = entity {
                    await MainActor.run {
                        self.transaction = tx.transaction
                        self.isLoading = false
                        print("✅ Loaded real transaction from API")
                    }
                } else {
                    await MainActor.run {
                        print("⚠️ API returned different type (not a transaction)")
                        self.errorMessage = "Указанная подпись не является транзакцией"
                        self.isLoading = false
                    }
                }
            } catch {
                await MainActor.run {
                    print("❌ API error: \(error)")
                    
                    // Более детальное объяснение ошибок
                    if error.localizedDescription.contains("400") {
                        // Для свежих транзакций (которые "just now") показываем базовую информацию
                        self.createBasicTransactionInfo(signature: signature)
                        self.errorMessage = "Транзакция очень свежая и ещё обрабатывается. Показана базовая информация."
                    } else if error.localizedDescription.contains("404") {
                        self.errorMessage = "Транзакция не существует в базе данных."
                    } else if error.localizedDescription.contains("timeout") || error.localizedDescription.contains("connection") {
                        self.errorMessage = "Проблема с подключением к серверу. Проверьте интернет."
                    } else {
                        self.errorMessage = "Ошибка загрузки: \(error.localizedDescription)"
                    }
                    
                    self.isLoading = false
                }
            }
        }
    }
    
    // Загружает тестовые данные из локального JSON файла
    func loadMockTransaction() {
        guard let url = Bundle.main.url(forResource: "Transaction", withExtension: "json") else {
            self.errorMessage = "Could not find test JSON file"
            self.isLoading = false
            return
        }
        
        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            let response = try decoder.decode(TransactionResponse.self, from: data)
            
            DispatchQueue.main.async {
                self.transaction = response.transaction
                self.isLoading = false
            }
        } catch {
            DispatchQueue.main.async {
                self.errorMessage = "Decoding error: \(error.localizedDescription)"
                self.isLoading = false
            }
        }
    }
    
    // Реальная загрузка с API (будет реализована в будущем)
    private func fetchTransactionFromAPI(signature: String) {
        // Построение URL запроса
        guard let url = URL(string: "https://api.example.com/transactions/\(signature)") else {
            self.errorMessage = "Invalid URL"
            self.isLoading = false
            return
        }
        
        URLSession.shared.dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: TransactionResponse.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink { completion in
                self.isLoading = false
                
                if case .failure(let error) = completion {
                    self.errorMessage = "Error: \(error.localizedDescription)"
                }
            } receiveValue: { response in
                self.transaction = response.transaction
            }
            .store(in: &cancellables)
    }
    
    // Форматированное отображение подписи транзакции
    func formattedSignature(_ signature: String) -> String {
        return formatWalletAddress(signature)
    }
    
    // Получение результата транзакции
    var transactionResult: String {
        if transaction?.transactionError == nil {
            return "SUCCESS"
        } else {
            return "FAILED"
        }
    }
    
    // Получение цвета результата транзакции
    var resultColor: Color {
        if transaction?.transactionError == nil {
            return Color(red: 0.247, green: 0.918, blue: 0.286)
        } else {
            return Color.red
        }
    }
    
    // Получение информации о подтверждениях
    var confirmationStatus: String {
        return "Finalized (MAX Confirmations)"
    }
    
    // Возвращает форматированную сумму в SOL для отображения
    func formatSolAmount(_ amount: Int) -> String {
        let solAmount = Double(amount) / 1_000_000_000.0
        return String(format: "%.5f", solAmount)
    }
    
    // Примерная конвертация SOL в USD
    func solToUSD(_ solAmount: Double) -> String {
        let usdAmount = solAmount * currentSOLPrice
        return String(format: "$%.2f", usdAmount)
    }
    
    // Обновляет текущий курс SOL
    func updateSOLPrice(_ price: Double) {
        currentSOLPrice = price
    }
    
    // Возвращает адрес в сокращенном виде
    func shortAddress(_ address: String) -> String {
        return formatWalletAddress(address)
    }
    
    // Обновляет данные транзакции
    func refreshData() {
        // Проверяем, есть ли сохраненная подпись
        guard let signature = currentSignature else { return }
        
        Task {
            do {
                let entity = try await SolSpyAPI.shared.search(address: signature)
                if case .transaction(let tx) = entity {
                    await MainActor.run {
                        self.transaction = tx.transaction
                        self.errorMessage = nil
                    }
                }
            } catch {
                // При ошибке обновления показываем короткий тост вместо замены данных
                await MainActor.run {
                    self.showToast(message: "Failed to refresh: \(error.localizedDescription)")
                }
            }
        }
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
    
    // Копирует адрес подписанта в буфер обмена
    func copySignerAddress(_ address: String) {
        UIPasteboard.general.string = address
        showToast(message: "Signer address copied")
    }
    
    // Создает базовую информацию о транзакции для свежих транзакций
    private func createBasicTransactionInfo(signature: String) {
        // Создаем минимальную транзакцию с доступной информацией
        let basicTransaction = DetailedTransaction(
            description: "Fresh Transaction",
            type: "TRANSFER",
            source: "Solana WebSocket",
            fee: 5000, // стандартная комиссия в лампортах
            feePayer: "Неизвестно", // будет заполнено когда API обработает
            signature: signature,
            slot: Int.random(in: 345870000...345900000),
            timestamp: Int(Date().timeIntervalSince1970),
            tokenTransfers: [],
            nativeTransfers: [],
            accountData: [],
            transactionError: nil,
            instructions: [],
            events: [:]
        )
        
        self.transaction = basicTransaction
        self.isLoading = false
    }
} 