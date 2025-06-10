import Foundation

// MARK: - Binance API Client
final class BinanceAPI {
    static let shared = BinanceAPI()
    private init() {}
    
    private let baseURL = "https://api.binance.com/api/v3"
    
    private let decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        // Убираем автоматическую конверсию, так как используем кастомные CodingKeys
        return decoder
    }()
    
    @available(iOS 15.0, *)
    func fetchSOLPrice() async throws -> SOLPriceDisplay {
        guard let url = URL(string: "\(baseURL)/ticker/24hr?symbol=SOLUSDT") else {
            print("❌ Invalid Binance URL")
            throw APIError.invalidURL
        }
        
        print("🌐 Fetching SOL price from: \(url)")
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            print("❌ Invalid HTTP response")
            throw APIError.badStatusCode(-1)
        }
        
        guard 200...299 ~= httpResponse.statusCode else {
            print("❌ Bad status code: \(httpResponse.statusCode)")
            throw APIError.badStatusCode(httpResponse.statusCode)
        }
        
        print("📥 Received response: \(httpResponse.statusCode)")
        
        do {
            // Логируем сырой ответ для отладки
            if let jsonString = String(data: data, encoding: .utf8) {
                print("📄 Raw response: \(jsonString)")
            }
            
            let binanceResponse = try decoder.decode(BinanceTickerResponse.self, from: data)
            let solPrice = SOLPrice(from: binanceResponse)
            let result = SOLPriceDisplay(from: solPrice)
            print("🎯 Parsed SOL price: \(result.formattedPrice), change: \(result.formattedChange)")
            return result
        } catch {
            print("❌ Binance decoding error: \(error)")
            throw APIError.decoding(error)
        }
    }
} 