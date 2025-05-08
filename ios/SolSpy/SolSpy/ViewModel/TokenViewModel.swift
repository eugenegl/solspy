import Foundation
import SwiftUI
import Combine

class TokenViewModel: ObservableObject {
    @Published var tokenData: TokenResponse?
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var transactions: [Transaction] = []
    @Published var showShareSheet = false
    @Published var showCopiedToast = false
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        loadTokenData()
    }
    
    // MARK: - Data loading
    func loadTokenData() {
        isLoading = true
        errorMessage = nil
        
        // Simulate network by loading local mock data
        loadMockData()
    }
    
    func refreshData() {
        errorMessage = nil
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
            self?.loadMockData()
        }
    }
    
    private func loadMockData() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            guard let self = self else { return }
            
            if let data = self.loadMockJSONData() {
                do {
                    let decoder = JSONDecoder()
                    self.tokenData = try decoder.decode(TokenResponse.self, from: data)
                    self.generateMockTransactions()
                } catch {
                    self.errorMessage = "Failed to decode token data: \(error.localizedDescription)"
                }
            }
            
            self.isLoading = false
        }
    }
    
    private func loadMockJSONData() -> Data? {
        guard let url = Bundle.main.url(forResource: "Token", withExtension: "json") else {
            // Fallback: use embedded string (from attached file)
            let jsonString = """
            {
                "address": "DezXAZ8z7PnrnRJjz3wXBoRgixCa6xjnB7YaB1pPB263",
                "type": "TOKEN",
                "token": {
                    "interface": "FungibleToken",
                    "id": "DezXAZ8z7PnrnRJjz3wXBoRgixCa6xjnB7YaB1pPB263",
                    "content": {
                        "$schema": "https://schema.metaplex.com/nft1.0.json",
                        "json_uri": "https://arweave.net/QPC6FYdUn-3V8ytFNuoCS85S2tHAuiDblh6u3CIZLsw",
                        "files": [
                            {
                                "uri": "https://arweave.net/hQiPZOsRZXGXBJd_82PhVdlM_hACsT_q6wqwf5cSY7I",
                                "cdn_uri": "https://cdn.helius-rpc.com/cdn-cgi/image//https://arweave.net/hQiPZOsRZXGXBJd_82PhVdlM_hACsT_q6wqwf5cSY7I",
                                "mime": "image/png"
                            }
                        ],
                        "metadata": {
                            "description": "The Official Bonk Inu token",
                            "name": "Bonk",
                            "symbol": "Bonk",
                            "token_standard": "Fungible"
                        },
                        "links": {
                            "image": "https://arweave.net/hQiPZOsRZXGXBJd_82PhVdlM_hACsT_q6wqwf5cSY7I"
                        }
                    },
                    "authorities": [
                        {
                            "address": "9AhKqLR67hwapvG8SA2JFXaCshXc9nALJjpKaHZrsbkw",
                            "scopes": [
                                "full"
                            ]
                        }
                    ],
                    "royalty": {
                        "royalty_model": "creators",
                        "target": null,
                        "percent": 0,
                        "basis_points": 0
                    },
                    "token_info": {
                        "symbol": "Bonk",
                        "supply": 8882739578526980000,
                        "decimals": 5,
                        "token_program": "TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA",
                        "price_info": {
                            "price_per_token": 0.0000170848,
                            "currency": "USDC"
                        }
                    }
                }
            }
            """
            return jsonString.data(using: .utf8)
        }
        return try? Data(contentsOf: url)
    }
    
    // MARK: - Mock Transactions
    private func generateMockTransactions() {
        let now = Date()
        let day: TimeInterval = 86400
        let randomAddress = "5KV9Z32iNZoDLSzBg8xzBB7JkvKUgvjSyhn"
        
        let transaction1 = Transaction(type: .transfer, amount: 1_000.0, tokenSymbol: "BONK", date: now.addingTimeInterval(-2 * day), address: randomAddress, isIncoming: true)
        let transaction2 = Transaction(type: .burn, amount: 500.0, tokenSymbol: "BONK", date: now.addingTimeInterval(-5 * day), address: randomAddress)
        let transaction3 = Transaction(type: .generic, amount: nil, tokenSymbol: nil, date: now.addingTimeInterval(-9 * day), address: randomAddress)
        
        transactions = [transaction1, transaction2, transaction3]
    }
    
    // MARK: - Helper computed strings for UI
    var tokenName: String {
        tokenData?.name ?? "--"
    }
    
    var tokenSymbol: String {
        tokenData?.symbol ?? "--"
    }
    
    var priceFormatted: String {
        guard let price = tokenData?.pricePerToken else { return "--" }
        return price.formatAsCurrency()
    }
    
    var marketCapFormatted: String {
        guard let data = tokenData else { return "--" }
        return data.marketCap.formatAsCurrency()
    }
    
    var currentSupplyFormatted: String {
        guard let data = tokenData else { return "--" }
        return data.uiSupply.formatAsTokenAmount()
    }
    
    var decimalsFormatted: String {
        "\(tokenData?.decimals ?? 0)"
    }
    
    var authorityShort: String {
        tokenData?.authorityShort ?? "--"
    }
    
    var tokenAddressShort: String {
        tokenData?.shortAddress ?? "--"
    }
    
    var logoURL: String? {
        tokenData?.logoURL
    }
    
    // Полный адрес authority (если есть)
    var fullAuthorityAddress: String {
        tokenData?.token.authorities?.first?.address ?? "--"
    }
    
    var creatorAddresses: [String] {
        // В примере массива нет, возвращаем пустой массив или плейсхелдер
        // tokenData?.token.creators?
        return []
    }
    
    // MARK: - Navigation & Share helpers
    func goBack() {
        print("Navigating back")
    }
    
    func copyTokenLink() {
        guard let address = tokenData?.address else { return }
        let link = "solspy://token/\(address)"
        UIPasteboard.general.string = link
        showCopiedToast = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
            self?.showCopiedToast = false
        }
    }
    
    func shareToken() {
        showShareSheet = true
    }
    
    func getShareItems() -> [Any] {
        var items: [Any] = []
        if let name = tokenName as String? { items.append("Token: \(name)") }
        if let address = tokenData?.address {
            items.append("Address: \(address)")
            if let url = URL(string: "https://solspy.app/token/\(address)") {
                items.append(url)
            }
        }
        return items
    }
} 