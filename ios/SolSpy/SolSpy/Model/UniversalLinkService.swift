import Foundation
import UIKit

// Сервис для управления Universal Links и deep links
class UniversalLinkService {
    static let shared = UniversalLinkService()
    
    // Флаг для включения/выключения кнопок шаринга 
    // Установите в true когда настроите сервер и приложение будет в App Store
    static let isUniversalLinksEnabled = false
    
    // ID приложения в App Store (нужно заменить на реальный)
    private let appStoreId = "123456789"
    
    // URL домена для Universal Links
    private let universalLinkDomain = "https://solspy.app"
    
    private init() {}
    
    // MARK: - Universal Link генерация
    
    /// Генерирует Universal Link для кошелька
    func generateWalletUniversalLink(address: String) -> URL? {
        return URL(string: "\(universalLinkDomain)/wallet/\(address)")
    }
    
    /// Генерирует Universal Link для токена
    func generateTokenUniversalLink(address: String) -> URL? {
        return URL(string: "\(universalLinkDomain)/token/\(address)")
    }
    
    /// Генерирует Universal Link для транзакции
    func generateTransactionUniversalLink(signature: String) -> URL? {
        return URL(string: "\(universalLinkDomain)/tx/\(signature)")
    }
    
    // MARK: - Deep Link генерация (fallback)
    
    /// Генерирует deep link для кошелька
    func generateWalletDeepLink(address: String) -> URL? {
        return URL(string: "solspy://wallet/\(address)")
    }
    
    /// Генерирует deep link для токена
    func generateTokenDeepLink(address: String) -> URL? {
        return URL(string: "solspy://token/\(address)")
    }
    
    /// Генерирует deep link для транзакции
    func generateTransactionDeepLink(signature: String) -> URL? {
        return URL(string: "solspy://transaction/\(signature)")
    }
    
    // MARK: - App Store Link
    
    /// Генерирует ссылку на App Store
    func generateAppStoreLink() -> URL? {
        return URL(string: "https://apps.apple.com/app/id\(appStoreId)")
    }
    
    // MARK: - Smart Link генерация (Universal Link + fallback)
    
    /// Генерирует умную ссылку, которая попытается открыть приложение, иначе App Store
    func generateSmartWalletLink(address: String) -> URL? {
        // Возвращаем Universal Link, который iOS автоматически обработает
        return generateWalletUniversalLink(address: address)
    }
    
    /// Генерирует умную ссылку для токена
    func generateSmartTokenLink(address: String) -> URL? {
        return generateTokenUniversalLink(address: address)
    }
    
    /// Генерирует умную ссылку для транзакции
    func generateSmartTransactionLink(signature: String) -> URL? {
        return generateTransactionUniversalLink(signature: signature)
    }
    
    // MARK: - Copy to clipboard
    
    /// Копирует ссылку на кошелек в буфер обмена
    func copyWalletLink(address: String) {
        guard let link = generateSmartWalletLink(address: address) else { return }
        UIPasteboard.general.string = link.absoluteString
    }
    
    /// Копирует ссылку на токен в буфер обмена
    func copyTokenLink(address: String) {
        guard let link = generateSmartTokenLink(address: address) else { return }
        UIPasteboard.general.string = link.absoluteString
    }
    
    /// Копирует ссылку на транзакцию в буфер обмена
    func copyTransactionLink(signature: String) {
        guard let link = generateSmartTransactionLink(signature: signature) else { return }
        UIPasteboard.general.string = link.absoluteString
    }
    
    // MARK: - Share items generation
    
    /// Генерирует элементы для шаринга кошелька
    func generateWalletShareItems(address: String, walletData: WalletResponse?) -> [Any] {
        var items: [Any] = []
        
        // Добавляем описание
        items.append("Solana Wallet")
        
        // Добавляем адрес
        items.append("Address: \(address)")
        
        // Добавляем Universal Link
        if let link = generateSmartWalletLink(address: address) {
            items.append(link)
        }
        
        return items
    }
    
    /// Генерирует элементы для шаринга токена
    func generateTokenShareItems(address: String, tokenName: String) -> [Any] {
        var items: [Any] = []
        
        // Добавляем описание
        items.append("Token: \(tokenName)")
        items.append("Address: \(address)")
        
        // Добавляем Universal Link
        if let link = generateSmartTokenLink(address: address) {
            items.append(link)
        }
        
        return items
    }
    
    /// Генерирует элементы для шаринга транзакции
    func generateTransactionShareItems(signature: String) -> [Any] {
        var items: [Any] = []
        
        // Добавляем описание
        items.append("Transaction: \(signature)")
        
        // Добавляем Universal Link
        if let link = generateSmartTransactionLink(signature: signature) {
            items.append(link)
        }
        
        return items
    }
} 