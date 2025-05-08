import Foundation

// MARK: - Основная модель транзакции
struct TransactionResponse: Codable {
    let address: String
    let type: String
    let transaction: DetailedTransaction
}

// MARK: - Модель DetailedTransaction
struct DetailedTransaction: Codable {
    let description: String
    let type: String
    let source: String
    let fee: Int
    let feePayer: String
    let signature: String
    let slot: Int
    let timestamp: Int
    let tokenTransfers: [TokenTransfer]
    let nativeTransfers: [NativeTransfer]
    let accountData: [AccountData]
    let transactionError: String?
    let instructions: [Instruction]
    let events: [String: String]?  // Опциональный словарь для events
    
    // Кодирование/декодирование для поддержки пустого словаря events
    enum CodingKeys: String, CodingKey {
        case description, type, source, fee, feePayer, signature, slot, timestamp
        case tokenTransfers, nativeTransfers, accountData, transactionError, instructions, events
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        description = try container.decode(String.self, forKey: .description)
        type = try container.decode(String.self, forKey: .type)
        source = try container.decode(String.self, forKey: .source)
        fee = try container.decode(Int.self, forKey: .fee)
        feePayer = try container.decode(String.self, forKey: .feePayer)
        signature = try container.decode(String.self, forKey: .signature)
        slot = try container.decode(Int.self, forKey: .slot)
        timestamp = try container.decode(Int.self, forKey: .timestamp)
        tokenTransfers = try container.decode([TokenTransfer].self, forKey: .tokenTransfers)
        nativeTransfers = try container.decode([NativeTransfer].self, forKey: .nativeTransfers)
        accountData = try container.decode([AccountData].self, forKey: .accountData)
        transactionError = try container.decodeIfPresent(String.self, forKey: .transactionError)
        instructions = try container.decode([Instruction].self, forKey: .instructions)
        
        // Попробуем декодировать events, но безопасно обработаем ошибку
        do {
            events = try container.decode([String: String].self, forKey: .events)
        } catch {
            // Если не получается, просто используем nil или пустой словарь
            events = [:]
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(description, forKey: .description)
        try container.encode(type, forKey: .type)
        try container.encode(source, forKey: .source)
        try container.encode(fee, forKey: .fee)
        try container.encode(feePayer, forKey: .feePayer)
        try container.encode(signature, forKey: .signature)
        try container.encode(slot, forKey: .slot)
        try container.encode(timestamp, forKey: .timestamp)
        try container.encode(tokenTransfers, forKey: .tokenTransfers)
        try container.encode(nativeTransfers, forKey: .nativeTransfers)
        try container.encode(accountData, forKey: .accountData)
        try container.encodeIfPresent(transactionError, forKey: .transactionError)
        try container.encode(instructions, forKey: .instructions)
        try container.encode(events ?? [:], forKey: .events)
    }
    
    // Дополнительные вычисляемые свойства
    var formattedFee: String {
        let solAmount = Double(fee) / 1_000_000_000.0
        return String(format: "%.8f", solAmount)
    }
    
    var formattedTimestamp: String {
        let date = Date(timeIntervalSince1970: TimeInterval(timestamp))
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .medium
        formatter.timeZone = TimeZone(identifier: "UTC")
        return formatter.string(from: date) + " +UTC"
    }
    
    var timeAgo: String {
        let timeInterval = Date().timeIntervalSince1970 - TimeInterval(timestamp)
        let seconds = Int(timeInterval)
        
        if seconds < 60 {
            return "\(seconds) сек. назад"
        } else if seconds < 3600 {
            return "\(seconds / 60) мин. назад"
        } else if seconds < 86400 {
            return "\(seconds / 3600) ч. назад"
        } else {
            return "\(seconds / 86400) дн. назад"
        }
    }
}

// MARK: - Модель TokenTransfer
struct TokenTransfer: Codable {
    // Поля будут добавлены по мере необходимости
}

// MARK: - Модель NativeTransfer
struct NativeTransfer: Codable {
    let fromUserAccount: String
    let toUserAccount: String
    let amount: Int
    
    var formattedAmount: String {
        let solAmount = Double(amount) / 1_000_000_000.0
        return String(format: "%.2f", solAmount)
    }
}

// MARK: - Модель AccountData
struct AccountData: Codable {
    let account: String
    let nativeBalanceChange: Int
    let tokenBalanceChanges: [TokenBalanceChange]
    
    var formattedBalanceChange: String {
        let solAmount = Double(nativeBalanceChange) / 1_000_000_000.0
        return String(format: "%.8f", solAmount)
    }
}

// MARK: - Модель TokenBalanceChange
struct TokenBalanceChange: Codable {
    // Поля будут добавлены по мере необходимости
}

// MARK: - Модель Instruction
struct Instruction: Codable {
    let accounts: [String]
    let data: String
    let programId: String
    let innerInstructions: [InnerInstruction]
    
    var shortProgramId: String {
        formatWalletAddress(programId)
    }
    
    var readableProgramName: String {
        if programId == "11111111111111111111111111111111" {
            return "System Program"
        } else if programId == "ComputeBudget111111111111111111111111111111" {
            return "Compute Budget Program"
        }
        return formatWalletAddress(programId)
    }
}

// MARK: - Модель InnerInstruction
struct InnerInstruction: Codable {
    // Поля будут добавлены по мере необходимости
}

// MARK: - Вспомогательные функции
func formatWalletAddress(_ address: String) -> String {
    if address.count <= 10 {
        return address
    }
    let prefix = address.prefix(5)
    let suffix = address.suffix(5)
    return "\(prefix)...\(suffix)"
} 