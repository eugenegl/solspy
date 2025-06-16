import SwiftUI

struct MEVStatsCard: View {
    let statistics: MEVStatistics
    let isLoading: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Основная метрика - SOL Drained
            VStack(alignment: .leading, spacing: 6) {
                Text("SOL Drained")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(.white.opacity(0.7))
                
                HStack(alignment: .center, spacing: 6) {
                    // SOL иконка
                    Image("SolanaLogo")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 25, height: 25)
                    
                    if isLoading {
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(width: 120, height: 28)
                            .cornerRadius(4)
                    } else {
                        Text(statistics.formattedExtracted)
                            .font(.system(size: 28, weight: .regular))
                            .foregroundStyle(.red)
                    }
                }
            }
            
            // Сетка с остальными метриками
            LazyVGrid(columns: [
                GridItem(.flexible(), spacing: 0),
                GridItem(.flexible(), spacing: 0),
                GridItem(.flexible(), spacing: 0)
            ], alignment: .leading, spacing: 12) {
                // Attackers
                StatMetricView(
                    title: "Attackers",
                    value: "\(statistics.attackers)",
                    isLoading: isLoading,
                    color: .purple
                )
                
                // Sandwiches Count
                StatMetricView(
                    title: "Attacks",
                    value: statistics.formattedSandwiches,
                    isLoading: isLoading,
                    color: .orange
                )
                
                // Victims
                StatMetricView(
                    title: "Victims",
                    value: statistics.formattedVictims,
                    isLoading: isLoading,
                    color: .yellow
                )
            }
        }
        .padding(16)
        .background(
            ZStack {
                // Основной фон
                RoundedRectangle(cornerRadius: 15)
                    .fill(Color.black.opacity(0.3))
                
                // Красное свечение для украденных средств
                Circle()
                    .fill(Color.red.opacity(0.3))
                    .frame(width: 150, height: 150)
                    .blur(radius: 60)
                    .offset(x: 120, y: -80)
            }
            .clipped()
            .cornerRadius(15)
            .overlay(
                RoundedRectangle(cornerRadius: 15)
                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
            )
        )
        .padding(.horizontal, 20)
    }
}

struct StatMetricView: View {
    let title: String
    let value: String
    let isLoading: Bool
    let color: Color
    
    init(title: String, value: String, isLoading: Bool, color: Color = .white) {
        self.title = title
        self.value = value
        self.isLoading = isLoading
        self.color = color
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.system(size: 11, weight: .regular))
                .foregroundStyle(.white.opacity(0.6))
                .lineLimit(2)
                .multilineTextAlignment(.leading)
            
            if isLoading {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 50, height: 18)
                    .cornerRadius(4)
            } else {
                Text(value)
                    .font(.system(size: 16, weight: .regular))
                    .foregroundStyle(color)
                    .lineLimit(1)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview {
    VStack(spacing: 20) {
        MEVStatsCard(
            statistics: .mock,
            isLoading: false
        )
        
        MEVStatsCard(
            statistics: .mock,
            isLoading: true
        )
    }
    .padding()
    .background(Color(red: 0.027, green: 0.035, blue: 0.039))
} 
