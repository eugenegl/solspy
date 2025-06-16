import SwiftUI

struct MEVStreamView: View {
    let events: [MEVStreamEvent]
    let isLoading: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Заголовок секции
            HStack {
                Text("Sandwich Stream")
                    .font(.system(size: 18, weight: .regular))
                    .foregroundStyle(.white)
                
                Spacer()
                
                // Индикатор обновления (заменяет realtime)
                HStack(spacing: 4) {
                    if isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .green))
                            .scaleEffect(0.6)
                        
                        Text("updating...")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundStyle(.green.opacity(0.7))
                    } else {
                        Image(systemName: "arrow.clockwise")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundStyle(.green.opacity(0.7))
                        
                        Text("pull to refresh")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundStyle(.green.opacity(0.7))
                    }
                }
            }
            .padding(.horizontal, 20)
            
            // Список событий как отдельные блоки
            VStack(spacing: 12) {
                ForEach(events) { event in
                    MEVStreamEventCard(event: event)
                        .transition(.asymmetric(
                            insertion: .move(edge: .top).combined(with: .opacity),
                            removal: .opacity
                        ))
                }
                
                if events.isEmpty && !isLoading {
                    EmptyStreamView()
                        .padding(.horizontal, 20)
                } else if events.isEmpty && isLoading {
                    LoadingStreamView()
                        .padding(.horizontal, 20)
                }
            }
        }
    }
}

struct MEVStreamEventCard: View {
    let event: MEVStreamEvent
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Заголовок события
            HStack {
                Text(event.id)
                    .font(.system(size: 16, weight: .regular))
                    .foregroundStyle(.white)
                    .lineLimit(1)
                
                Spacer()
                
                Text(event.station)
                    .font(.system(size: 12, weight: .regular))
                    .foregroundStyle(.white.opacity(0.6))
            }
            
            // Время
            HStack {
                Text(event.timeAgo)
                    .font(.system(size: 12, weight: .regular))
                    .foregroundStyle(.white.opacity(0.5))
                
                Spacer()
            }
            
            // Список действий с фоном
            VStack(spacing: 4) {
                ForEach(event.actions) { action in
                    MEVActionRow(action: action)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 10)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.white.opacity(0.1))
                        )
                }
            }
        }
        .padding(14)
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

struct MEVActionRow: View {
    let action: MEVAction
    
    var body: some View {
        HStack(spacing: 6) {
            // Тип действия
            Text(action.type.rawValue + ":")
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(actionTypeColor)
                .frame(width: 45, alignment: .leading)
            
            // Адрес
            Text(action.shortAddress)
                .font(.system(size: 11, weight: .regular))
                .foregroundStyle(.white.opacity(0.8))
                .frame(width: 70, alignment: .leading)
                .lineLimit(1)
            
            // Стрелка
            Image(systemName: "arrow.right")
                .font(.system(size: 9))
                .foregroundStyle(.white.opacity(0.4))
            
            // Сумма
            Text("\(action.formattedAmount) \(action.token)")
                .font(.system(size: 11, weight: .regular))
                .foregroundStyle(.white)
                .lineLimit(1)
            
            Spacer()
            
            // Блок и ник
            Text("\(action.blockNumber). \(action.nickname ?? "Unknown")")
                .font(.system(size: 9, weight: .regular))
                .foregroundStyle(.white.opacity(0.5))
                .lineLimit(1)
        }
    }
    
    private var actionTypeColor: Color {
        switch action.type {
        case .bot:
            return .red
        case .victim:
            return .orange
        }
    }
}

struct TokenIcon: View {
    let token: String
    
    var body: some View {
        HStack(spacing: 2) {
            Image(systemName: "circle.fill")
                .font(.system(size: 8))
                .foregroundStyle(tokenColor)
            
            Text(token)
                .font(.system(size: 10, weight: .medium))
                .foregroundStyle(.white.opacity(0.7))
        }
    }
    
    private var tokenColor: Color {
        switch token {
        case "SOL":
            return .purple
        case "USDC":
            return .blue
        default:
            return .gray
        }
    }
}

struct EmptyStreamView: View {
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "chart.line.uptrend.xyaxis")
                .font(.system(size: 32))
                .foregroundStyle(.white.opacity(0.3))
            
            Text("No MEV events found")
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

struct LoadingStreamView: View {
    var body: some View {
        VStack(spacing: 12) {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: .green))
                .scaleEffect(1.2)
            
            Text("Loading MEV events...")
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
            MEVStreamView(
                events: MEVStreamEvent.mockEvents,
                isLoading: false
            )
            
            MEVStreamView(
                events: [],
                isLoading: true
            )
        }
    }
    .background(Color(red: 0.027, green: 0.035, blue: 0.039))
} 
