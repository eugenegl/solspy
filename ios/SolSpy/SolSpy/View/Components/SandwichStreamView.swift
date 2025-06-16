import SwiftUI

struct SandwichStreamView: View {
    let events: [SandwichEvent]
    let isLoading: Bool
    let onCopyTransaction: ((String) -> Void)?
    
    init(events: [SandwichEvent], isLoading: Bool, onCopyTransaction: ((String) -> Void)? = nil) {
        self.events = events
        self.isLoading = isLoading
        self.onCopyTransaction = onCopyTransaction
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Заголовок секции
            HStack {
                Text("Recent Sandwich Attacks")
                    .font(.system(size: 18, weight: .regular))
                    .foregroundStyle(.white)
                
                Spacer()
                
                // Индикатор обновления
                HStack(spacing: 4) {
                    if isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .gray))
                            .scaleEffect(0.6)
                        
                        Text("updating...")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundStyle(.gray.opacity(0.7))
                    } else {
                        Image(systemName: "arrow.clockwise")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundStyle(.gray.opacity(0.7))
                        
                        Text("pull to refresh")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundStyle(.gray.opacity(0.7))
                    }
                }
            }
            .padding(.horizontal, 20)
            
            // Список событий
            VStack(spacing: 12) {
                ForEach(events) { event in
                    SandwichEventCard(
                        event: event,
                        onCopyTransaction: onCopyTransaction
                    )
                    .transition(.asymmetric(
                        insertion: .move(edge: .top).combined(with: .opacity),
                        removal: .opacity
                    ))
                }
                
                if events.isEmpty && !isLoading {
                    EmptySandwichView()
                        .padding(.horizontal, 20)
                } else if events.isEmpty && isLoading {
                    LoadingSandwichView()
                        .padding(.horizontal, 20)
                }
            }
        }
    }
}

struct EmptySandwichView: View {
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "shield.slash")
                .font(.system(size: 32))
                .foregroundStyle(.white.opacity(0.3))
            
            Text("No sandwich attacks found")
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(.white.opacity(0.5))
            
            Text("Pull to refresh or try a different time filter")
                .font(.system(size: 12, weight: .regular))
                .foregroundStyle(.white.opacity(0.4))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }
}

struct LoadingSandwichView: View {
    var body: some View {
        VStack(spacing: 12) {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: .green))
                .scaleEffect(1.2)
            
            Text("Loading sandwich attacks...")
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(.white.opacity(0.5))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }
}

#Preview {
    ScrollView {
        VStack(spacing: 20) {
            SandwichStreamView(
                events: [
                    SandwichEvent(
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
                    )
                ],
                isLoading: false,
                onCopyTransaction: nil
            )
            
            SandwichStreamView(
                events: [],
                isLoading: true,
                onCopyTransaction: nil
            )
        }
    }
    .background(Color(red: 0.027, green: 0.035, blue: 0.039))
} 
