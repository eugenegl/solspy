import Foundation
import SwiftUI

@MainActor
final class MEVTrackerViewModel: ObservableObject {
    
    // MARK: - Published Properties
    @Published var statistics: MEVStatistics = .mock
    @Published var sandwichEvents: [SandwichEvent] = []
    @Published var isLoading: Bool = false
    @Published var selectedTimeFilter: MEVAPIService.TimeFilter = .thirtyDays
    @Published var errorMessage: String?
    
    // MARK: - Private Properties
    private let apiService = MEVAPIService.shared
    
    // MARK: - Initialization
    init() {
        Task {
            await loadInitialData()
        }
    }
    
    // MARK: - Public Methods
    func refreshData() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let response = try await apiService.fetchSandwiches(days: selectedTimeFilter)
            
            // Обновляем статистику
            statistics = MEVStatistics(from: response.stats)
            
            // Обновляем события
            sandwichEvents = response.sandwiches
            
            isLoading = false
            
        } catch {
            print("❌ Error loading MEV data: \(error)")
            errorMessage = error.localizedDescription
            isLoading = false
        }
    }
    
    func changeTimeFilter(_ filter: MEVAPIService.TimeFilter) {
        selectedTimeFilter = filter
        Task {
            await refreshData()
        }
    }
    
    // MARK: - Private Methods
    private func loadInitialData() async {
        await refreshData()
    }
    
    // MARK: - Legacy Support (for existing UI components)
    
    // Convert sandwich events to legacy stream events for backwards compatibility
    var streamEvents: [MEVStreamEvent] {
        return sandwichEvents.prefix(20).map { event in
            let dateFormatter = ISO8601DateFormatter()
            dateFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
            let timestamp = dateFormatter.date(from: event.createdAt) ?? Date()
            
            let actions = [
                MEVAction(
                    type: .bot,
                    address: event.shortWalletAddress,
                    amount: event.solDrained,
                    token: "SOL",
                    blockNumber: event.slot,
                    nickname: "Bot"
                ),
                MEVAction(
                    type: .victim,
                    address: event.shortVictimAddress,
                    amount: event.victimAmountIn,
                    token: "SOL",
                    blockNumber: event.slot,
                    nickname: "Victim"
                )
            ]
            
            return MEVStreamEvent(
                id: event.id,
                timestamp: timestamp,
                station: event.source.capitalized,
                tokens: ["SOL"],
                actions: actions
            )
        }
    }
    
    // Legacy time filter enum for backward compatibility
    enum TimeFilter: String, CaseIterable {
        case oneDay = "1D"
        case threeDays = "3D"
        case sevenDays = "7D"
        case thirtyDays = "30D"
        
        var displayName: String {
            switch self {
            case .oneDay: return "last 1D"
            case .threeDays: return "last 3D"
            case .sevenDays: return "last 7D"
            case .thirtyDays: return "last 30D"
            }
        }
        
        var apiFilter: MEVAPIService.TimeFilter {
            switch self {
            case .oneDay: return .oneDay
            case .threeDays: return .threeDays
            case .sevenDays: return .sevenDays
            case .thirtyDays: return .thirtyDays
            }
        }
    }
    
    var legacyTimeFilter: TimeFilter {
        switch selectedTimeFilter {
        case .oneDay: return .oneDay
        case .threeDays: return .threeDays
        case .sevenDays: return .sevenDays
        case .thirtyDays: return .thirtyDays
        }
    }
} 