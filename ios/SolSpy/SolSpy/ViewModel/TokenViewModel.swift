//  TokenViewModel.swift
//  SolSpy
//
//  Refactored 13‑05‑2025 for the new TokenResponse helpers
//  – Replaced legacy field names (pricePerToken, uiSupply, resolvedDecimals …)
//    with the fresh API from TokenModels.swift
//  – View‑only helpers now use safe fallbacks ("--") via new convenience props
//  – Debug print updated for clarity
//
import Foundation
import SwiftUI
import Combine

final class TokenViewModel: ObservableObject {
    // MARK: – State
    @Published var tokenData: TokenResponse?
    @Published var isLoading  = false
    @Published var errorMessage: String?
    @Published var transactions: [Transaction] = []
    @Published var showShareSheet  = false
    @Published var showCopiedToast = false
    @Published var showToast       = false
    @Published var toastMessage    = ""

    private let tokenAddress: String?

    // MARK: – Init
    init(address: String? = nil) {
        self.tokenAddress = address?.isEmpty == true ? nil : address
        loadTokenData()
    }

    // MARK: – Network
    func loadTokenData() {
        guard let addr = tokenAddress, !addr.isEmpty else { loadMockData(); return }
        isLoading = true; errorMessage = nil

        Task {
            do {
                let entity = try await SolSpyAPI.shared.search(address: addr)
                if case .token(let token) = entity {
                    await MainActor.run {
                        debugPrint("🔹 Token loaded:", token.title, "price:", token.price ?? 0)
                        self.tokenData = token
                        self.isLoading = false
                    }
                } else {
                    await MainActor.run {
                        self.errorMessage = "Expected token data, received different type."
                        self.isLoading = false
                    }
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = error.localizedDescription
                    self.isLoading = false
                }
            }
        }
    }

    func refreshData() { loadTokenData() }

    // MARK: – Mocks (коротко)
    private func loadMockData() { 
        isLoading = false 
    }

    // MARK: – UI helpers
    var tokenName: String { tokenData?.title ?? "--" }
    var tokenSymbol: String { tokenData?.symbol ?? "--" }

    var priceFormatted: String {
        tokenData?.price.map { $0.formatAsCurrency() } ?? "--"
    }
    var marketCapFormatted: String {
        tokenData?.marketCap.map { $0.formatAsCurrency() } ?? "--"
    }
    var currentSupplyFormatted: String {
        tokenData?.currentSupply.map { $0.formatAsTokenAmount() } ?? "--"
    }
    var decimalsFormatted: String {
        if let dec = tokenData?.token.tokenInfo?.decimals ?? tokenData?.token.decimals { return "\(dec)" }
        return "--"
    }

    var authorityShort: String { tokenData?.authority ?? "--" }
    var tokenAddressShort: String { tokenData?.address.abbreviated() ?? "--" }
    var logoURL: String? { tokenData?.iconURL }

    var fullAuthorityAddress: String {
        tokenData?.token.authorities?.first?.address ?? "--"
    }

    // MARK: – Navigation & share
    func goBack() {
        NotificationCenter.default.post(name: .tokenViewShouldDismiss, object: nil)
    }

    func copyTokenLink() {
        guard let addr = tokenData?.address else { return }
        UniversalLinkService.shared.copyTokenLink(address: addr)
        showCopiedToast = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { self.showCopiedToast = false }
    }
    
    func copyTokenAddress() {
        guard let addr = tokenData?.address else { return }
        UIPasteboard.general.string = addr
        showToast(message: "Address copied")
    }
    func shareToken() { showShareSheet = true }
    func getShareItems() -> [Any] {
        guard let addr = tokenData?.address else { return [] }
        return UniversalLinkService.shared.generateTokenShareItems(
            address: addr,
            tokenName: tokenName
        )
    }

    // MARK: – Toast helper
    func showToast(message: String) {
        toastMessage = message
        showToast = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { self.showToast = false }
    }
}

extension Notification.Name {
    static let tokenViewShouldDismiss = Notification.Name("tokenViewShouldDismiss")
}
