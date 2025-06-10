import SwiftUI

struct SOLPriceWidget: View {
    let priceData: SOLPriceDisplay?
    let isLoading: Bool
    
    var body: some View {
        HStack {
            // Левая часть - цена и изменение
            VStack(alignment: .leading, spacing: 4) {
                // Цена с индикатором загрузки
                HStack(spacing: 8) {
                    ZStack(alignment: .leading) {
                        if let priceData = priceData {
                            Text(priceData.formattedPrice)
                                .font(.system(size: 24, weight: .semibold))
                                .foregroundStyle(.white)
                        } else {
                            // Плейсхолдер - прочерк когда нет данных
                            Text("--")
                                .font(.system(size: 24, weight: .semibold))
                                .foregroundStyle(.gray)
                        }
                    }
                    
                    // Индикатор загрузки рядом с ценой
                    if isLoading {
                        LoadingView()
                            .scaleEffect(0.5)
                    }
                }
                .frame(height: 28) // Фиксированная высота для цены
                
                // Изменение за 24 часа
                ZStack(alignment: .leading) {
                    if let priceData = priceData {
                        Text(priceData.formattedChange)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(priceData.isPositive ? 
                                           Color(red: 0.247, green: 0.918, blue: 0.286) : 
                                           Color.red)
                    } else {
                        // Плейсхолдер - прочерк для изменения цены
                        Text("--")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(.gray)
                    }
                }
                .frame(height: 18) // Фиксированная высота для изменения
            }
            
            Spacer()
            
            // Правая часть - логотип SOL и индикатор загрузки
            VStack(alignment: .center, spacing: 4) {
                ZStack {
                    // SOL логотип с fallback
                    ZStack {
                        // Проверяем, есть ли изображение SolanaLogo
                        if UIImage(named: "SolanaLogo") != nil {
                            Image("SolanaLogo")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 32, height: 32)
                        } else {
                            // Fallback - современный стилизованный логотип SOL
                            ZStack {
                                Circle()
                                    .fill(
                                        LinearGradient(
                                            colors: [
                                                Color(red: 0.2, green: 0.8, blue: 1.0),
                                                Color(red: 0.6, green: 0.4, blue: 1.0),
                                                Color(red: 0.9, green: 0.3, blue: 0.8)
                                            ],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .frame(width: 32, height: 32)
                                
                                // Стилизованный символ SOL
                                Text("⬣")
                                    .font(.system(size: 20, weight: .bold))
                                    .foregroundStyle(.white)
                                    .shadow(color: .black.opacity(0.3), radius: 1, x: 0, y: 1)
                            }
                        }
                    }
                }
                .frame(width: 32, height: 32) // Фиксированный размер
                
                
                Text("SOL")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(.white.opacity(0.7))
            }
        }
        .frame(height: 56) // Фиксированная высота контента
        .padding(.horizontal, 20)
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

#Preview {
    VStack(spacing: 20) {
        // С данными
        SOLPriceWidget(
            priceData: SOLPriceDisplay(from: SOLPrice(usd: 160.67, usd24hChange: 2.37)),
            isLoading: false
        )
        
        // Загрузка
        SOLPriceWidget(
            priceData: nil,
            isLoading: true
        )
        
        // Отрицательное изменение
        SOLPriceWidget(
            priceData: SOLPriceDisplay(from: SOLPrice(usd: 148.32, usd24hChange: -1.25)),
            isLoading: false
        )
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color(red: 0.027, green: 0.035, blue: 0.039))
} 
