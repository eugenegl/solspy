import SwiftUI

struct TopTokensWidget: View {
    let tokens: [TopToken]
    let isLoading: Bool
    @EnvironmentObject private var coordinator: NavigationCoordinator
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Заголовок секции
            HStack {
                Text("Top Tokens")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(.white)
                
                Spacer()
                
                if isLoading {
                    LoadingView()
                        .scaleEffect(0.4)
                }
            }
            .frame(height: 24) // Фиксированная высота заголовка как у других виджетов
            .padding(.horizontal, 20)
            
            // Список токенов (фиксированная высота как у транзакций)
            VStack(spacing: 6) {
                ForEach(0..<5, id: \.self) { index in
                    if tokens.isEmpty {
                        // Skeleton loading
                        TokenRowSkeleton()
                    } else if index < tokens.count {
                        // Реальный токен
                        TokenRow(token: tokens[index], rank: index + 1)
                            .onTapGesture {
                                coordinator.navigateToToken(address: tokens[index].address)
                            }
                    } else {
                        // Пустая строка для сохранения высоты
                        TokenRowSkeleton()
                            .opacity(0)
                    }
                }
            }
            .padding(.horizontal, 20)
            .frame(height: 170) // Фиксированная высота как у транзакций
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

struct TokenRow: View {
    let token: TopToken
    let rank: Int
    
    var body: some View {
        HStack(spacing: 12) {
            // Лого токена
            TokenImageView(token: token, size: 20)
            
            // Название и символ
            HStack(spacing: 4) {
                Text(token.name)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(.white)
                    .lineLimit(1)
                
                Text("(\(token.symbol))")
                    .font(.system(size: 12, weight: .regular))
                    .foregroundStyle(.white.opacity(0.6))
                    .lineLimit(1)
            }
            
            Spacer()
            
            // Market cap
            Text(token.formattedMarketCap)
                .font(.system(size: 12, weight: .regular))
                .foregroundStyle(.white.opacity(0.6))
            
            // Цена
            Text(token.formattedPrice)
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(.white)
            
        }
        .frame(height: 18) // Фиксированная высота строки как у транзакций
        .padding(.vertical, 6)
        .contentShape(Rectangle())
    }
}

struct TokenRowSkeleton: View {
    var body: some View {
        HStack(spacing: 12) {
            // Лого скелетон
            Circle()
                .fill(Color.gray.opacity(0.3))
                .frame(width: 20, height: 20)
            
            // Название скелетон
            Rectangle()
                .fill(Color.gray.opacity(0.3))
                .frame(width: 80, height: 14)
                .cornerRadius(4)
            
            Spacer()
            
            // Market cap скелетон
            Rectangle()
                .fill(Color.gray.opacity(0.3))
                .frame(width: 50, height: 12)
                .cornerRadius(4)
            
            // Цена скелетон
            Rectangle()
                .fill(Color.gray.opacity(0.3))
                .frame(width: 60, height: 14)
                .cornerRadius(4)
        }
        .frame(height: 18) // Фиксированная высота строки как у транзакций
        .padding(.vertical, 6)
    }
}

#Preview {
    VStack {
        TopTokensWidget(
            tokens: TopToken.mockTokens,
            isLoading: false
        )
        .environmentObject(NavigationCoordinator())
        
        TopTokensWidget(
            tokens: [],
            isLoading: true
        )
        .environmentObject(NavigationCoordinator())
    }
    .padding()
    .background(Color(red: 0.027, green: 0.035, blue: 0.039))
} 
