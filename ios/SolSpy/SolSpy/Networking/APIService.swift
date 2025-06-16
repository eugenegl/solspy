import Foundation

class MEVAPIService {
    static let shared = MEVAPIService()
    private let baseURL = "https://api.solspy.io/api/v1"
    
    private init() {}
    
    enum TimeFilter: Int, CaseIterable {
        case oneDay = 1
        case threeDays = 3
        case sevenDays = 7
        case thirtyDays = 30
        
        var displayName: String {
            switch self {
            case .oneDay: return "last 1D"
            case .threeDays: return "last 3D" 
            case .sevenDays: return "last 7D"
            case .thirtyDays: return "last 30D"
            }
        }
    }
    
    // Основной метод для получения данных о сэндвич атаках
    func fetchSandwiches(days: TimeFilter = .thirtyDays) async throws -> SandwichesResponse {
        guard let url = URL(string: "\(baseURL)/sandwiches?days=\(days.rawValue)") else {
            throw MEVAPIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw MEVAPIError.invalidResponse
            }
            
            guard httpResponse.statusCode == 200 else {
                throw MEVAPIError.serverError(httpResponse.statusCode)
            }
            
            // Декодируем JSON ответ
            let decoder = JSONDecoder()
            let sandwichesResponse = try decoder.decode(SandwichesResponse.self, from: data)
            
            return sandwichesResponse
            
        } catch let decodingError as DecodingError {
            print("❌ Decoding error: \(decodingError)")
            throw MEVAPIError.decodingError(decodingError.localizedDescription)
        } catch {
            print("❌ Network error: \(error)")
            throw MEVAPIError.networkError(error.localizedDescription)
        }
    }
}

// MARK: - MEV API Error Types
enum MEVAPIError: LocalizedError {
    case invalidURL
    case invalidResponse
    case serverError(Int)
    case decodingError(String)
    case networkError(String)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .invalidResponse:
            return "Invalid response"
        case .serverError(let code):
            return "Server error with code: \(code)"
        case .decodingError(let message):
            return "Decoding error: \(message)"
        case .networkError(let message):
            return "Network error: \(message)"
        }
    }
} 