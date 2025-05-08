import SwiftUI

struct TokenListView: View {
    @ObservedObject var viewModel: WalletViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            Color(red: 0.027, green: 0.035, blue: 0.039).ignoresSafeArea()
            
            VStack(spacing: 15) {
                // Заголовок с кнопкой закрытия
                HStack {
                    Text("Tokens")
                        .font(.system(size: 20, weight: .regular))
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "xmark")
                            .foregroundColor(.white.opacity(0.7))
                            .padding(10)
                            .background(Color.white.opacity(0.1))
                            .clipShape(Circle())
                    }
                }
                .padding(.horizontal)
                .padding(.top, 20)
                
                // Токены
                ScrollView {
                    VStack(spacing: 12) {
                        // SOL токен
                        if let solBalance = viewModel.walletData?.balance {
                            TokenRowView(
                                logo: solBalance.logo,
                                symbol: solBalance.symbol,
                                name: solBalance.name,
                                amount: solBalance.uiAmount,
                                usdValue: solBalance.priceInfo.totalPrice
                            )
                        }
                        
                        // Другие токены
                        if let assets = viewModel.walletData?.assets, !assets.isEmpty {
                            ForEach(assets, id: \.address) { asset in
                                TokenRowView(
                                    logo: asset.logo,
                                    symbol: asset.symbol,
                                    name: asset.name,
                                    amount: asset.uiAmount,
                                    usdValue: asset.priceInfo.totalPrice
                                )
                            }
                        } else if viewModel.walletData?.balance == nil {
                            // Пустое состояние только если и SOL нет
                            EmptyTokensView()
                        }
                    }
                    .padding(.horizontal)
                }
            }
        }
        .foregroundStyle(.white)
    }
}

// Компонент для отображения строки с токеном
struct TokenRowView: View {
    let logo: String?
    let symbol: String
    let name: String
    let amount: Double
    let usdValue: Double
    
    var body: some View {
        HStack {
            // Логотип
            TokenLogoView(
                logoUrl: logo,
                symbol: symbol
            )
            
            // Информация о токене
            VStack(alignment: .leading, spacing: 2) {
                Text(symbol)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                
                Text(name)
                    .font(.system(size: 12))
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            // Баланс и стоимость
            VStack(alignment: .trailing, spacing: 2) {
                Text(amount.formatAsTokenAmount())
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                
                Text(usdValue.formatAsCurrency())
                    .font(.system(size: 12))
                    .foregroundColor(.gray)
            }
        }
        .padding(.vertical, 14)
        .padding(.horizontal, 16)
        .background(Color.white.opacity(0.05))
        .cornerRadius(12)
    }
}

// Пустое состояние
struct EmptyTokensView: View {
    var body: some View {
        VStack(spacing: 10) {
            Image(systemName: "banknote")
                .font(.system(size: 40))
                .foregroundColor(.gray)
            
            Text("No tokens found")
                .font(.headline)
                .foregroundColor(.white)
            
            Text("Your tokens will appear here")
                .font(.caption)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 60)
    }
}

#Preview {
    TokenListView(viewModel: WalletViewModel())
} 
