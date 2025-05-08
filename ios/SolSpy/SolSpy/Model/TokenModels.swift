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
    let royalty: TokenRoyalty?
    let tokenInfo: TokenInfo?

    enum CodingKeys: String, CodingKey {
        case interface
        case id
        case content
        case authorities
        case royalty
        case tokenInfo = "token_info"
    }
}

// MARK: - TokenContent
struct TokenContent: Codable {
    let jsonURI: String?
    let files: [TokenFile]?
    let metadata: TokenMetadata?
    let links: TokenLinks?

    enum CodingKeys: String, CodingKey {
        case jsonURI = "json_uri"
        case files
        case metadata
        case links
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
        case description
        case name
        case symbol
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

    enum CodingKeys: String, CodingKey {
        case royaltyModel = "royalty_model"
        case target
        case percent
        case basisPoints = "basis_points"
    }
}

// MARK: - TokenInfo (flattened convenient data)
struct TokenInfo: Codable {
    let symbol: String?
    let supply: Double?
    let decimals: Int?
    let tokenProgram: String?
    let priceInfo: TokenPriceInfo?

    enum CodingKeys: String, CodingKey {
        case symbol
        case supply
        case decimals
        case tokenProgram = "token_program"
        case priceInfo = "price_info"
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

    // Total supply in raw units (before decimals)
    var rawSupply: Double {
        token.tokenInfo?.supply ?? 0
    }

    // Supply accounting for decimals
    var uiSupply: Double {
        guard decimals > 0 else { return rawSupply }
        return rawSupply / pow(10, Double(decimals))
    }

    // Current price per token (USD)
    var pricePerToken: Double {
        token.tokenInfo?.priceInfo?.pricePerToken ?? 0
    }

    // Market cap (price * supply)
    var marketCap: Double {
        pricePerToken * uiSupply
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
} 