import Foundation

// MARK: - API Errors
enum APIError: Error, LocalizedError {
    case invalidURL
    case badStatusCode(Int)
    case decoding(Error)
    case network(Error)

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .badStatusCode(let code):
            return "Server returned status code \(code)"
        case .decoding(let err):
            return "Response decoding error: \(err.localizedDescription)"
        case .network(let err):
            return "Network error: \(err.localizedDescription)"
        }
    }
}

// MARK: - Entity type returned by search endpoint
enum EntityType: String, Codable {
    case WALLET
    case TOKEN
    case TRANSACTION
}

// MARK: - Top-level response for search
private struct SearchMeta: Codable {
    let address: String
    let type: EntityType
}

// MARK: - Wrapper that calling code will receive
enum SearchEntity {
    case wallet(WalletResponse)
    case token(TokenResponse)
    case transaction(TransactionResponse)
}

// MARK: - API client
final class SolSpyAPI {
    static let shared = SolSpyAPI()
    private init() {}

    private let base = URL(string: "https://api.solspy.io/api/v1")!
    private let jsonDecoder: JSONDecoder = {
        let d = JSONDecoder()
        d.keyDecodingStrategy = .convertFromSnakeCase
        return d
    }()

    // Single public method - search. Depending on the response type
    // returns specific model in enum SearchEntity.
    @available(iOS 15.0, *)
    func search(address: String) async throws -> SearchEntity {
        guard var comps = URLComponents(url: base.appendingPathComponent("search"), resolvingAgainstBaseURL: false) else {
            throw APIError.invalidURL
        }
        comps.queryItems = [URLQueryItem(name: "address", value: address)]
        guard let url = comps.url else { throw APIError.invalidURL }

        let (data, response): (Data, URLResponse)
        do {
            (data, response) = try await URLSession.shared.data(from: url)
        } catch {
            throw APIError.network(error)
        }

        guard let http = response as? HTTPURLResponse, 200 ..< 300 ~= http.statusCode else {
            throw APIError.badStatusCode((response as? HTTPURLResponse)?.statusCode ?? -1)
        }

        // First decode just metadata to determine type
        let meta: SearchMeta
        do {
            meta = try jsonDecoder.decode(SearchMeta.self, from: data)
        } catch {
            throw APIError.decoding(error)
        }

        switch meta.type {
        case .WALLET:
            do {
                let wallet = try jsonDecoder.decode(WalletResponse.self, from: data)
                return .wallet(wallet)
            } catch {
                throw APIError.decoding(error)
            }
        case .TOKEN:
            do {
                let token = try jsonDecoder.decode(TokenResponse.self, from: data)
                return .token(token)
            } catch {
                throw APIError.decoding(error)
            }
        case .TRANSACTION:
            do {
                // Логирование содержимого JSON-ответа для отладки
                print("Raw Transaction JSON: \(String(data: data, encoding: .utf8) ?? "unable to decode")")
                
                let tx = try jsonDecoder.decode(TransactionResponse.self, from: data)
                return .transaction(tx)
            } catch {
                // Детальное логирование ошибки декодирования
                print("Transaction decoding error: \(error)")
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
                throw APIError.decoding(error)
            }
        }
    }
} 