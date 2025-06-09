//  TokenModels.swift
//  SolSpy
//
//  Unified model for /search TOKEN response
//  Covers all UI‑required fields and stays resilient to missing keys.
//  If a value is absent in the payload, computed helpers return "--" (dash)
//  so that the UI layer can bind directly without extra nil‑checks.
//
//  Created May 13 2025

import Foundation

// MARK: - Top‑level /search response
struct TokenResponse: Codable {
    let address: String              // full token address for deep links
    let type: String                 // "TOKEN"
    let token: TokenDetails          // the heavy payload
}

// MARK: - Middle layer
struct TokenDetails: Codable {
    // required for computed helpers
    let id: String
    let interface: String?

    // Rich content & visuals
    let content: TokenContent?

    // On‑chain metadata & authorities
    let authorities: [TokenAuthority]?
    let creators:   [TokenCreator]?

    // Duplicates of some fields that may also appear inside `tokenInfo`
    let decimals: Int?
    let supply:   Double?

    // Extended low‑level info
    let tokenInfo: TokenInfo?

    // Community / analytical fields that might arrive from the backend in future
    let holders: Double?            // nullable – not present in sample JSON but reserved

    private enum CodingKeys: String, CodingKey {
        case id, interface, content, authorities, creators, decimals, supply
        case tokenInfo, holders   // rely on global .convertFromSnakeCase
    }
}

// MARK: - Rich content (images, name, description, links)
struct TokenContent: Codable {
    let jsonUri: String?
    let files: [TokenFile]?
    let metadata: TokenMetadata?
    let links: TokenLinks?
}
struct TokenFile: Codable {
    let uri:     String?
    let cdnUri:  String?
    let mime:    String?
}

/// Name, symbol, description, plus optional "extensions" block with arbitrary key/values.
struct TokenMetadata: Codable {
    let description:  String?
    let name:         String?
    let symbol:       String?
    let tokenStandard:String?
    let extensions:   [String: String]?  // website, twitter, discord & other custom links
}

/// Dynamic container – collects every string link under `links` no matter the key.
struct TokenLinks: Codable {
    let map: [String: String]  // arbitrary keys (image, website, twitter, …)

    struct AnyKey: CodingKey {
        var stringValue: String
        init?(stringValue: String) { self.stringValue = stringValue }
        var intValue: Int? { nil }
        init?(intValue: Int) { nil }
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: AnyKey.self)
        var tmp: [String: String] = [:]
        for key in container.allKeys {
            if let value = try? container.decode(String.self, forKey: key) {
                tmp[key.stringValue] = value
            }
        }
        map = tmp
    }
}

// MARK: - Authority / creator records
struct TokenAuthority: Codable {
    let address: String?
    let scopes:  [String]?
}
struct TokenCreator: Codable {
    let address:  String?
    let share:    Int?
    let verified: Bool?
}

// MARK: - Low‑level numerical info
struct TokenInfo: Codable {
    let symbol:  String?
    let supply:  Decimal?   // can arrive as string or number
    let decimals:Int?
    let tokenProgram: String?
    let priceInfo: TokenPriceInfo?

    // optional analytics fields
    let holders: Double?    // not in sample JSON but may be provided by backend

    private enum CodingKeys: String, CodingKey {
        case symbol, supply, decimals, holders, tokenProgram, priceInfo
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        symbol       = try c.decodeIfPresent(String.self,  forKey: .symbol)
        decimals     = try c.decodeIfPresent(Int.self,     forKey: .decimals)
        tokenProgram = try c.decodeIfPresent(String.self,  forKey: .tokenProgram)
        
        priceInfo    = try c.decodeIfPresent(TokenPriceInfo.self, forKey: .priceInfo)
        
        holders      = try c.decodeIfPresent(Double.self,  forKey: .holders)

        // supply is tricky – may be number or string, and can be very large
        if let s = try? c.decodeIfPresent(String.self, forKey: .supply) {
            supply = Decimal(string: s)
        } else if let i = try? c.decodeIfPresent(Int64.self, forKey: .supply) {
            supply = Decimal(i)
        } else if let n = try? c.decodeIfPresent(Double.self, forKey: .supply) {
            supply = Decimal(n)
        } else {
            supply = nil
        }
    }
}
struct TokenPriceInfo: Codable {
    let pricePerToken: Double?
    let currency:      String?
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        pricePerToken = try container.decodeIfPresent(Double.self, forKey: .pricePerToken)
        currency = try container.decodeIfPresent(String.self, forKey: .currency)
    }
}

// MARK: - Convenience extensions for UI binding
extension TokenResponse {
    /// Screen title: "TokenName (SYMBOL)"
    var title: String {
        let name = token.content?.metadata?.name ?? symbol
        return name.isEmpty ? symbol : name
    }

    /// Main icon URL (png / svg). Nil if missing.
    var iconURL: String? {
        token.content?.files?.first?.cdnUri ??
        token.content?.files?.first?.uri   ??
        token.content?.links?.map["image"]
    }

    /// Price per token in USD (or backend‑specified currency)
    var price: Double? {
        token.tokenInfo?.priceInfo?.pricePerToken
    }

    /// Number of on‑chain holders (if backend gave the metric)
    var holders: Double? {
        token.tokenInfo?.holders ?? token.holders
    }

    /// Decimals for human supply calculation
    private var resolvedDecimals: Int {
        token.tokenInfo?.decimals ?? token.decimals ?? 0
    }

    /// Raw supply value from any source
    private var rawSupply: Decimal? {
        if let s = token.tokenInfo?.supply { return s }
        if let s = token.supply          { return Decimal(Double(s)) }
        return nil
    }

    /// Supply adjusted by decimals for UI (eg. 1 000 000.00)
    var currentSupply: Double? {
        guard let raw = rawSupply else { return nil }
        let divisor = pow(Decimal(10), resolvedDecimals)
        return (raw / divisor).doubleValue
    }

    /// Market capitalisation = price × supply (USD)
    var marketCap: Double? {
        guard let p = price, let s = currentSupply else { return nil }
        return p * s
    }



    /// Token code symbol (e.g., JUP)
    var symbol: String {
        token.content?.metadata?.symbol ?? token.tokenInfo?.symbol ?? "--"
    }

    /// Optional list of token metadata extensions (website, whitepaper, …)
    var tokenExtensions: [String: String] {
        token.content?.metadata?.extensions ?? [:]
    }

    /// First authority address or "--".
    var authority: String {
        guard let addr = token.authorities?.first?.address else { return "--" }
        return addr.abbreviated()
    }

    /// Program that owns the token (usually SPL‑Token)
    var ownerProgram: String {
        token.tokenInfo?.tokenProgram ?? "--"
    }

    /// Pretty helpers with fallback dash (use directly in Views)
    var displayPrice: String        { price        .map { $0.formatted2 } ?? "--" }
    var displayHolders: String      { holders      .map { $0.formatted0 } ?? "--" }
    var displayMarketCap: String    { marketCap    .map { $0.formatted2 } ?? "--" }
    var displayCurrentSupply: String{ currentSupply.map { $0.formatted2 } ?? "--" }
}

// MARK: - Handy primitives
extension String {
    /// "ABCDE..1234"
    func abbreviated(_ head: Int = 5, _ tail: Int = 5) -> String {
        guard count > head + tail else { return self }
        return "\(prefix(head))…\(suffix(tail))"
    }
}
private extension Double {
    /// 2‑decimal formatter
    var formatted2: String { String(format: "%.2f", self) }
    /// no‑decimal formatter
    var formatted0: String { String(format: "%.0f", self) }
}
private extension Decimal {
    var doubleValue: Double { NSDecimalNumber(decimal: self).doubleValue }
}
