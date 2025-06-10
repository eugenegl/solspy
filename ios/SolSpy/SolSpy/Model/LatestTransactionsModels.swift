import Foundation

// MARK: - Latest Transactions Models (Mock Data)
struct LatestTransaction: Identifiable, Equatable {
    let id = UUID()
    let signature: String
    let blockNumber: Int
    let timeAgo: String
    let instructionType: String
    let instructionCount: Int
    
    var shortSignature: String {
        let start = String(signature.prefix(4))
        let end = String(signature.suffix(4))
        return "\(start)...\(end)"
    }
    
    // Equatable implementation
    static func == (lhs: LatestTransaction, rhs: LatestTransaction) -> Bool {
        return lhs.signature == rhs.signature &&
               lhs.blockNumber == rhs.blockNumber &&
               lhs.timeAgo == rhs.timeAgo &&
               lhs.instructionType == rhs.instructionType &&
               lhs.instructionCount == rhs.instructionCount
    }
}

// MARK: - Mock Data Provider
class MockTransactionsProvider {
    static func generateMockTransactions() -> [LatestTransaction] {
        let mockTransactions = [
            LatestTransaction(
                signature: "5RA6TFaKbS7ofN9mHUoFApzH2Lp3X4V8bGnE7zRtYu3k",
                blockNumber: 345870654,
                timeAgo: "25 secs ago",
                instructionType: "transfer",
                instructionCount: 3
            ),
            LatestTransaction(
                signature: "ytyYFvGMoXDY7yrHPKbN9ePqA4VtU8gH2sL6nR9pWxE7",
                blockNumber: 345870654,
                timeAgo: "25 secs ago",
                instructionType: "SetComputeUnitLimit",
                instructionCount: 1
            ),
            LatestTransaction(
                signature: "ahdwHTqU7nFtXgmoZcBvL5qR8sN4fY2kP6jD3wE9vXu1",
                blockNumber: 345870654,
                timeAgo: "25 secs ago",
                instructionType: "transfer",
                instructionCount: 1
            ),
            LatestTransaction(
                signature: "7UfKW7SeM9k17orYq8DcZ3vN4fP2bA5jH6gR1tE9wXu3",
                blockNumber: 345870654,
                timeAgo: "25 secs ago",
                instructionType: "transfer",
                instructionCount: 1
            ),
            LatestTransaction(
                signature: "5CKEq68U4D5iq2vjnM8pL7aR3bN9fY4kH2sG6wE1vXt2",
                blockNumber: 345870654,
                timeAgo: "25 secs ago",
                instructionType: "SetComputeUnitLimit",
                instructionCount: 1
            )
        ]
        return mockTransactions
    }
} 