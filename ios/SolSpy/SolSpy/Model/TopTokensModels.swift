import Foundation

// MARK: - Модель для топ токенов
struct TopToken: Codable, Identifiable {
    let id = UUID()
    let name: String
    let symbol: String
    let address: String
    let price: Double
    let marketCap: Double
    let change24h: Double?
    let logoURL: String?
    
    // Дополнительные URL для fallback
    var fallbackLogoURLs: [String] {
        switch symbol {
        case "TRUMP":
            return [
                "https://assets.coingecko.com/coins/images/34963/large/trump.png",
                "https://assets.coingecko.com/coins/images/34963/small/trump.png",
                "https://s2.coinmarketcap.com/static/img/coins/64x64/trump.png"
            ]
        case "USDC":
            return [
                "https://assets.coingecko.com/coins/images/6319/large/USD_Coin_icon.png",
                "https://assets.coingecko.com/coins/images/6319/small/USD_Coin_icon.png",
                "https://s2.coinmarketcap.com/static/img/coins/64x64/3408.png"
            ]
        case "JUP":
            return [
                "https://assets.coingecko.com/coins/images/31929/large/jup.png",
                "https://assets.coingecko.com/coins/images/31929/small/jup.png",
                "https://s2.coinmarketcap.com/static/img/coins/64x64/29210.png"
            ]
        case "WSOL":
            return [
                "https://assets.coingecko.com/coins/images/21629/large/solana.jpg",
                "https://assets.coingecko.com/coins/images/1/large/solana.png",
                "https://s2.coinmarketcap.com/static/img/coins/64x64/5426.png"
            ]
        case "USDT":
            return [
                "https://assets.coingecko.com/coins/images/325/large/Tether.png",
                "https://assets.coingecko.com/coins/images/325/small/Tether.png",
                "https://s2.coinmarketcap.com/static/img/coins/64x64/825.png"
            ]
        default:
            return []
        }
    }
    
    // Форматированные значения для UI
    var formattedPrice: String {
        if price < 0.01 {
            return String(format: "$%.4f", price)
        } else {
            return String(format: "$%.2f", price)
        }
    }
    
    var formattedMarketCap: String {
        if marketCap >= 1_000_000_000 {
            return String(format: "$%.2fB", marketCap / 1_000_000_000)
        } else if marketCap >= 1_000_000 {
            return String(format: "$%.2fM", marketCap / 1_000_000)
        } else if marketCap >= 1_000 {
            return String(format: "$%.2fK", marketCap / 1_000)
        } else {
            return String(format: "$%.2f", marketCap)
        }
    }
    
    var formattedChange: String? {
        guard let change = change24h else { return nil }
        let sign = change >= 0 ? "+" : ""
        return "\(sign)\(String(format: "%.2f", change))%"
    }
    
    var changeColor: Color {
        guard let change = change24h else { return .gray }
        return change >= 0 ? .green : .red
    }
}

// MARK: - Mock данные для демонстрации
extension TopToken {
    static var mockTokens: [TopToken] = [
        TopToken(
            name: "OFFICIAL TRUMP",
            symbol: "TRUMP",
            address: "6p6xgHyF7AeE6TZkSmFsko444wqoP15icUSqi2jfGiPN",
            price: 10.97,
            marketCap: 10_969_993_325,
            change24h: 0.95,
            logoURL: "https://assets.coingecko.com/coins/images/34963/large/trump.png"
        ),
        TopToken(
            name: "USD Coin",
            symbol: "USDC",
            address: "EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v",
            price: 1.0,
            marketCap: 8_478_939_188,
            change24h: 0.0075,
            logoURL: "https://assets.coingecko.com/coins/images/6319/large/USD_Coin_icon.png"
        ),
        TopToken(
            name: "Jupiter",
            symbol: "JUP",
            address: "JUPyiwrYJFskUPiHa7hkeR8VUtAeFoSYbKedZNsDvCN",
            price: 0.496,
            marketCap: 3_433_745_218,
            change24h: 2.07,
            logoURL: "https://assets.coingecko.com/coins/images/31929/large/jup.png"
        ),
        TopToken(
            name: "Wrapped SOL",
            symbol: "WSOL",
            address: "So11111111111111111111111111111111111111112",
            price: 165.0,
            marketCap: 2_584_730_826,
            change24h: 2.52,
            logoURL: "https://assets.coingecko.com/coins/images/21629/large/solana.jpg"
        ),
        TopToken(
            name: "Tether USD",
            symbol: "USDT", 
            address: "Es9vMFrzaCERmJfrF4H2FYD4KCoNkY11McCe8BenwNYB",
            price: 1.0003,
            marketCap: 2_389_928_496,
            change24h: -0.03,
            logoURL: "https://assets.coingecko.com/coins/images/325/large/Tether.png"
        )
    ]
    
    // Функция для генерации обновленных данных токенов (имитация реальных рыночных данных)
    static func generateUpdatedTokens() -> [TopToken] {
        return mockTokens.map { token in
            // Генерируем случайное изменение цены от -5% до +5%
            let priceChange = Double.random(in: -0.05...0.05)
            let newPrice = token.price * (1 + priceChange)
            
            // Генерируем новое изменение за 24ч от -10% до +10%
            let newChange24h = Double.random(in: -10.0...10.0)
            
            // Пересчитываем market cap
            let supplyMultiplier = token.marketCap / token.price
            let newMarketCap = newPrice * supplyMultiplier
            
            return TopToken(
                name: token.name,
                symbol: token.symbol,
                address: token.address,
                price: newPrice,
                marketCap: newMarketCap,
                change24h: newChange24h,
                logoURL: token.logoURL
            )
        }
        // Сортируем по рыночной капитализации (топ по капитализации)
        .sorted { $0.marketCap > $1.marketCap }
    }
}

import SwiftUI

private extension Color {
    static let green = Color(red: 0.247, green: 0.918, blue: 0.286)
    static let red = Color(red: 0.918, green: 0.247, blue: 0.286)
    static let gray = Color.gray
} 
