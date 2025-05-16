import Foundation

// MARK: - API Errors
enum APIError: Error, LocalizedError {
    case invalidURL
    case badStatusCode(Int)
    case decoding(Error)
    case network(Error)

    var errorDescription: String? {
        switch self {
        case .invalidURL:             return "Invalid URL"
        case .badStatusCode(let c):   return "Server responded with status code \(c)"
        case .decoding(let err):      return "Decoding error: \(err.localizedDescription)"
        case .network(let err):       return "Network error: \(err.localizedDescription)"
        }
    }
}

// MARK: - Entity type that SolSpy returns under `/search`
enum EntityType: String, Codable {
    case WALLET, TOKEN, TRANSACTION
}

// MARK: - Quick struct just to read the `type` field
private struct SearchMeta: Codable {
    let address: String
    let type: EntityType
}

// MARK: - What the caller eventually gets
enum SearchEntity {
    case wallet(WalletResponse)
    case token(TokenResponse)
    case transaction(TransactionResponse)
}

// MARK: - Actual API client
final class SolSpyAPI {
    static let shared = SolSpyAPI(); private init() {}

    private let base = URL(string: "https://api.solspy.io/api/v1")!

    private let decoder: JSONDecoder = {
        let d = JSONDecoder()
        d.keyDecodingStrategy = .convertFromSnakeCase
        return d
    }()

    // MARK: - Public: single entry‑point that figures out what the backend sent back
    @available(iOS 15.0, *)
    func search(address: String) async throws -> SearchEntity {
        // 1. build URL
        guard var comps = URLComponents(url: base.appendingPathComponent("search"), resolvingAgainstBaseURL: false) else { throw APIError.invalidURL }
        comps.queryItems = [URLQueryItem(name: "address", value: address)]
        guard let url = comps.url else { throw APIError.invalidURL }

        // 2. fetch
        let (data, resp): (Data, URLResponse)
        do { (data, resp) = try await URLSession.shared.data(from: url) }
        catch { throw APIError.network(error) }

        guard let http = resp as? HTTPURLResponse, 200 ..< 300 ~= http.statusCode else {
            throw APIError.badStatusCode((resp as? HTTPURLResponse)?.statusCode ?? -1)
        }

        // 3. figure out what entity type the backend recognised
        let meta: SearchMeta
        do { meta = try decoder.decode(SearchMeta.self, from: data) }
        catch { throw APIError.decoding(error) }

        // 4. decode the full object based on `type`
        switch meta.type {
        case .WALLET:
            return .wallet( try decoder.decode(WalletResponse.self, from: data) )

        case .TRANSACTION:
            // handy log for troubleshooting – remove if noisy
            print("Raw tx JSON:", String(data: data, encoding: .utf8) ?? "<unreadable>")
            return .transaction( try decoder.decode(TransactionResponse.self, from: data) )

        case .TOKEN:
            // log once – helps when fields go missing on backend side
            print("Raw token JSON:", String(data: data, encoding: .utf8) ?? "<unreadable>")

            // `/search` уже содержит `token_info`, доп‑запрос не нужен → просто декодируем
            return .token( try decoder.decode(TokenResponse.self, from: data) )
        }
    }
}
