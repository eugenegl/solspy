import Foundation

// MARK: - Основная модель транзакции
struct TransactionResponse: Codable {
    let address: String
    let type: EntityType
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
    
    // Инициализатор для создания базовых транзакций
    init(description: String, type: String, source: String, fee: Int, feePayer: String, 
         signature: String, slot: Int, timestamp: Int, tokenTransfers: [TokenTransfer], 
         nativeTransfers: [NativeTransfer], accountData: [AccountData], 
         transactionError: String?, instructions: [Instruction], events: [String: String]?) {
        self.description = description
        self.type = type
        self.source = source
        self.fee = fee
        self.feePayer = feePayer
        self.signature = signature
        self.slot = slot
        self.timestamp = timestamp
        self.tokenTransfers = tokenTransfers
        self.nativeTransfers = nativeTransfers
        self.accountData = accountData
        self.transactionError = transactionError
        self.instructions = instructions
        self.events = events
    }
    
    // Кодирование/декодирование для поддержки пустого словаря events
    enum CodingKeys: String, CodingKey {
        case description, type, source, fee, feePayer, signature, slot, timestamp
        case tokenTransfers, nativeTransfers, accountData, transactionError, instructions, events
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Обрабатываем базовые поля
        do {
            description = try container.decode(String.self, forKey: .description)
        } catch {
            print("Error decoding description: \(error)")
            description = "Transaction"
        }
        
        do {
            // type может быть в разных форматах и регистрах
            let rawType = try container.decode(String.self, forKey: .type)
            type = rawType
        } catch {
            print("Error decoding type: \(error)")
            type = "UNKNOWN"
        }
        
        do {
            source = try container.decode(String.self, forKey: .source)
        } catch {
            print("Error decoding source: \(error)")
            source = "UNKNOWN_SOURCE"
        }
        
        // fee может быть в разных форматах
        do {
            if let feeDouble = try? container.decode(Double.self, forKey: .fee) {
                fee = Int(feeDouble)
            } else {
                fee = try container.decode(Int.self, forKey: .fee)
            }
        } catch {
            print("Error decoding fee: \(error)")
            fee = 0
        }
        
        do {
            feePayer = try container.decode(String.self, forKey: .feePayer)
        } catch {
            print("Error decoding feePayer: \(error)")
            feePayer = ""
        }
        
        do {
            signature = try container.decode(String.self, forKey: .signature)
        } catch {
            print("Error decoding signature: \(error)")
            signature = ""
        }
        
        // slot обрабатываем как Int или Double
        do {
            if let slotDouble = try? container.decode(Double.self, forKey: .slot) {
                slot = Int(slotDouble)
            } else {
                slot = try container.decode(Int.self, forKey: .slot)
            }
        } catch {
            print("Error decoding slot: \(error)")
            slot = 0
        }
        
        // timestamp может быть Int, Double или String
        do {
            if let timestampDouble = try? container.decode(Double.self, forKey: .timestamp) {
                timestamp = Int(timestampDouble)
            } else if let timestampString = try? container.decode(String.self, forKey: .timestamp),
                      let timestampInt = Int(timestampString) {
                timestamp = timestampInt
            } else {
                timestamp = try container.decode(Int.self, forKey: .timestamp)
            }
        } catch {
            print("Error decoding timestamp: \(error)")
            timestamp = Int(Date().timeIntervalSince1970)
        }
        
        // Обрабатываем массивы
        tokenTransfers = (try? container.decodeIfPresent([TokenTransfer].self, forKey: .tokenTransfers)) ?? []
        nativeTransfers = (try? container.decodeIfPresent([NativeTransfer].self, forKey: .nativeTransfers)) ?? []
        accountData = (try? container.decodeIfPresent([AccountData].self, forKey: .accountData)) ?? []
        transactionError = try? container.decodeIfPresent(String.self, forKey: .transactionError)
        instructions = (try? container.decodeIfPresent([Instruction].self, forKey: .instructions)) ?? []
        
        // events может быть словарем, массивом или объектом - просто попробуем декодировать
        if let _ = try? container.decodeNil(forKey: .events) {
            events = nil
        } else {
            events = (try? container.decode([String: String].self, forKey: .events)) ?? [:]
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
            return "\(seconds) sec. ago"
        } else if seconds < 3600 {
            return "\(seconds / 60) min. ago"
        } else if seconds < 86400 {
            return "\(seconds / 3600) hrs. ago"
        } else {
            return "\(seconds / 86400) days ago"
        }
    }
}

// MARK: - Модель TokenTransfer
struct TokenTransfer: Codable {
    let fromUserAccount: String?
    let toUserAccount: String?
    let fromTokenAccount: String?
    let toTokenAccount: String?
    let tokenAmount: TokenAmount?
    let mint: String?  // Адрес токена
    
    // Добавляем кастомный декодер для гибкой обработки
    enum CodingKeys: String, CodingKey {
        case fromUserAccount, toUserAccount, fromTokenAccount, toTokenAccount, tokenAmount, mint
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        fromUserAccount = try? container.decodeIfPresent(String.self, forKey: .fromUserAccount)
        toUserAccount = try? container.decodeIfPresent(String.self, forKey: .toUserAccount)
        fromTokenAccount = try? container.decodeIfPresent(String.self, forKey: .fromTokenAccount)
        toTokenAccount = try? container.decodeIfPresent(String.self, forKey: .toTokenAccount)
        tokenAmount = try? container.decodeIfPresent(TokenAmount.self, forKey: .tokenAmount)
        mint = try? container.decodeIfPresent(String.self, forKey: .mint)
    }
    
    // Вычисляемые свойства для удобного доступа
    var amount: Double? {
        guard let rawAmount = tokenAmount?.uiAmount else { return nil }
        return rawAmount
    }
    
    var symbol: String? {
        tokenAmount?.symbol
    }
    
    var isIncoming: Bool? {
        guard let to = toUserAccount, let from = fromUserAccount else { return nil }
        return to != from
    }
}

// MARK: - Модель TokenAmount
struct TokenAmount: Codable {
    let amount: String
    let decimals: Int
    let uiAmount: Double
    let uiAmountString: String
    let symbol: String?     // Может быть nil для неизвестных токенов
    
    // Кастомный декодер для безопасной обработки полей
    enum CodingKeys: String, CodingKey {
        case amount, decimals, uiAmount, uiAmountString, symbol
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // amount может быть строкой или числом
        if let amountStr = try? container.decode(String.self, forKey: .amount) {
            amount = amountStr
        } else if let amountDouble = try? container.decode(Double.self, forKey: .amount) {
            amount = String(amountDouble)
        } else if let amountInt = try? container.decode(Int.self, forKey: .amount) {
            amount = String(amountInt)
        } else {
            amount = "0"
        }
        
        // decimals может быть числом или строкой
        if let decimalsInt = try? container.decode(Int.self, forKey: .decimals) {
            decimals = decimalsInt
        } else if let decimalsStr = try? container.decode(String.self, forKey: .decimals),
                  let decimalsVal = Int(decimalsStr) {
            decimals = decimalsVal
        } else {
            decimals = 0
        }
        
        // uiAmount может быть числом или строкой
        if let uiAmountDouble = try? container.decode(Double.self, forKey: .uiAmount) {
            uiAmount = uiAmountDouble
        } else if let uiAmountStr = try? container.decode(String.self, forKey: .uiAmount),
                  let uiAmountVal = Double(uiAmountStr) {
            uiAmount = uiAmountVal
        } else {
            uiAmount = 0
        }
        
        // Для uiAmountString и symbol мы просто пытаемся декодировать строку
        uiAmountString = (try? container.decode(String.self, forKey: .uiAmountString)) ?? "0"
        symbol = try? container.decodeIfPresent(String.self, forKey: .symbol)
    }
}

// MARK: - Модель NativeTransfer
struct NativeTransfer: Codable {
    let fromUserAccount: String
    let toUserAccount: String
    let amount: Int
    
    // Добавляем кастомный декодер для гибкой обработки
    enum CodingKeys: String, CodingKey {
        case fromUserAccount, toUserAccount, amount
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Пробуем прочитать аккаунты, если не удалось - используем пустые строки
        fromUserAccount = (try? container.decode(String.self, forKey: .fromUserAccount)) ?? ""
        toUserAccount = (try? container.decode(String.self, forKey: .toUserAccount)) ?? ""
        
        // amount может быть как Int, так и String или Double
        if let amountStr = try? container.decode(String.self, forKey: .amount) {
            amount = Int(amountStr) ?? 0
        } else if let amountDouble = try? container.decode(Double.self, forKey: .amount) {
            amount = Int(amountDouble)
        } else if let amountInt = try? container.decode(Int.self, forKey: .amount) {
            amount = amountInt
        } else {
            amount = 0
        }
    }
    
    var formattedAmount: String {
        let solAmount = Double(amount) / 1_000_000_000.0
        return String(format: "%.2f", solAmount)
    }
}

// MARK: - Модель AccountData
struct AccountData: Codable {
    let account: String
    let nativeBalanceChange: Int
    let tokenBalanceChanges: [TokenBalanceChange]?
    
    enum CodingKeys: String, CodingKey {
        case account, nativeBalanceChange, tokenBalanceChanges
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Безопасно декодируем account
        account = (try? container.decode(String.self, forKey: .account)) ?? ""
        
        // nativeBalanceChange может быть различных типов
        if let balanceStr = try? container.decode(String.self, forKey: .nativeBalanceChange),
           let balanceInt = Int(balanceStr) {
            nativeBalanceChange = balanceInt
        } else if let balanceDouble = try? container.decode(Double.self, forKey: .nativeBalanceChange) {
            nativeBalanceChange = Int(balanceDouble)
        } else if let balanceInt = try? container.decode(Int.self, forKey: .nativeBalanceChange) {
            nativeBalanceChange = balanceInt
        } else {
            nativeBalanceChange = 0
        }
        
        // Безопасно декодируем tokenBalanceChanges с учетом возможности null, пустого массива и т.д.
        do {
            tokenBalanceChanges = try container.decodeIfPresent([TokenBalanceChange].self, forKey: .tokenBalanceChanges)
        } catch {
            print("Error decoding tokenBalanceChanges: \(error)")
            tokenBalanceChanges = []
        }
    }
    
    var formattedBalanceChange: String {
        let solAmount = Double(nativeBalanceChange) / 1_000_000_000.0
        return String(format: "%.8f", solAmount)
    }
}

// MARK: - Модель TokenBalanceChange
struct TokenBalanceChange: Codable {
    let mint: String?
    let tokenAccount: String?
    let userAccount: String?
    let rawTokenAmount: RawTokenAmount?
    let symbol: String?
    
    // Кастомный декодер для безопасной обработки
    enum CodingKeys: String, CodingKey {
        case mint, tokenAccount, userAccount, rawTokenAmount, symbol
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Все поля опциональные, безопасно декодируем
        mint = try? container.decodeIfPresent(String.self, forKey: .mint)
        tokenAccount = try? container.decodeIfPresent(String.self, forKey: .tokenAccount)
        userAccount = try? container.decodeIfPresent(String.self, forKey: .userAccount)
        rawTokenAmount = try? container.decodeIfPresent(RawTokenAmount.self, forKey: .rawTokenAmount)
        symbol = try? container.decodeIfPresent(String.self, forKey: .symbol)
    }
}

// MARK: - Модель RawTokenAmount
struct RawTokenAmount: Codable {
    let tokenAmount: String?
    let decimals: Int?
    
    // Кастомный декодер для безопасной обработки
    enum CodingKeys: String, CodingKey {
        case tokenAmount, decimals
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // tokenAmount может быть строкой или числом
        if let amountStr = try? container.decode(String.self, forKey: .tokenAmount) {
            tokenAmount = amountStr
        } else if let amountDouble = try? container.decode(Double.self, forKey: .tokenAmount) {
            tokenAmount = String(amountDouble)
        } else if let amountInt = try? container.decode(Int.self, forKey: .tokenAmount) {
            tokenAmount = String(amountInt)
        } else {
            tokenAmount = nil
        }
        
        // decimals может быть числом или строкой
        if let decimalsInt = try? container.decode(Int.self, forKey: .decimals) {
            decimals = decimalsInt
        } else if let decimalsStr = try? container.decode(String.self, forKey: .decimals),
                  let decimalsVal = Int(decimalsStr) {
            decimals = decimalsVal
        } else {
            decimals = nil
        }
    }
    
    // Удобное свойство перевода в Double (если возможно)
    var uiAmount: Double? {
        guard let amountStr = tokenAmount,
              let amountDouble = Double(amountStr),
              let decimalsVal = decimals else { return nil }
        return amountDouble / pow(10, Double(decimalsVal))
    }
}

// MARK: - Модель Instruction
struct Instruction: Codable {
    let accounts: [String]
    let data: String
    let programId: String
    let innerInstructions: [InnerInstruction]
    
    // Добавляем кастомный декодер
    enum CodingKeys: String, CodingKey {
        case accounts, data, programId, innerInstructions
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Безопасно декодируем accounts
        if let accountArr = try? container.decode([String].self, forKey: .accounts) {
            accounts = accountArr
        } else {
            accounts = []
        }
        
        // Безопасно декодируем data
        data = (try? container.decode(String.self, forKey: .data)) ?? ""
        
        // Безопасно декодируем programId
        programId = (try? container.decode(String.self, forKey: .programId)) ?? ""
        
        // Безопасно декодируем innerInstructions
        innerInstructions = (try? container.decodeIfPresent([InnerInstruction].self, forKey: .innerInstructions)) ?? []
    }
    
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
    // Empty implementation to allow decoding anything
    init(from decoder: Decoder) throws {
        // Пустая имплементация - мы пока не используем это поле
    }
    
    func encode(to encoder: Encoder) throws {
        // Пустая имплементация - мы пока не используем это поле
    }
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