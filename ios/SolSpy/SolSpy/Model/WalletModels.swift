import Foundation

// MARK: - Wallet
struct WalletResponse: Codable {
    let address: String
    let type: EntityType
    let balance: TokenBalance
    let assets: [TokenAsset]
    let transactions: [DetailedTransaction]?
}

// MARK: - TokenBalance
struct TokenBalance: Codable {
    let address: String
    let amount: Int
    let uiAmount: Double
    let decimals: Int
    let symbol: String
    let name: String
    let logo: String?
    let priceInfo: PriceInfo?
}

// MARK: - TokenAsset
struct TokenAsset: Codable {
    let address: String
    let amount: Int
    let uiAmount: Double
    let decimals: Int
    let symbol: String
    let name: String
    let description: String?
    let logo: String?
    let supply: Double?
    let priceInfo: PriceInfo?
}

// MARK: - PriceInfo
struct PriceInfo: Codable {
    let pricePerToken: Double?
    let totalPrice: Double?

    enum CodingKeys: String, CodingKey {
        case pricePerToken, totalPrice
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        // pricePerToken может быть Double или String или null
        if let dbl = try? container.decode(Double.self, forKey: .pricePerToken) {
            pricePerToken = dbl
        } else if let str = try? container.decode(String.self, forKey: .pricePerToken) {
            pricePerToken = Double(str)
        } else {
            pricePerToken = nil
        }

        if let dbl = try? container.decode(Double.self, forKey: .totalPrice) {
            totalPrice = dbl
        } else if let str = try? container.decode(String.self, forKey: .totalPrice) {
            totalPrice = Double(str)
        } else {
            totalPrice = nil
        }
    }
}

// MARK: - Transaction types
enum TransactionType: String, Codable {
    case transfer = "Transfer"
    case burn = "Burn"
    case swap = "Swap"
    case failed = "Failed"
    case generic = "Generic"
    case unknown = "Unknown"
}

// MARK: - Transaction
struct Transaction: Identifiable {
    let id = UUID()
    let type: TransactionType
    let amount: Double?
    let tokenSymbol: String?
    let date: Date
    let address: String
    let isFailed: Bool
    let isIncoming: Bool
    
    // For Swap transactions
    let fromAmount: Double?
    let fromSymbol: String?
    let toAmount: Double?
    let toSymbol: String?
    
    // Default init for most transactions
    init(type: TransactionType, amount: Double?, tokenSymbol: String?, date: Date, address: String, isIncoming: Bool = false, isFailed: Bool = false) {
        self.type = type
        self.amount = amount
        self.tokenSymbol = tokenSymbol
        self.date = date
        self.address = address
        self.isIncoming = isIncoming
        self.isFailed = isFailed
        self.fromAmount = nil
        self.fromSymbol = nil
        self.toAmount = nil
        self.toSymbol = nil
    }
    
    // Init for swap transactions
    init(date: Date, address: String, fromAmount: Double, fromSymbol: String, toAmount: Double, toSymbol: String) {
        self.type = .swap
        self.date = date
        self.address = address
        self.amount = nil
        self.tokenSymbol = nil
        self.isIncoming = false
        self.isFailed = false
        self.fromAmount = fromAmount
        self.fromSymbol = fromSymbol
        self.toAmount = toAmount
        self.toSymbol = toSymbol
    }
    
    // Init for failed transactions
    static func failed(date: Date, address: String) -> Transaction {
        return Transaction(type: .failed, amount: nil, tokenSymbol: nil, date: date, address: address, isIncoming: false, isFailed: true)
    }
}

// MARK: - Helper Extensions
extension WalletResponse {
    var totalBalance: Double {
        let assetsTotal = assets.map { $0.priceInfo?.totalPrice ?? 0 }.reduce(0, +)
        return (balance.priceInfo?.totalPrice ?? 0) + assetsTotal
    }
    
    var tokenCount: Int {
        return assets.count
    }
    
    // Returns formatted wallet address with first 5 and last 5 characters
    var shortAddress: String {
        guard address.count > 10 else { return address }
        let start = address.prefix(5)
        let end = address.suffix(5)
        return "\(start)...\(end)"
    }
}

extension Double {
    // Format price with currency symbol
    func formatAsCurrency() -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        
        // Выбираем количество десятичных знаков динамически
        if self < 0.01 && self > 0 {
            formatter.maximumFractionDigits = 6
            formatter.minimumFractionDigits = 4
        } else {
            formatter.maximumFractionDigits = 2
            formatter.minimumFractionDigits = 2
        }
        
        formatter.currencySymbol = "$"
        formatter.decimalSeparator = ","
        formatter.groupingSeparator = " "
        formatter.currencyDecimalSeparator = ","
        // Убедимся, что символ всегда стоит перед числом
        formatter.positiveFormat = "$ #,##0.######"
        
        if let formattedAmount = formatter.string(from: NSNumber(value: self)) {
            return formattedAmount
        }
        // Фоллбек
        return "$\(self)"
    }
    
    // Format token amount with appropriate precision
    func formatAsTokenAmount() -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 6
        formatter.minimumFractionDigits = 0
        formatter.decimalSeparator = ","
        formatter.groupingSeparator = " "
        
        if let formattedAmount = formatter.string(from: NSNumber(value: self)) {
            return formattedAmount
        }
        return "\(self)"
    }

    // Форматировать как процент (для дальнейшего использования)
    func formatAsPercent() -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .percent
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 0
        formatter.decimalSeparator = ","
        formatter.groupingSeparator = " "
        
        if let formattedAmount = formatter.string(from: NSNumber(value: self / 100)) {
            return formattedAmount
        }
        return "\(self)%"
    }
    
    // Форматировать с определенным количеством десятичных знаков
    func formatWithPrecision(digits: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = digits
        formatter.minimumFractionDigits = digits
        formatter.decimalSeparator = ","
        formatter.groupingSeparator = " "
        
        if let formattedAmount = formatter.string(from: NSNumber(value: self)) {
            return formattedAmount
        }
        return "\(self)"
    }
}

extension Date {
    func timeAgo() -> String {
        let calendar = Calendar.current
        let now = Date()
        let components = calendar.dateComponents([.minute, .hour, .day, .weekOfYear, .month, .year], from: self, to: now)
        
        if let year = components.year, year >= 1 {
            return year == 1 ? "1 year ago" : "\(year) years ago"
        }
        
        if let month = components.month, month >= 1 {
            return month == 1 ? "1 month ago" : "\(month) months ago"
        }
        
        if let week = components.weekOfYear, week >= 1 {
            return week == 1 ? "1 week ago" : "\(week) weeks ago"
        }
        
        if let day = components.day, day >= 1 {
            return day == 1 ? "1 day ago" : "\(day) days ago"
        }
        
        if let hour = components.hour, hour >= 1 {
            return hour == 1 ? "1 hour ago" : "\(hour) hours ago"
        }
        
        if let minute = components.minute, minute >= 1 {
            return minute == 1 ? "1 minute ago" : "\(minute) minutes ago"
        }
        
        return "Just now"
    }
} 