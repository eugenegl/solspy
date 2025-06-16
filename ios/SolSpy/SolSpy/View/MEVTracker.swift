import SwiftUI

struct MEVTracker: View {
    @StateObject private var viewModel = MEVTrackerViewModel()
    @EnvironmentObject private var coordinator: NavigationCoordinator
    @State private var showTimeFilterSheet = false
    @State private var showToast = false
    @State private var toastMessage = ""
    
    var body: some View {
        ZStack {
            // Основной фон
            Color(red: 0.027, green: 0.035, blue: 0.039).ignoresSafeArea()
            
            // Основной контент
            ZStack(alignment: .top) {
                // Скроллируемый контент
                ScrollView(showsIndicators: false) {
                    // Отступ сверху для кнопки "Назад" и заголовка
                    Spacer().frame(height: 90)
                    
                    VStack(spacing: 15) {
                        // Заголовок
                        HStack {
                            Text("Sandwich Analytics")
                                .font(.system(size: 20, weight: .regular))
                                .foregroundStyle(.white)
                            Spacer()
                        }
                        .padding(.horizontal, 20)
                        
                        // Показываем ошибку если есть
                        if let errorMessage = viewModel.errorMessage {
                            ErrorBanner(message: errorMessage) {
                                Task {
                                    await viewModel.refreshData()
                                }
                            }
                        }
                        
                        // Статистика
                        MEVStatsCard(
                            statistics: viewModel.statistics,
                            isLoading: viewModel.isLoading
                        )
                        .padding(.bottom, 20)
                        
                        // Лента событий с колбеком для тоста
                        SandwichStreamView(
                            events: viewModel.sandwichEvents,
                            isLoading: viewModel.isLoading,
                            onCopyTransaction: { txHash in
                                UIPasteboard.general.string = txHash
                                showToastMessage("Transaction copied")
                            }
                        )
                    }
                    .padding(.bottom, 100) // Отступ снизу для удобства скролла
                }
                .refreshable {
                    await viewModel.refreshData()
                }
                
                // Хедер с кнопкой "Назад" и фильтром
                VStack(spacing: 0) {
                    HStack {
                        // Кнопка "Назад"
                        Button(action: {
                            coordinator.pop()
                        }) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundStyle(.white.opacity(0.7))
                                .frame(width: 40, height: 40)
                                .background(Color.white.opacity(0.05))
                                .cornerRadius(12)
                        }
                        
                        Spacer()
                        
                        // Фильтр времени
                        Button(action: {
                            showTimeFilterSheet = true
                        }) {
                            HStack(spacing: 6) {
                                Text(viewModel.selectedTimeFilter.displayName)
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundStyle(.white)
                                
                                Image(systemName: "chevron.down")
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundStyle(.white.opacity(0.7))
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.white.opacity(0.1))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(Color.white.opacity(0.2), lineWidth: 1)
                                    )
                            )
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 10)
                }
                .background(
                    Rectangle()
                        .fill(Color.clear)
                        .frame(height: 70)
                )
                .zIndex(3) // Поверх основного контента
                
                // Тост уведомление
                if showToast {
                    VStack {
                        Spacer()
                        
                        Text(toastMessage)
                            .font(.system(size: 15, weight: .medium))
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.black.opacity(0.7))
                                    .shadow(color: .black.opacity(0.2), radius: 5, x: 0, y: 2)
                            )
                            .foregroundColor(.white)
                            .transition(.move(edge: .bottom).combined(with: .opacity))
                            .padding(.bottom, 20)
                    }
                    .animation(.easeInOut, value: showToast)
                    .zIndex(4) // Поверх всего остального
                }
            }
        }
        .navigationBarHidden(true)
        .sheet(isPresented: $showTimeFilterSheet) {
            TimeFilterSheet(
                selectedFilter: $viewModel.selectedTimeFilter,
                onFilterChange: { filter in
                    viewModel.changeTimeFilter(filter)
                }
            )
            .presentationDetents([.height(300)])
            .presentationDragIndicator(.visible)
        }
    }
    
    // MARK: - Toast Methods
    private func showToastMessage(_ message: String) {
        toastMessage = message
        showToast = true
        
        // Автоматически скрываем через 2 секунды
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            showToast = false
        }
    }
}

struct TimeFilterSheet: View {
    @Binding var selectedFilter: MEVAPIService.TimeFilter
    let onFilterChange: (MEVAPIService.TimeFilter) -> Void
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                ForEach(MEVAPIService.TimeFilter.allCases, id: \.self) { filter in
                    Button(action: {
                        selectedFilter = filter
                        onFilterChange(filter)
                        dismiss()
                    }) {
                        HStack {
                            Text(filter.displayName)
                                .font(.system(size: 16, weight: .medium))
                                .foregroundStyle(.white)
                            
                            Spacer()
                            
                            if selectedFilter == filter {
                                Image(systemName: "checkmark")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundStyle(.green)
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 16)
                        .background(
                            selectedFilter == filter ?
                            Color.white.opacity(0.1) :
                            Color.clear
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    if filter != MEVAPIService.TimeFilter.allCases.last {
                        Divider()
                            .background(Color.white.opacity(0.1))
                    }
                }
                
                Spacer()
            }
            .background(Color(red: 0.027, green: 0.035, blue: 0.039))
            .navigationTitle("Time Filter")
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

struct ErrorBanner: View {
    let message: String
    let onRetry: () -> Void
    
    var body: some View {
        HStack {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(.orange)
            
            Text(message)
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(.white)
                .lineLimit(2)
            
            Spacer()
            
            Button("Pull to refresh") {
                onRetry()
            }
            .font(.system(size: 14, weight: .medium))
            .foregroundStyle(.gray)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.orange.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.orange.opacity(0.3), lineWidth: 1)
                )
        )
        .padding(.horizontal, 20)
    }
}

#Preview {
    NavigationView {
        MEVTracker()
            .environmentObject(NavigationCoordinator())
    }
    .preferredColorScheme(.dark)
} 
