import Foundation
import SwiftUI

// MARK: - API Response Models
struct SandwichesResponse: Codable {
    let stats: SandwichStats
    let sandwiches: [SandwichEvent]
}

struct SandwichStats: Codable {
    let solDrained: Double
    let sandwichesCount: Int
    let victimsCount: Int
    let attackersCount: Int
    
    var formattedSolDrained: String {
        return String(format: "%.3f", solDrained)
    }
    
    var formattedSandwichesCount: String {
        return NumberFormatter.compactFormatter.string(from: NSNumber(value: sandwichesCount)) ?? "\(sandwichesCount)"
    }
    
    var formattedVictimsCount: String {
        return NumberFormatter.compactFormatter.string(from: NSNumber(value: victimsCount)) ?? "\(victimsCount)"
    }
    
    var formattedAttackersCount: String {
        return NumberFormatter.compactFormatter.string(from: NSNumber(value: attackersCount)) ?? "\(attackersCount)"
    }
}

struct SandwichEvent: Codable, Identifiable {
    let tokenAddress: String
    let walletAddress: String
    let solDrained: Double
    let txHashBuy: String
    let txHashSell: String
    let victimWalletAddress: String
    let victimAmountIn: Double
    let victimTxHash: String
    let slot: Int
    let source: String
    let createdAt: String
    
    var id: String { txHashBuy }
    
    var formattedSolDrained: String {
        return String(format: "%.6f", solDrained)
    }
    
    var formattedVictimAmount: String {
        return String(format: "%.6f", victimAmountIn)
    }
    
    var shortTokenAddress: String {
        guard tokenAddress.count > 8 else { return tokenAddress }
        return String(tokenAddress.prefix(4)) + "..." + String(tokenAddress.suffix(4))
    }
    
    var shortWalletAddress: String {
        guard walletAddress.count > 8 else { return walletAddress }
        return String(walletAddress.prefix(4)) + "..." + String(walletAddress.suffix(4))
    }
    
    var shortVictimAddress: String {
        guard victimWalletAddress.count > 8 else { return victimWalletAddress }
        return String(victimWalletAddress.prefix(4)) + "..." + String(victimWalletAddress.suffix(4))
    }
    
    var timeAgo: String {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        
        guard let date = formatter.date(from: createdAt) else {
            return "Unknown"
        }
        
        let relativeFormatter = RelativeDateTimeFormatter()
        relativeFormatter.unitsStyle = .abbreviated
        return relativeFormatter.localizedString(for: date, relativeTo: Date())
    }
    
    var sourceColor: Color {
        switch source.lowercased() {
        case "pump":
            return .purple
        case "pumpswap":
            return .orange
        case "raydium":
            return .blue
        default:
            return .gray
        }
    }
}

// MARK: - Legacy Models (for backward compatibility during transition)
struct MEVStatistics {
    let extracted: Double
    let sandwiches: Int
    let cost: Double
    let victims: Int
    let attackers: Int
    
    // Convert from new API model
    init(from stats: SandwichStats) {
        self.init(
            extracted: stats.solDrained,
            sandwiches: stats.sandwichesCount,
            cost: 0.0, // Not provided by API, setting to 0
            victims: stats.victimsCount,
            attackers: stats.attackersCount
        )
    }
    
    // Default initializer for legacy compatibility
    init(extracted: Double, sandwiches: Int, cost: Double, victims: Int, attackers: Int) {
        self.extracted = extracted
        self.sandwiches = sandwiches
        self.cost = cost
        self.victims = victims
        self.attackers = attackers
    }
    
    var formattedExtracted: String {
        return String(format: "%.3f", extracted)
    }
    
    var formattedCost: String {
        return String(format: "%.3f", cost)
    }
    
    var formattedSandwiches: String {
        return NumberFormatter.compactFormatter.string(from: NSNumber(value: sandwiches)) ?? "\(sandwiches)"
    }
    
    var formattedVictims: String {
        return NumberFormatter.compactFormatter.string(from: NSNumber(value: victims)) ?? "\(victims)"
    }
}

// MARK: - MEV Stream Event Models (Legacy)
struct MEVStreamEvent: Identifiable, Hashable {
    let id: String
    let timestamp: Date
    let station: String
    let tokens: [String]
    let actions: [MEVAction]
    
    var timeAgo: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: timestamp, relativeTo: Date())
    }
}

struct MEVAction: Identifiable, Hashable {
    let id = UUID()
    let type: MEVActionType
    let address: String
    let amount: Double
    let token: String
    let blockNumber: Int
    let nickname: String?
    
    var formattedAmount: String {
        return String(format: "%.3f", amount)
    }
    
    var shortAddress: String {
        guard address.count > 8 else { return address }
        return String(address.prefix(4)) + "..." + String(address.suffix(4))
    }
}

enum MEVActionType: String, CaseIterable {
    case bot = "Bot"
    case victim = "Victim"
    
    var color: String {
        switch self {
        case .bot:
            return "red"
        case .victim:
            return "orange"
        }
    }
}

// MARK: - Mock Data (Legacy)
extension MEVStatistics {
    static let mock = MEVStatistics(
        extracted: 43760.542,
        sandwiches: 367165,
        cost: 6465.026,
        victims: 113166,
        attackers: 70
    )
}

extension MEVStreamEvent {
    static let mockEvents: [MEVStreamEvent] = [
        MEVStreamEvent(
            id: "330827848",
            timestamp: Date().addingTimeInterval(-39),
            station: "Solar Station",
            tokens: ["SOL", "USDC"],
            actions: [
                MEVAction(
                    type: .bot,
                    address: "5KV9...Syhn",
                    amount: 0.095,
                    token: "SOL",
                    blockNumber: 92699806,
                    nickname: "N00b"
                ),
                MEVAction(
                    type: .victim,
                    address: "5KV9...Syhn",
                    amount: 0.095,
                    token: "SOL",
                    blockNumber: 92699806,
                    nickname: "N00b"
                ),
                MEVAction(
                    type: .bot,
                    address: "5KV9...Syhn",
                    amount: 0.095,
                    token: "SOL",
                    blockNumber: 92699806,
                    nickname: "N00b"
                )
            ]
        )
    ]
}

// MARK: - Number Formatter Extension
extension NumberFormatter {
    static let compactFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 0
        formatter.usesGroupingSeparator = true
        return formatter
    }()
}

// MARK: - Color Extension for SwiftUI Compatibility  
extension Color {
    // Helper for source colors - это расширение пустое, можно убрать если не используется
} 