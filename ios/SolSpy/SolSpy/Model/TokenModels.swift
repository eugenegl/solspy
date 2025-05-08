import Foundation

// MARK: - Token API Response
struct TokenResponse: Codable {
    let address: String
    let type: String
    let token: TokenDetails
}

// MARK: - TokenDetails
struct TokenDetails: Codable {
    let interface: String?
    let id: String
    let content: TokenContent?
    let authorities: [TokenAuthority]?
    let compression: TokenCompression?
    let grouping: [String]?
    let royalty: TokenRoyalty?
    let creators: [TokenCreator]?
    let ownership: TokenOwnership?
    let supply: Double?
    let mutable: Bool?
    let burnt: Bool?
    let tokenInfo: TokenInfo?

    enum CodingKeys: String, CodingKey {
        case interface, id, content, authorities, compression, grouping
        case royalty, creators, ownership, supply, mutable, burnt
        case tokenInfo = "token_info"
    }
}

// MARK: - TokenCompression
struct TokenCompression: Codable {
    let eligible: Bool?
    let compressed: Bool?
    let dataHash: String?
    let creatorHash: String?
    let assetHash: String?
    let tree: String?
    let seq: Int?
    let leafId: Int?
}

// MARK: - TokenOwnership
struct TokenOwnership: Codable {
    let frozen: Bool?
    let delegated: Bool?
    let delegate: String?
    let ownershipModel: String?
    let owner: String?
}

// MARK: - TokenContent
struct TokenContent: Codable {
    let jsonURI: String?
    let files: [TokenFile]?
    let metadata: TokenMetadata?
    let links: TokenLinks?

    enum CodingKeys: String, CodingKey {
        case jsonURI = "json_uri"
        case files, metadata, links
    }
}

// MARK: - TokenFile
struct TokenFile: Codable {
    let uri: String?
    let cdnURI: String?
    let mime: String?

    enum CodingKeys: String, CodingKey {
        case uri
        case cdnURI = "cdn_uri"
        case mime
    }
}

// MARK: - TokenMetadata
struct TokenMetadata: Codable {
    let description: String?
    let name: String?
    let symbol: String?
    let tokenStandard: String?

    enum CodingKeys: String, CodingKey {
        case description, name, symbol
        case tokenStandard = "token_standard"
    }
}

// MARK: - TokenLinks
struct TokenLinks: Codable {
    let image: String?
}

// MARK: - TokenAuthority
struct TokenAuthority: Codable {
    let address: String?
    let scopes: [String]?
}

// MARK: - TokenRoyalty
struct TokenRoyalty: Codable {
    let royaltyModel: String?
    let target: String?
    let percent: Double?
    let basisPoints: Int?
    let primarySaleHappened: Bool?
    let locked: Bool?

    enum CodingKeys: String, CodingKey {
        case royaltyModel = "royalty_model"
        case target, percent
        case basisPoints = "basis_points"
        case primarySaleHappened = "primary_sale_happened"
        case locked
    }
}

// MARK: - TokenCreator
struct TokenCreator: Codable {
    let address: String?
    let share: Int?
    let verified: Bool?
}

// MARK: - TokenInfo (flattened convenient data)
struct TokenInfo: Codable {
    let symbol: String?
    let supply: String?        // всегда строка, но может приходить как число – декодим гибко
    let decimals: Int?
    let tokenProgram: String?
    let priceInfo: TokenPriceInfo?

    enum CodingKeys: String, CodingKey {
        case symbol, supply, decimals
        case tokenProgram = "token_program"
        case priceInfo = "price_info"
    }
    // Кастомный декодер, умеющий читать строку/число для supply
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        symbol = try container.decodeIfPresent(String.self, forKey: .symbol)
        // supply может прийти как Int/Double/String
        if let str = try? container.decode(String.self, forKey: .supply) {
            supply = str
        } else if let intVal = try? container.decode(Int.self, forKey: .supply) {
            supply = String(intVal)
        } else if let doubleVal = try? container.decode(Double.self, forKey: .supply) {
            // убираем возможные .0 на конце
            supply = String(format: "%.0f", doubleVal)
        } else {
            supply = nil
        }
        decimals = try container.decodeIfPresent(Int.self, forKey: .decimals)
        tokenProgram = try container.decodeIfPresent(String.self, forKey: .tokenProgram)
        priceInfo = try container.decodeIfPresent(TokenPriceInfo.self, forKey: .priceInfo)
    }
}

// MARK: - TokenPriceInfo
struct TokenPriceInfo: Codable {
    let pricePerToken: Double?
    let currency: String?

    enum CodingKeys: String, CodingKey {
        case pricePerToken = "price_per_token"
        case currency
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        // price может быть строкой или числом, либо null
        if let dbl = try? container.decode(Double.self, forKey: .pricePerToken) {
            pricePerToken = dbl
        } else if let str = try? container.decode(String.self, forKey: .pricePerToken) {
            pricePerToken = Double(str)
        } else {
            pricePerToken = nil
        }
        currency = try container.decodeIfPresent(String.self, forKey: .currency)
    }
}

// MARK: - Convenience Helpers
extension TokenResponse {
    // Token symbol (from metadata or tokenInfo)
    var symbol: String {
        token.tokenInfo?.symbol ?? token.content?.metadata?.symbol ?? ""
    }

    // Token name
    var name: String {
        token.content?.metadata?.name ?? symbol
    }

    // Token logo URL (cdn first, fallback links.image)
    var logoURL: String? {
        if let cdnURL = token.content?.files?.first?.cdnURI {
            return cdnURL
        }
        if let uri = token.content?.files?.first?.uri {
            return uri
        }
        return token.content?.links?.image
    }

    // Decimals
    var decimals: Int {
        token.tokenInfo?.decimals ?? 0
    }

    // Total supply in raw units (as formatted string to avoid large number issues)
    var rawSupplyString: String {
        token.tokenInfo?.supply ?? "0"
    }
    
    // Total supply converted to Double (safely)
    var rawSupply: Double {
        guard let supplyStr = token.tokenInfo?.supply else { return 0 }
        // Safe conversion of string to Double
        return Double(supplyStr) ?? 0
    }

    // Supply accounting for decimals with safer calculation
    var uiSupply: Double {
        guard let decimalValue = token.tokenInfo?.decimals, decimalValue > 0 else { return rawSupply }
        
        // For large numbers it's better to use NSDecimalNumber for precision
        if let supplyStr = token.tokenInfo?.supply,
           let supplyDecimal = Decimal(string: supplyStr) {
            
            // Create divisor directly as Decimal (10^decimals)
            let divisorDecimal = pow(Decimal(10), decimalValue)
            
            return (supplyDecimal / divisorDecimal).doubleValue
        }
        
        // Fallback if string conversion failed
        return rawSupply / pow(10, Double(decimalValue))
    }

    // Current price per token (USD)
    var pricePerToken: Double {
        // Return nil-coalesced value only if it's greater than zero
        if let price = token.tokenInfo?.priceInfo?.pricePerToken, price > 0 {
            return price
        }
        return 0
    }

    // Market cap (price * supply)
    var marketCap: Double {
        // Only calculate market cap if both price and supply are available
        let price = pricePerToken
        let supply = uiSupply
        
        if price > 0 && supply > 0 {
            return price * supply
        }
        return 0
    }

    // Shortened token address (first 5 ... last 5)
    var shortAddress: String {
        guard address.count > 10 else { return address }
        let start = address.prefix(5)
        let end = address.suffix(5)
        return "\(start)...\(end)"
    }

    // First authority address shortened
    var authorityShort: String {
        guard let authAddress = token.authorities?.first?.address else { return "--" }
        if authAddress.count <= 10 { return authAddress }
        return "\(authAddress.prefix(5))...\(authAddress.suffix(5))"
    }
    
    // Creator address shortened
    var creatorShort: String {
        guard let creatorAddress = token.creators?.first?.address else { return "--" }
        if creatorAddress.count <= 10 { return creatorAddress }
        return "\(creatorAddress.prefix(5))...\(creatorAddress.suffix(5))"
    }
}

// Расширение для Decimal, чтобы получить doubleValue
extension Decimal {
    var doubleValue: Double {
        return NSDecimalNumber(decimal: self).doubleValue
    }
} 