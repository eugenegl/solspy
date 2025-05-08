//
//  Wallet.swift
//  SolSpy
//
//  Created by Евгений Голота on 28.04.2025.
//

import SwiftUI
import Combine

struct Wallet: View {
    // Адрес кошелька, который нужно отобразить. Пока не используется во viewModel, но пригодится при подключении API.
    var address: String = ""
    
    @StateObject private var viewModel: WalletViewModel
    var background: Color = Color(red: 0.027, green: 0.035, blue: 0.039)
    @State private var showingTokenList = false
    @Environment(\.dismiss) private var dismiss
    // Координатор для переходов к токенам/транзакциям
    @EnvironmentObject private var coordinator: NavigationCoordinator
    
    init(address: String = "") {
        self.address = address
        _viewModel = StateObject(wrappedValue: WalletViewModel(address: address))
    }
    
    var body: some View {
        ZStack {
            // Основной фон
            background.ignoresSafeArea()
            
            if viewModel.isLoading {
                // Используем кастомную анимацию загрузки
                VStack(spacing: 20) {
                    LoadingView()
                    
                    // Добавляем плейсхолдеры для контента
                    VStack(spacing: 25) {
                        ShimmerLoadingView()
                        ShimmerLoadingView()
                        ShimmerLoadingView()
                    }
                    .padding(.horizontal, 20)
                }
            } else if let errorMessage = viewModel.errorMessage {
                VStack {
                    Text("Error")
                        .font(.title)
                        .foregroundColor(.red)
                    Text(errorMessage)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .padding()
                    
                    Button("Retry") {
                        viewModel.loadWalletData()
                    }
                    .padding()
                    .background(Color.white.opacity(0.1))
                    .cornerRadius(10)
                }
                .padding()
            } else {
                // Основной контент
                ZStack(alignment: .top) {
                    // Скроллируемый контент с эффектом пружины
                    ScrollView(showsIndicators: false) {
                        RefreshControl(coordinateSpace: .named("walletRefresh"), onRefresh: {
                            viewModel.refreshData()
                        })
                        
                        // Отступ сверху для Header action bar с учетом вашего дизайна
                        Spacer().frame(height: 40)
                        
                        VStack(spacing: 20) {
                            // Содержимое страницы без Header action bar
                            
                            //Wallet title
                            VStack(alignment: .leading, spacing: 15) {
                                Text("Wallet")
                                    .font(.system(size: 20, weight: .regular, design: .default))
                                VStack(alignment: .leading, spacing: 5) {
                                    Text(viewModel.walletAddressShort)
                                        .font(.system(size: 36, weight: .regular, design: .default))
                                    Text(viewModel.walletAddressFull)
                                        .font(.system(size: 12, weight: .regular, design: .default))
                                        .foregroundStyle(.white.opacity(0.5))
                                }
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.top, 20)
                            
                            //Account Balance
                            ZStack {
                                
                                VStack {
                                    VStack(alignment: .leading, spacing: 20) {
                                        VStack(alignment: .leading, spacing: 8) {
                                            Text("Account Balance")
                                                .foregroundStyle(Color.gray)
                                                .font(.system(size: 14))
                                            
                                            Text(viewModel.totalBalanceUSD)
                                                .foregroundStyle(.white)
                                                .font(.system(size: 36, weight: .regular))
                                        }
                                        
                                        // Проверка на нулевой баланс
                                        if viewModel.isEmptyBalance {
                                            EmptyStateView(
                                                icon: "dollarsign.circle",
                                                title: "No balance",
                                                message: "Add funds to your wallet to get started"
                                            )
                                            .padding(.vertical, 10)
                                        } else {
                                            
                                            HStack {
                                                VStack(alignment: .leading) {
                                                    Text("SOL Balance")
                                                        .foregroundStyle(Color.gray)
                                                        .font(.caption)
                                                    Text(viewModel.solBalanceFormatted)
                                                        .foregroundStyle(.white)
                                                        .font(.subheadline)
                                                }
                                                .frame(width: 160, alignment: .leading)
                                                
                                                
                                                VStack(alignment: .leading) {
                                                    Text("Token Balance")
                                                        .foregroundStyle(Color.gray)
                                                        .font(.caption)
                                                    HStack(spacing: 4) {
                                                        Text(viewModel.tokenCountFormatted)
                                                            .foregroundStyle(.white)
                                                            .font(.subheadline)
                                                        Text("(\(viewModel.tokenBalanceUSD))")
                                                            .foregroundStyle(.gray)
                                                            .font(.subheadline)
                                                    }
                                                }
                                                .frame(width: 160, alignment: .leading)
                                            }
                                            
                                            // USDC кнопка - теперь работает как кнопка для открытия sheet
                                            Button(action: {
                                                showingTokenList = true
                                            }) {
                                                HStack {
                                                    TokenLogoView(
                                                        logoUrl: viewModel.getTokenLogo(symbol: "USDC"),
                                                        symbol: "USDC"
                                                    )
                                                    
                                                    Text(viewModel.usdcMaskFormatted)
                                                        .foregroundStyle(.white)
                                                        .font(.system(size: 16))
                                                    Spacer()
                                                    Image(systemName: "plus")
                                                        .foregroundStyle(.white.opacity(0.5))
                                                        .font(.system(size: 12))
                                                }
                                                .padding(.vertical, 14)
                                                .padding(.horizontal, 16)
                                                .background(Color.white.opacity(0.05))
                                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                            }
                                        }
                                    }
                                    .padding(10)
                                }
                                .background(Color.white.opacity(0.02))
                                
                                Circle()
                                    .fill(Color.green.opacity(0.4))
                                    .frame(width: 150, height: 150)
                                    .blur(radius: 60)
                                    .offset(x: 150, y: -100)
                            }
                            .clipped()
                            .cornerRadius(15)
                            .overlay(
                                RoundedRectangle(cornerRadius: 15)
                                    .stroke(
                                        LinearGradient(
                                            gradient: Gradient(colors: [Color.white.opacity(0.2), Color.white.opacity(0.1)]),
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ),
                                        lineWidth: 0.5
                                    )
                            )
                            
                            //All Transactions
                            VStack(spacing: 10) {
                                HStack() {
                                    Text("Transactions")
                                        .font(.system(size: 20, weight: .regular, design: .default))
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.vertical, 10)
                                
                                if viewModel.transactions.isEmpty {
                                    // Пустое состояние для транзакций
                                    EmptyStateView(
                                        icon: "arrow.left.arrow.right.circle",
                                        title: "No transactions yet",
                                        message: "Your transaction history will appear here"
                                    )
                                    .padding(.vertical, 30)
                                } else {
                                    // Динамически создаем транзакции
                                    ForEach(viewModel.transactions) { transaction in
                                        TransactionCard(transaction: transaction, viewModel: viewModel)
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 20)
                    }
                    
                    Spacer()
                }
                .coordinateSpace(name: "walletRefresh")
                .zIndex(0) // Контент под хедером
                
                // Полупрозрачный фон за Header
                VStack(spacing: 0) {
                    // Градиентный фон для хедера
                    LinearGradient(
                        gradient: Gradient(
                            colors: [
                                background.opacity(1),
                                background.opacity(1),
                                background.opacity(0.9),
                                background.opacity(0)
                            ]
                        ),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .frame(height: 160)
                    
                    Spacer()
                }
                .ignoresSafeArea()
                .zIndex(1) // Фоновый градиент над контентом
                
                
                // Header action bar закрепленный вверху
                VStack {
                    HStack {
                        // Кнопка назад
                        Button(action: {
                            // Используем Environment для возврата, если возможно
                            if dismiss != nil {
                                dismiss()
                            } else {
                                // Иначе используем ViewModel
                                viewModel.goBack()
                            }
                        }) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundStyle(.white.opacity(0.7))
                                .frame(width: 40, height: 40)
                                .background(Color.white.opacity(0.05))
                                .cornerRadius(12)
                        }
                        
                        Spacer()
                        
                        HStack(spacing: 12) {
                            // Кнопка поделиться
                            Button(action: {
                                viewModel.shareWallet()
                            }) {
                                Image(systemName: "square.and.arrow.up")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundStyle(.white.opacity(0.7))
                                    .frame(width: 40, height: 40)
                                    .background(Color.white.opacity(0.05))
                                    .cornerRadius(12)
                            }
                            
                            // Кнопка копировать
                            Button(action: {
                                viewModel.copyWalletLink()
                            }) {
                                Image(systemName: "doc.on.doc")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundStyle(.white.opacity(0.7))
                                    .frame(width: 40, height: 40)
                                    .background(Color.white.opacity(0.05))
                                    .cornerRadius(12)
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 10)
                    .padding(.bottom, 10)
                    
                    Spacer()
                }
                .background(
                    // Эффект размытия для стеклянного эффекта хедера (при желании)
                    Rectangle()
                        .fill(Color.clear)
                        .frame(height: 70)
                )
                .zIndex(3) // Элементы хедера поверх всего, кроме тоста
            }
            
            // Toast уведомление при копировании
            if viewModel.showCopiedToast {
                VStack {
                    Spacer()
                    
                    Text("Link copied")
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
                .animation(.easeInOut, value: viewModel.showCopiedToast)
                .zIndex(10) // Абсолютно поверх всего интерфейса
            }
            
            // Toast уведомление об ошибках обновления
            if viewModel.showToast {
                VStack {
                    Spacer()
                    
                    Text(viewModel.toastMessage)
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
                .animation(.easeInOut, value: viewModel.showToast)
                .zIndex(11) // Поверх всего интерфейса, включая другие тосты
            }
        }
        .foregroundStyle(.white)
        .onAppear {
            viewModel.loadWalletData()
        }
        .sheet(isPresented: $showingTokenList) {
            TokenListView(viewModel: viewModel)
        }
        .sheet(isPresented: $viewModel.showShareSheet) {
            // Отображение ShareSheet
            ShareSheet(items: viewModel.getShareItems())
        }
        .coordinateSpace(name: "walletRefresh") // Для работы refresh control
    }
}

// Вынесли карточку транзакции в отдельный компонент для переиспользования
struct TransactionCard: View {
    let transaction: Transaction
    @ObservedObject var viewModel: WalletViewModel
    
    init(transaction: Transaction, viewModel: WalletViewModel) {
        self.transaction = transaction
        self.viewModel = viewModel
    }
    
    var body: some View {
        VStack {
            VStack(alignment: .leading, spacing: 20) {
                // Заголовок карточки
                HStack {
                    Text(transaction.type.rawValue)
                        .foregroundStyle(transaction.isFailed ? Color(red: 0.894, green: 0.247, blue: 0.145) : Color.white)
                        .font(.subheadline)
                    Spacer()
                    // Иконки (могут быть динамическими в зависимости от транзакции)
                    Image(systemName: "dollarsign.circle.fill")
                        .foregroundStyle(.white)
                    Image(systemName: "dollarsign.circle.fill")
                        .foregroundStyle(.white)
                }
                
                // Содержимое транзакции в зависимости от типа
                if transaction.isFailed {
                    // Неудачная транзакция
                    HStack {
                        Text("Transaction failed")
                            .foregroundStyle(Color(red: 0.894, green: 0.247, blue: 0.145))
                            .font(.subheadline)
                    }
                } else if transaction.type == .swap {
                    // Своп транзакция
                    HStack {
                        if let fromAmount = transaction.fromAmount, let fromSymbol = transaction.fromSymbol,
                           let toAmount = transaction.toAmount, let toSymbol = transaction.toSymbol {
                            // От токена
                            HStack(spacing: 2) {
                                TokenLogoView(
                                    logoUrl: viewModel.getTokenLogo(symbol: fromSymbol),
                                    symbol: fromSymbol,
                                    size: 16
                                )
                                
                                Text(fromAmount.formatAsTokenAmount())
                                    .foregroundStyle(.white)
                                    .font(.subheadline)
                                
                                Text(fromSymbol)
                                    .foregroundStyle(.white)
                                    .font(.subheadline)
                            }
                            
                            Image(systemName: "arrow.left.arrow.right")
                                .foregroundStyle(.white)
                                .font(.system(size: 12))
                            
                            // К токену
                            HStack(spacing: 2) {
                                TokenLogoView(
                                    logoUrl: viewModel.getTokenLogo(symbol: toSymbol),
                                    symbol: toSymbol,
                                    size: 16
                                )
                                
                                Text(toAmount.formatAsTokenAmount())
                                    .foregroundStyle(.white)
                                    .font(.subheadline)
                                
                                Text(toSymbol)
                                    .foregroundStyle(.white)
                                    .font(.subheadline)
                            }
                        }
                    }
                } else if transaction.type == .burn {
                    // Транзакция сжигания
                    HStack {
                        Text("Burned")
                            .foregroundStyle(.white)
                            .font(.subheadline)
                        if let amount = transaction.amount, let symbol = transaction.tokenSymbol {
                            HStack(spacing: 4) {
                                TokenLogoView(
                                    logoUrl: viewModel.getTokenLogo(symbol: symbol),
                                    symbol: symbol,
                                    size: 16
                                )
                                
                                Text(amount.formatAsTokenAmount())
                                    .foregroundStyle(.white)
                                    .font(.subheadline)
                                Text(symbol)
                                    .foregroundStyle(.white)
                                    .font(.subheadline)
                            }
                        }
                    }
                } else if transaction.type == .generic {
                    // Общая транзакция без доп. информации
                    HStack {
                        Text("---")
                            .foregroundStyle(Color.white)
                            .font(.subheadline)
                    }
                } else {
                    // Обычная транзакция с суммой и токеном
                    HStack {
                        // Индикатор входящей/исходящей транзакции
                        ZStack {
                            Image(systemName: transaction.isIncoming ? "plus" : "minus")
                                .foregroundStyle(transaction.isIncoming ? Color(red: 0.247, green: 0.918, blue: 0.286) : Color(red: 0.894, green: 0.247, blue: 0.145))
                                .font(.system(size: 12))
                            Circle()
                                .foregroundStyle((transaction.isIncoming ? Color(red: 0.247, green: 0.918, blue: 0.286) : Color(red: 0.894, green: 0.247, blue: 0.145)).opacity(0.1))
                                .frame(width: 20, height: 20)
                        }
                        
                        if let amount = transaction.amount, let symbol = transaction.tokenSymbol {
                            HStack(spacing: 4) {
                                TokenLogoView(
                                    logoUrl: viewModel.getTokenLogo(symbol: symbol),
                                    symbol: symbol,
                                    size: 16
                                )
                                
                                HStack(spacing: 2) {
                                    Text(amount.formatAsTokenAmount())
                                        .foregroundStyle(.white)
                                        .font(.subheadline)
                                    
                                    Text(symbol)
                                        .foregroundStyle(.white)
                                        .font(.subheadline)
                                }
                            }
                        }
                    }
                }
                
                // Нижняя часть карточки с датой и адресом
                HStack {
                    Text(transaction.date.timeAgo())
                        .foregroundStyle(Color.gray)
                        .font(.caption)
                    
                    Spacer()
                    
                    // Короткий формат адреса
                    HStack {
                        Text(formatShortAddress(transaction.address))
                            .foregroundStyle(.white)
                            .font(.subheadline)
                        Image(systemName: "arrow.up.right")
                            .foregroundStyle(.white)
                            .font(.system(size: 13))
                    }
                }
            }
            .padding(10)
        }
        .clipped()
        .cornerRadius(15)
        .overlay(
            RoundedRectangle(cornerRadius: 15)
                .stroke(
                    LinearGradient(
                        gradient: Gradient(colors: [Color.white.opacity(0.2), Color.white.opacity(0.1)]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 0.5
                )
        )
    }
    
    // Функция для формирования короткого адреса
    private func formatShortAddress(_ address: String) -> String {
        guard address.count > 7 else { return address }
        let prefix = address.prefix(4)
        let suffix = address.suffix(4)
        return "\(prefix)...\(suffix)"
    }
}

// Превью
struct Wallet_Previews: PreviewProvider {
    static var previews: some View {
        Wallet()
            .preferredColorScheme(.dark)
            .environmentObject(NavigationCoordinator())
    }
}

// Компонент для отображения системного ShareSheet
#if false
struct ShareSheet: UIViewControllerRepresentable { /* duplicate */ }
#endif

/// Кастомный RefreshControl
#if false
struct RefreshControl: View { /* duplicate */ }
struct ScrollOffsetPreferenceKey: PreferenceKey { static var defaultValue: CGFloat = 0; static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) { value = nextValue() } }
#endif

// Компонент для отображения пустых состояний
struct EmptyStateView: View {
    var icon: String
    var title: String
    var message: String
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 40))
                .foregroundColor(.gray)
            
            Text(title)
                .font(.headline)
                .foregroundColor(.white)
            
            Text(message)
                .font(.subheadline)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical)
    }
}
