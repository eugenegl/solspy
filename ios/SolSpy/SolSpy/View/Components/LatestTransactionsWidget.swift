import SwiftUI

struct LatestTransactionsWidget: View {
    let transactions: [LatestTransaction]
    let isLoading: Bool
    let webSocketStatus: String
    let isWebSocketConnected: Bool
    @EnvironmentObject private var coordinator: NavigationCoordinator
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Заголовок с WebSocket статусом
            HStack {
                Text("Latest Transactions")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(.white)
                
                Spacer()
                
                // Фиксированное место для индикатора загрузки
                ZStack {
                    if isLoading {
                        LoadingView()
                            .scaleEffect(0.4)
                    }
                }
                .frame(width: 30, height: 20) // Фиксированный размер
                
                // Индикатор статуса WebSocket
                HStack(spacing: 4) {
                    Circle()
                        .fill(isWebSocketConnected ? Color.green : Color.red)
                        .frame(width: 6, height: 6)
                    
                    Text(webSocketStatus)
                        .font(.system(size: 10, weight: .medium))
                        .foregroundStyle(isWebSocketConnected ? Color.green : Color.gray)
                }
                
                
            }
            .frame(height: 24) // Фиксированная высота заголовка
            .padding(.horizontal, 20)
            
            // Список транзакций (фиксированная высота для предотвращения скачков)
            VStack(spacing: 6) {
                ForEach(0..<5, id: \.self) { index in
                    if transactions.isEmpty {
                        // Skeleton loading
                        TransactionSkeletonRow()
                    } else if index < transactions.count {
                        // Реальная транзакция
                        TransactionRow(transaction: transactions[index])
                            .onTapGesture {
                                coordinator.showTransaction(signature: transactions[index].signature)
                            }
                    } else {
                        // Пустая строка для сохранения высоты
                        TransactionSkeletonRow()
                            .opacity(0)
                    }
                }
            }
            .padding(.horizontal, 20)
            .frame(height: 170) // Фиксированная высота: 5 строк * 30px на строку (18px + 12px padding)
            

        }
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color.black.opacity(0.3))
                .overlay(
                    RoundedRectangle(cornerRadius: 15)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
        )
        .padding(.horizontal, 20)
    }
}

struct TransactionRow: View {
    let transaction: LatestTransaction
    
    var body: some View {
        HStack(spacing: 12) {
            // Подпись транзакции
            Text(transaction.shortSignature)
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(Color(red: 0.3, green: 0.7, blue: 1.0)) 
            
            // Время
            Text(transaction.timeAgo)
                .font(.system(size: 12, weight: .regular))
                .foregroundStyle(.white.opacity(0.6))
            
            Spacer()
            
            // Тип инструкции
            InstructionTypeBadge(
                type: transaction.instructionType,
                count: transaction.instructionCount
            )
        }
        .frame(height: 18) // Фиксированная высота строки (как у skeleton)
        .padding(.vertical, 6)
    }
}

struct InstructionTypeBadge: View {
    let type: String
    let count: Int
    
    var body: some View {
        HStack(spacing: 4) {
            Text(type)
                .font(.system(size: 10, weight: .medium))
                .foregroundStyle(.white)
            
            if count > 1 {
                Text("\(count)+")
                    .font(.system(size: 9, weight: .bold))
                    .foregroundStyle(.white)
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(type == "transfer" ? 
                     Color.gray.opacity(0.6) : 
                     Color(red: 0.4, green: 0.6, blue: 0.8).opacity(0.6))
        )
    }
}

struct TransactionSkeletonRow: View {
    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(Color.gray.opacity(0.3))
                .frame(width: 8, height: 8)
            
            Rectangle()
                .fill(Color.gray.opacity(0.3))
                .frame(width: 80, height: 14)
                .cornerRadius(4)
            
            Spacer()
            
            Rectangle()
                .fill(Color.gray.opacity(0.3))
                .frame(width: 60, height: 12)
                .cornerRadius(4)
            
            Rectangle()
                .fill(Color.gray.opacity(0.3))
                .frame(width: 70, height: 12)
                .cornerRadius(4)
            
            Rectangle()
                .fill(Color.gray.opacity(0.3))
                .frame(width: 50, height: 20)
                .cornerRadius(8)
        }
        .frame(height: 18) // Фиксированная высота строки (как у TransactionRow)
        .padding(.vertical, 6)
    }
}

#Preview {
    VStack(spacing: 20) {
        // С данными
        LatestTransactionsWidget(
            transactions: MockTransactionsProvider.generateMockTransactions(),
            isLoading: false,
            webSocketStatus: "Live",
            isWebSocketConnected: true
        )
        .environmentObject(NavigationCoordinator())
        
        // Загрузка
        LatestTransactionsWidget(
            transactions: [],
            isLoading: true,
            webSocketStatus: "Connecting...",
            isWebSocketConnected: false
        )
        .environmentObject(NavigationCoordinator())
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color(red: 0.027, green: 0.035, blue: 0.039))
} 
