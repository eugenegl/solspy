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
    
    // Загружает транзакцию по подписи
    func loadTransaction(signature: String) {
        currentSignature = signature
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                let entity = try await SolSpyAPI.shared.search(address: signature)
                if case .transaction(let tx) = entity {
                    await MainActor.run {
                        self.transaction = tx.transaction
                        self.isLoading = false
                    }
                } else {
                    // Если получили другой тип – fallback на mock
                    await MainActor.run {
                        self.errorMessage = "Could not find transaction"
                        self.isLoading = false
                    }
                }
            } catch {
                // При ошибке пробуем локальный мок (для оффлайн-превью)
                await MainActor.run {
                    self.errorMessage = error.localizedDescription
                    self.isLoading = false
                }
            }
        }
    }
    
    // Загружает тестовые данные из локального JSON файла
    private func loadMockTransaction() {
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
        // Обычно здесь будет запрос к API для получения актуального курса
        // Для примера используем фиксированный курс
        let rate = 50.0 // 1 SOL = 50 USD
        let usdAmount = solAmount * rate
        return String(format: "$%.6f", usdAmount)
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
} 