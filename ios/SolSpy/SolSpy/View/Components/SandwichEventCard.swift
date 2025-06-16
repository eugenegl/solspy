import SwiftUI

struct SandwichEventCard: View {
    let event: SandwichEvent
    let onCopyTransaction: ((String) -> Void)?
    
    init(event: SandwichEvent, onCopyTransaction: ((String) -> Void)? = nil) {
        self.event = event
        self.onCopyTransaction = onCopyTransaction
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Хедер с основной информацией
            HStack(alignment: .top, spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    
                    // Время и источник
                    HStack(spacing: 8) {
                        
                        Text("\(event.slot)")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(.white.opacity(0.7))
                        
                        Spacer()
                        
                        // Источник с цветом
                        Text(event.source.uppercased())
                            .font(.system(size: 10, weight: .bold))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(Color.gray.opacity(0.2))
                            )
                    }
                    
                    Text(event.timeAgo)
                        .font(.system(size: 10, weight: .medium))
                        .foregroundStyle(.white.opacity(0.5))
                }
                
            }
            
            // Детали транзакции
            VStack(spacing: 8) {
                // Атакующий
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Attacker")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundStyle(.red.opacity(0.8))
                        
                        Text(event.shortWalletAddress)
                            .font(.system(size: 12, weight: .medium))
                            .foregroundStyle(.white)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 2) {
                        Text("Token")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundStyle(.white.opacity(0.6))
                        
                        Text(event.shortTokenAddress)
                            .font(.system(size: 12, weight: .medium))
                            .foregroundStyle(.white)
                    }
                }
                
                // Разделитель
                Rectangle()
                    .fill(Color.white.opacity(0.1))
                    .frame(height: 1)
                
                // Жертва
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Victim")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundStyle(.orange.opacity(0.8))
                        
                        Text(event.shortVictimAddress)
                            .font(.system(size: 12, weight: .medium))
                            .foregroundStyle(.white)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 2) {
                        Text("Amount In")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundStyle(.white.opacity(0.6))
                        
                        HStack(spacing: 2) {
                            Text(event.formattedVictimAmount)
                                .font(.system(size: 12, weight: .medium))
                                .foregroundStyle(.white)
                            
                            Text("SOL")
                                .font(.system(size: 10, weight: .medium))
                                .foregroundStyle(.white.opacity(0.7))
                        }
                    }
                }
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.white.opacity(0.05))
            )
            
            // Хеши транзакций (опционально)
            HStack(spacing: 4) {
                // Украденная сумма (главная метрика)
                HStack(spacing: 4) {
                    Image("SolanaLogo")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 16, height: 16)
                    
                    Text(event.formattedSolDrained)
                        .font(.system(size: 18, weight: .regular))
                        .foregroundStyle(.red)
                    
                    Text("SOL Drained")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(.white.opacity(0.6))
                }
                
                Spacer()
                
                Button(action: {
                    // Используем колбек если есть, иначе копируем напрямую
                    if let onCopy = onCopyTransaction {
                        onCopy(event.txHashBuy)
                    } else {
                        UIPasteboard.general.string = event.txHashBuy
                    }
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: "doc.on.doc")
                            .font(.system(size: 10))
                        Text("Copy TX")
                            .font(.system(size: 10, weight: .medium))
                    }
                    .foregroundStyle(.green.opacity(0.7))
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color.black.opacity(0.4))
                .overlay(
                    RoundedRectangle(cornerRadius: 15)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
        )
        .padding(.horizontal, 20)
    }
}

#Preview {
    ScrollView {
        VStack(spacing: 12) {
            // Создаем мок данные для превью
            SandwichEventCard(
                event: SandwichEvent(
                tokenAddress: "EkfdYHF9n3jKNV1zgRWAZXDFUtkF7qLCqAMERfWVpump",
                walletAddress: "AtTjQKXo1CYTa2MuxPARtr382ZyhPU5YX4wMMpvaa1oy",
                solDrained: 0.082763832,
                txHashBuy: "3eh4CdwNxbuf9NzvgHcGNLLGzF7N6LKVVKie4c1x29m4RXe5XmAG6JqUScMFespZGyKjCPVVzw8TyiCy23auz8nB",
                txHashSell: "CWJMyzSiZSBFyDd6oE98pAqocRWTSPTrgMfL6AV3zE3GnRvJpRjE2V9D1eHPFmNNxgtXjiCgAA9Dwh79fLF1eW7",
                victimWalletAddress: "DzZeMyunGCsP6p3N5VQ5376ARkzYHLQjxJyUnmPGdgT5",
                victimAmountIn: 4.241447682,
                victimTxHash: "5YV5sMkdkJavqJqpLhXNgdDFZW773QiBaEv4S6LzHvanzLAC2bj4doZbZ68wbtFeJmvyDcvamEyT9GkqfrMrCgEB",
                slot: 347107431,
                source: "pump",
                createdAt: "2025-06-16T05:29:23.000Z"
                ),
                onCopyTransaction: { txHash in
                    print("Copied: \(txHash)")
                }
            )
            
            SandwichEventCard(
                event: SandwichEvent(
                    tokenAddress: "BWZNwv1tfkpcef56oD3HUkxvKvw5Wz8RQuJUAEYfpump",
                    walletAddress: "AtTjQKXo1CYTa2MuxPARtr382ZyhPU5YX4wMMpvaa1oy",
                    solDrained: 0.019638205,
                    txHashBuy: "22op9bmXuEhmtwvuK4dHNPUqDzwLmzwScLbkSDWV4pfxjPAJJdssnWii9mPFPvYnb86aG67ubAAZHA1syTvxox5i",
                    txHashSell: "4cErD2DofnmYDBhZsXPWQ7K4coHKqLJKrLXL7w2WKBKvJsx6H2zjZwxEDoaCzHWu8Wd95LGTvnSuCyfMmowPqs4n",
                    victimWalletAddress: "8bXYWSJpAmdS8yMQsTJq5hoyfjdd214EYXvexmYwUBY3",
                    victimAmountIn: 0.304138634,
                    victimTxHash: "DEJkgHY7wRBRZ81G9F8JuXcB6HLnkbHQevmHxwoFgvz37yTRaQGB88JVFHgTVwGZgmHcHwnxT5XAyU6vBh1CboN",
                    slot: 347107417,
                    source: "pumpswap",
                    createdAt: "2025-06-16T05:29:17.000Z"
                ),
                onCopyTransaction: { txHash in
                    print("Copied: \(txHash)")
                }
            )
        }
    }
    .background(Color(red: 0.027, green: 0.035, blue: 0.039))
} 
