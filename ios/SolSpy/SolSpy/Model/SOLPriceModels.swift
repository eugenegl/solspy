import Foundation

// MARK: - Binance SOL Price Models
struct BinanceTickerResponse: Codable {
    let symbol: String
    let lastPrice: String
    let priceChangePercent: String
    
    enum CodingKeys: String, CodingKey {
        case symbol
        case lastPrice
        case priceChangePercent
    }
}

// MARK: - Internal SOL Price Model (конвертируется из Binance)
struct SOLPrice {
    let usd: Double
    let usd24hChange: Double
    
    init(from binanceResponse: BinanceTickerResponse) {
        self.usd = Double(binanceResponse.lastPrice) ?? 0.0
        self.usd24hChange = Double(binanceResponse.priceChangePercent) ?? 0.0
    }
    
    // Удобный инициализатор для Preview и тестов
    init(usd: Double, usd24hChange: Double) {
        self.usd = usd
        self.usd24hChange = usd24hChange
    }
}

// MARK: - UI Display Model
struct SOLPriceDisplay {
    let price: Double
    let change24h: Double
    let isPositive: Bool
    let lastUpdated: Date
    
    init(from solPrice: SOLPrice) {
        self.price = solPrice.usd
        self.change24h = solPrice.usd24hChange
        self.isPositive = solPrice.usd24hChange >= 0
        self.lastUpdated = Date()
    }
    
    var formattedPrice: String {
        return String(format: "$%.2f", price)
    }
    
    var formattedChange: String {
        let sign = isPositive ? "+" : ""
        return String(format: "\(sign)%.2f%%", change24h)
    }
} 