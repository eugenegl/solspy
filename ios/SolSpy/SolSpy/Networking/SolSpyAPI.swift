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
        
        print("🔍 Searching for: \(address)")
        print("🌐 API URL: \(url)")

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
            let wallet = try decoder.decode(WalletResponse.self, from: data)
            print("📋 Parsed wallet: \(wallet.address)")
            print("   SOL: \(wallet.balance.uiAmount) SOL")
            print("   Assets: \(wallet.assets.count) tokens")
            return .wallet(wallet)

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
    
    // MARK: - Top Tokens API
    @available(iOS 15.0, *)
    func fetchTopTokens() async throws -> [TopToken] {
        // Получаем данные токенов через существующий API - обновленные адреса реального топ-5
        let tokenAddresses = [
            "6p6xgHyF7AeE6TZkSmFsko444wqoP15icUSqi2jfGiPN", // OFFICIAL TRUMP - №1 по капитализации
            "EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v", // USDC - №2 по капитализации
            "JUPyiwrYJFskUPiHa7hkeR8VUtAeFoSYbKedZNsDvCN", // Jupiter - №3 по капитализации 
            "So11111111111111111111111111111111111111112",  // Wrapped SOL - №4 по капитализации
            "Es9vMFrzaCERmJfrF4H2FYD4KCoNkY11McCe8BenwNYB"  // USDT - №5 по капитализации
        ]
        
        var topTokens: [TopToken] = []
        
        // Получаем данные каждого токена через search API
        for address in tokenAddresses {
            do {
                let searchResult = try await search(address: address)
                if case .token(let tokenResponse) = searchResult {
                    // Генерируем случайные изменения для имитации реалтайм данных
                    let priceChange = Double.random(in: -0.03...0.03)
                    let change24h = Double.random(in: -8.0...12.0)
                    
                    let basePrice = tokenResponse.price ?? 1.0
                    let newPrice = basePrice * (1 + priceChange)
                    let newMarketCap = tokenResponse.marketCap ?? 100_000_000
                    
                    let topToken = TopToken(
                        name: tokenResponse.title,
                        symbol: tokenResponse.symbol,
                        address: address,
                        price: newPrice,
                        marketCap: newMarketCap,
                        change24h: change24h,
                        logoURL: tokenResponse.iconURL // Используем реальный URL из API!
                    )
                    
                    topTokens.append(topToken)
                }
            } catch {
                print("❌ Failed to fetch token \(address): \(error)")
                // В случае ошибки используем fallback данные
                if let fallbackToken = TopToken.mockTokens.first(where: { $0.address == address }) {
                    topTokens.append(fallbackToken)
                }
            }
        }
        
        // Сортируем по рыночной капитализации
        let sortedTokens = topTokens.sorted { $0.marketCap > $1.marketCap }
        
        print("🔄 Fetched top tokens with real logos:")
        for token in sortedTokens {
            print("   \(token.symbol): \(token.formattedPrice) (Logo: \(token.logoURL ?? "none"))")
        }
        
        return sortedTokens
    }
}
