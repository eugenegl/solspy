import Foundation
import SwiftUI
import Combine

class TransactionViewModel: ObservableObject {
    @Published var transaction: DetailedTransaction?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private var cancellables = Set<AnyCancellable>()
    
    // Загружает транзакцию по подписи
    func loadTransaction(signature: String) {
        isLoading = true
        errorMessage = nil
        
        // В реальном приложении здесь будет API запрос
        // Для примера используем загрузку из локального JSON
        loadMockTransaction()
    }
    
    // Загружает тестовые данные из локального JSON файла
    private func loadMockTransaction() {
        guard let url = Bundle.main.url(forResource: "Transaction", withExtension: "json") else {
            self.errorMessage = "Не удалось найти тестовый JSON файл"
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
                self.errorMessage = "Ошибка декодирования: \(error.localizedDescription)"
                self.isLoading = false
            }
        }
    }
    
    // Реальная загрузка с API (будет реализована в будущем)
    private func fetchTransactionFromAPI(signature: String) {
        // Построение URL запроса
        guard let url = URL(string: "https://api.example.com/transactions/\(signature)") else {
            self.errorMessage = "Некорректный URL"
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
                    self.errorMessage = "Ошибка: \(error.localizedDescription)"
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
} 