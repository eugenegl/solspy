import SwiftUI

struct MEVBotTrackerWidget: View {
    @EnvironmentObject private var coordinator: NavigationCoordinator
    @EnvironmentObject private var homeViewModel: HomeViewModel
    @State private var isPressed = false
    @State private var showDataInfoSheet = false
    
    // Проверяем свежесть данных MEV (считаем устаревшими если старше 2 часов)
    private var isDataStale: Bool {
        return homeViewModel.isMEVDataStale
    }
    
    var body: some View {
        Button(action: {
            coordinator.showMEVTracker()
        }) {
            VStack(alignment: .leading, spacing: 16) {
                // Заголовок с иконкой
                HStack {
                    // Иконка MEV с индикатором состояния
                    ZStack {
                        Circle()
                            .fill(Color.red.opacity(0.2))
                            .frame(width: 40, height: 40)
                        
                        Image(systemName: "shield.slash")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundStyle(Color.red)
                        
                        // Индикатор устаревших данных
                        if isDataStale {
                            Circle()
                                .fill(Color.orange)
                                .frame(width: 8, height: 8)
                                .offset(x: 14, y: -14)
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        HStack(spacing: 4) {
                            Text("MEV Bot Tracker")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundStyle(.white)
                            
                            // Индикатор если данные устарели
                            if isDataStale {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .font(.system(size: 12))
                                    .foregroundStyle(.orange)
                            }
                        }
                        
                        Text(isDataStale ? "Data may be outdated" : "Sandwich attacks monitor")
                            .font(.system(size: 14, weight: .regular))
                            .foregroundStyle(isDataStale ? .orange.opacity(0.8) : .white.opacity(0.7))
                    }
                    
                    Spacer()
                    
                    // Индикатор загрузки или стрелка
                    if homeViewModel.isMEVLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white.opacity(0.6)))
                            .scaleEffect(0.8)
                    } else {
                        Image(systemName: "chevron.right")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(.white.opacity(0.6))
                    }
                }
                
                // Статистика в строку - новые метрики из API
                HStack(spacing: 16) {
                    // SOL Drained
                    VStack(alignment: .leading, spacing: 4) {
                        Text("SOL Drained")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundStyle(.white.opacity(0.6))
                            .lineLimit(1)
                        
                        HStack(spacing: 2) {
                            Image("SolanaLogo")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 12, height: 12)
                            
                            if let stats = homeViewModel.mevStats {
                                Text(formatSolAmount(stats.solDrained))
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundStyle(isDataStale ? .orange : .red)
                                    .lineLimit(1)
                            } else {
                                Text("--")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundStyle(.gray)
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                    // Attackers
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Attackers")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundStyle(.white.opacity(0.6))
                        
                        if let stats = homeViewModel.mevStats {
                            Text("\(stats.attackersCount)")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundStyle(isDataStale ? .purple.opacity(0.8) : .purple)
                        } else {
                            Text("--")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundStyle(.gray)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                    // Victims
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Victims")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundStyle(.white.opacity(0.6))
                        
                        if let stats = homeViewModel.mevStats {
                            Text(formatCount(stats.victimsCount))
                                .font(.system(size: 14, weight: .bold))
                                .foregroundStyle(isDataStale ? .orange.opacity(0.8) : .yellow)
                                .lineLimit(1)
                        } else {
                            Text("--")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundStyle(.gray)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                
                // Время периода данных с кликабельным индикатором
                HStack {
                    Text("Last 7 days")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundStyle(.white.opacity(0.4))
                    
                    Spacer()
                    
                    if isDataStale {
                        Button(action: {
                            showDataInfoSheet = true
                        }) {
                            HStack(spacing: 4) {
                                Text("Updated over 2h ago")
                                    .font(.system(size: 10, weight: .medium))
                                    .foregroundStyle(.orange.opacity(0.8))
                                
                                Image(systemName: "info.circle")
                                    .font(.system(size: 10))
                                    .foregroundStyle(.orange.opacity(0.6))
                            }
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(Color.orange.opacity(0.1))
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 15)
                    .fill(Color.black.opacity(0.3))
                    .overlay(
                        RoundedRectangle(cornerRadius: 15)
                            .stroke(
                                isPressed ? 
                                Color.red.opacity(0.5) : 
                                (isDataStale ? Color.orange.opacity(0.3) : Color.white.opacity(0.1)), 
                                lineWidth: 1
                            )
                    )
            )
            .scaleEffect(isPressed ? 0.98 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: isPressed)
        }
        .buttonStyle(PlainButtonStyle())
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
            isPressed = pressing
        }, perform: {})
        .padding(.horizontal, 20)
        .sheet(isPresented: $showDataInfoSheet) {
            MEVDataInfoSheet(
                lastAttackTime: homeViewModel.lastMEVAttackTime,
                isDataStale: isDataStale
            )
            .presentationDetents([.height(400)])
            .presentationDragIndicator(.visible)
        }
    }
    
    // MARK: - Formatting Helpers
    private func formatSolAmount(_ amount: Double) -> String {
        if amount >= 1000 {
            return String(format: "%.1fK", amount / 1000)
        } else if amount >= 1 {
            return String(format: "%.1f", amount)
        } else {
            return String(format: "%.3f", amount)
        }
    }
    
    private func formatCount(_ count: Int) -> String {
        if count >= 1000000 {
            return String(format: "%.1fM", Double(count) / 1000000)
        } else if count >= 1000 {
            return String(format: "%.1fK", Double(count) / 1000)
        } else {
            return "\(count)"
        }
    }
}

// MARK: - MEV Data Info Sheet
struct MEVDataInfoSheet: View {
    let lastAttackTime: Date?
    let isDataStale: Bool
    @Environment(\.dismiss) private var dismiss
    
    private var timeAgoText: String {
        guard let lastAttack = lastAttackTime else { return "Unknown" }
        
        let hoursAgo = Date().timeIntervalSince(lastAttack) / 3600
        if hoursAgo < 1 {
            let minutesAgo = Int(Date().timeIntervalSince(lastAttack) / 60)
            return "\(minutesAgo) minutes ago"
        } else if hoursAgo < 24 {
            return String(format: "%.1f hours ago", hoursAgo)
        } else {
            let daysAgo = hoursAgo / 24
            return String(format: "%.1f days ago", daysAgo)
        }
    }
    
    private var lastAttackFormatted: String {
        guard let lastAttack = lastAttackTime else { return "Unknown" }
        
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: lastAttack)
    }
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 20) {
                // Заголовок с иконкой
                HStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(Color.orange.opacity(0.2))
                            .frame(width: 50, height: 50)
                        
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.system(size: 24))
                            .foregroundStyle(.orange)
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("MEV Data Status")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundStyle(.white)
                        
                        Text(isDataStale ? "Data is outdated" : "Data is current")
                            .font(.system(size: 14))
                            .foregroundStyle(isDataStale ? .orange : .green)
                    }
                    
                    Spacer()
                }
                
                // Информация о последней атаке
                VStack(alignment: .leading, spacing: 12) {
                    Text("Last MEV Attack")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(.white)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Time:")
                                .font(.system(size: 14))
                                .foregroundStyle(.white.opacity(0.7))
                            
                            Spacer()
                            
                            Text(timeAgoText)
                                .font(.system(size: 14, weight: .medium))
                                .foregroundStyle(isDataStale ? .orange : .white)
                        }
                        
                        HStack {
                            Text("Date:")
                                .font(.system(size: 14))
                                .foregroundStyle(.white.opacity(0.7))
                            
                            Spacer()
                            
                            Text(lastAttackFormatted)
                                .font(.system(size: 14))
                                .foregroundStyle(.white.opacity(0.9))
                        }
                    }
                    .padding(12)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.white.opacity(0.05))
                    )
                }
                
                // Объяснение логики
                VStack(alignment: .leading, spacing: 12) {
                    Text("How it works")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(.white)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Label("Data updates every 2 minutes", systemImage: "clock")
                            .font(.system(size: 14))
                            .foregroundStyle(.white.opacity(0.8))
                        
                        Label("Shows warning if >2 hours since last attack", systemImage: "exclamationmark.triangle")
                            .font(.system(size: 14))
                            .foregroundStyle(.orange.opacity(0.8))
                        
                        Label("Pull to refresh for latest data", systemImage: "arrow.clockwise")
                            .font(.system(size: 14))
                            .foregroundStyle(.white.opacity(0.8))
                    }
                }
                
                Spacer()
            }
            .padding(20)
            .background(Color(red: 0.027, green: 0.035, blue: 0.039))
            .navigationTitle("Data Info")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundStyle(.white)
                }
            }
        }
    }
}

#Preview {
    MEVBotTrackerWidget()
        .environmentObject(NavigationCoordinator())
        .environmentObject(HomeViewModel())
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(red: 0.027, green: 0.035, blue: 0.039))
} 
