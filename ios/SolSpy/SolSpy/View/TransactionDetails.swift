//
//  TransactionDetails.swift
//  SolSpy
//
//  Created by Евгений Голота on 28.04.2025.
//

import SwiftUI
import UIKit

enum TransactionTab {
    case overview
    case solBalanceChange
    case tokenBalanceChange
}

struct TransactionDetails: View {
    @StateObject private var viewModel = TransactionViewModel()
    @State private var selectedTab: TransactionTab = .overview
    @Environment(\.dismiss) private var dismiss
    @State private var showCopiedToast: Bool = false
    @State private var showShareSheet: Bool = false
    @EnvironmentObject private var coordinator: NavigationCoordinator
    
    var transactionSignature: String? = nil
    var background: Color = Color(red: 0.027, green: 0.035, blue: 0.039)
    
    var body: some View {
        ZStack {
            background.ignoresSafeArea()
            
            if viewModel.isLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .scaleEffect(1.5)
            } else if let errorMessage = viewModel.errorMessage {
                VStack {
                    Text("Loading Error")
                        .font(.headline)
                        .foregroundColor(.white)
                    Text(errorMessage)
                        .foregroundColor(.white.opacity(0.7))
                        .multilineTextAlignment(.center)
                        .padding()
                    
                    Button("Retry") {
                        if let signature = transactionSignature {
                            viewModel.loadTransaction(signature: signature)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(Color.white.opacity(0.1))
                    .cornerRadius(10)
                }
            } else if let transaction = viewModel.transaction {
                // Основной контент
                ZStack(alignment: .top) {
                    // Скроллируемый контент
                    ScrollView(showsIndicators: false) {
                        RefreshControl(coordinateSpace: .named("transactionRefresh"), onRefresh: {
                            viewModel.refreshData()
                        })
                        
                        // Отступ сверху для Header action bar
                        Spacer().frame(height: 60)
                        
                        VStack(spacing: 20) {
                            //Transaction title
                            Text("Transaction Details")
                                .font(.system(size: 20, weight: .regular, design: .default))
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal, 20)
                                .padding(.top, 20)
                            
                            //Tabs
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 10) {
                                    TabButton(title: "Overview", isSelected: selectedTab == .overview) {
                                        selectedTab = .overview
                                    }
                                    
                                    TabButton(title: "SOL Balance Change", isSelected: selectedTab == .solBalanceChange) {
                                        selectedTab = .solBalanceChange
                                    }
                                    
                                    TabButton(title: "Token Balance Change", isSelected: selectedTab == .tokenBalanceChange) {
                                        selectedTab = .tokenBalanceChange
                                    }
                                    
                                    Spacer()
                                }
                                .padding(.horizontal, 20)
                            }
                            .padding(.bottom, 10)
                            
                            // Выбор контента на основе выбранной вкладки
                            if let transaction = viewModel.transaction {
                                switch selectedTab {
                                case .overview:
                                    OverviewTabView(transaction: transaction, viewModel: viewModel)
                                case .solBalanceChange:
                                    SolBalanceChangeTabView(transaction: transaction, viewModel: viewModel)
                                case .tokenBalanceChange:
                                    TokenBalanceChangeTabView(transaction: transaction)
                                }
                            } else {
                                // Показываем заглушку пока данные загружаются
                                VStack {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                        .scaleEffect(1.2)
                                    Text("Загрузка данных транзакции...")
                                        .foregroundColor(.white.opacity(0.7))
                                        .padding(.top, 10)
                                }
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .padding(.top, 50)
                            }
                        }
                    }
                    .coordinateSpace(name: "transactionRefresh")
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
                        .frame(height: 80)
                        
                        Spacer()
                    }
                    .ignoresSafeArea()
                    .zIndex(1) // Фоновый градиент над контентом
                    
                    
                    // Header action bar закрепленный вверху
                    VStack {
                        HStack {
                            // Кнопка назад
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
                            
                            HStack(spacing: 12) {
                                // Кнопка поделиться
                                Button(action: {
                                    shareTransaction()
                                }) {
                                    Image(systemName: "square.and.arrow.up")
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundStyle(.white.opacity(0.7))
                                        .frame(width: 40, height: 40)
                                        .background(Color.white.opacity(0.05))
                                        .cornerRadius(12)
                                }
                                .opacity(UniversalLinkService.isUniversalLinksEnabled ? 1 : 0)
                                
                                // Кнопка копировать
                                Button(action: {
                                    copyTransactionLink()
                                }) {
                                    Image(systemName: "doc.on.doc")
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundStyle(.white.opacity(0.7))
                                        .frame(width: 40, height: 40)
                                        .background(Color.white.opacity(0.05))
                                        .cornerRadius(12)
                                }
                                .opacity(UniversalLinkService.isUniversalLinksEnabled ? 1 : 0)
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 10)
                        .padding(.bottom, 10)
                        
                        Spacer()
                    }
                    .zIndex(3) // Элементы хедера поверх всего, кроме тоста
                }
            } else {
                Text("Нет данных для отображения")
                    .foregroundColor(.white)
            }
            
            // Toast уведомление при копировании
            if showCopiedToast {
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
                .animation(.easeInOut, value: showCopiedToast)
                .zIndex(10) // Абсолютно поверх всего интерфейса
            }
            
            // Toast-уведомление для ошибок обновления
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
                .zIndex(11) // Поверх toast для копирования ссылки
            }
        }
        .foregroundStyle(.white)
        .onAppear {
            if let signature = transactionSignature {
                viewModel.loadTransaction(signature: signature)
            } else {
                // Для предварительного просмотра или тестирования
                viewModel.loadTransaction(signature: "")
            }
        }
        .sheet(isPresented: $showShareSheet) {
            ShareSheet(items: getShareItems())
        }
    }
    
    // Функция копирования ссылки на транзакцию
    private func copyTransactionLink() {
        guard let transaction = viewModel.transaction else { return }
        UniversalLinkService.shared.copyTransactionLink(signature: transaction.signature)
        
        // Показываем toast уведомление
        showCopiedToast = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            showCopiedToast = false
        }
    }
    
    // Функция для шаринга транзакции
    private func shareTransaction() {
        guard viewModel.transaction != nil else { return }
        showShareSheet = true
    }
    
    // Получение элементов для шаринга
    private func getShareItems() -> [Any] {
        guard let transaction = viewModel.transaction else { return [] }
        
        return UniversalLinkService.shared.generateTransactionShareItems(
            signature: transaction.signature
        )
    }
}

// Компонент для кнопки таба
struct TabButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .foregroundStyle(isSelected ? Color.black : Color.gray)
                .font(.system(size: 12, weight: .regular, design: .default))
                .padding(10)
                .background(isSelected ? Color.white.opacity(1) : Color.white.opacity(0.05))
                .cornerRadius(10)
        }
    }
}

// Представление для таба Overview
struct OverviewTabView: View {
    let transaction: DetailedTransaction
    let viewModel: TransactionViewModel
    
    var body: some View {
        VStack(spacing: 20) {
            //Signature
            VStack(alignment: .leading, spacing: 5) {
                Text("Signature")
                    .foregroundStyle(Color.gray)
                    .font(.subheadline)
                Text(viewModel.formattedSignature(transaction.signature))
                    .font(.system(size: 36, weight: .regular, design: .default))
                Text(transaction.signature)
                    .font(.system(size: 12, weight: .regular, design: .default))
                    .foregroundStyle(.white.opacity(0.5))
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 20)
            
            Divider()
                .padding(.horizontal, 20)
                .opacity(0.5)
            
            //Result
            VStack(alignment: .leading) {
                Text("Result")
                    .foregroundStyle(Color.gray)
                    .font(.subheadline)
                    .padding(.bottom, 10)
                HStack {
                    Text(viewModel.transactionResult)
                        .foregroundStyle(viewModel.resultColor)
                        .font(.subheadline)
                    Text("|")
                        .foregroundStyle(.gray)
                        .font(.subheadline)
                    Text(viewModel.confirmationStatus)
                        .foregroundStyle(.gray)
                        .font(.subheadline)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 20)
            
            Divider()
                .padding(.horizontal, 20)
                .opacity(0.5)
            
            //Timestamp
            VStack(alignment: .leading) {
                Text("Timestamp")
                    .foregroundStyle(Color.gray)
                    .font(.subheadline)
                    .padding(.bottom, 10)
                HStack {
                    Text(transaction.timeAgo)
                        .foregroundStyle(.white)
                        .font(.subheadline)
                    Text("|")
                        .foregroundStyle(.gray)
                        .font(.subheadline)
                    Text(transaction.formattedTimestamp)
                        .foregroundStyle(.gray)
                        .font(.subheadline)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 20)
            
            Divider()
                .padding(.horizontal, 20)
                .opacity(0.5)
            
            //Signer
            VStack(alignment: .leading, spacing: 10) {
                Text("Signer")
                    .foregroundStyle(Color.gray)
                    .font(.subheadline)
                    .padding(.bottom, 10)
                HStack {
                    Text(viewModel.shortAddress(transaction.feePayer))
                        .foregroundStyle(.white)
                        .font(.subheadline)
                    
                    Spacer()
                    
                    Button(action: {
                        viewModel.copySignerAddress(transaction.feePayer)
                    }) {
                        Image(systemName: "document.on.document")
                            .foregroundStyle(.white.opacity(0.5))
                            .font(.system(size: 12))
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 20)
            
            Divider()
                .padding(.horizontal, 20)
                .opacity(0.5)
            
            //Block
            VStack(alignment: .leading) {
                Text("Block")
                    .foregroundStyle(Color.gray)
                    .font(.subheadline)
                    .padding(.bottom, 10)
                HStack {
                    Text("\(transaction.slot)")
                        .foregroundStyle(.white)
                        .font(.subheadline)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 20)
            
            Divider()
                .padding(.horizontal, 20)
                .opacity(0.5)
            
            //Transaction Actions
            VStack(spacing: 10) {
                
                Text("Transaction Actions")
                    .font(.system(size: 20, weight: .regular, design: .default))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.vertical, 10)
                
                
                //Transaction Actions base info
                VStack(spacing: 20) {
                    VStack(alignment: .leading) {
                        Text("Fee")
                            .foregroundStyle(Color.gray)
                            .font(.subheadline)

                        HStack {
                            Text(transaction.formattedFee)
                                .foregroundStyle(.white)
                                .font(.subheadline)
                            TokenLogoView(
                                logoUrl: "https://light.dangervalley.com/static/sol.png",
                                symbol: "SOL",
                                size: 16
                            )
                            Text("SOL")
                                .foregroundStyle(.white)
                                .font(.subheadline)
                            
                            Text(viewModel.solToUSD(Double(transaction.fee) / 1_000_000_000.0))
                                .foregroundStyle(.gray)
                                .font(.subheadline)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                    VStack(alignment: .leading) {
                        Text("Compute Units Consumed")
                            .foregroundStyle(Color.gray)
                            .font(.subheadline)

                        HStack {
                            Text("900")
                                .foregroundStyle(.white)
                                .font(.subheadline)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                    VStack(alignment: .leading) {
                        Text("Transaction Version")
                            .foregroundStyle(Color.gray)
                            .font(.subheadline)

                        HStack {
                            Text("Legacy")
                                .foregroundStyle(.white)
                                .font(.subheadline)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                }
                .padding(10)
                .clipped()
                .cornerRadius(15)
                .background(Color.white.opacity(0.02))
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
                
                // Отображение нативных переводов
                ForEach(transaction.nativeTransfers.indices, id: \.self) { index in
                    let transfer = transaction.nativeTransfers[index]
                    TransferActionView(
                        from: viewModel.shortAddress(transfer.fromUserAccount),
                        to: viewModel.shortAddress(transfer.toUserAccount),
                        amount: transfer.formattedAmount,
                        programName: "System Program"
                    )
                }
                
            }
            .padding(.horizontal, 20)
            
            Spacer()
        }
    }
}

// Представление для таба SOL Balance Change
struct SolBalanceChangeTabView: View {
    let transaction: DetailedTransaction
    let viewModel: TransactionViewModel
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Заголовок раздела
                Text("SOL Balance Changes")
                    .font(.system(size: 18, weight: .medium))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 20)
                    .padding(.top, 10)
                
                // Фильтруем аккаунты, у которых есть изменения
                ForEach(transaction.accountData.filter { $0.nativeBalanceChange != 0 }, id: \.account) { account in
                    SolBalanceCardView(account: account, viewModel: viewModel)
                }
                
                // Если нет данных для отображения
                if transaction.accountData.filter({ $0.nativeBalanceChange != 0 }).isEmpty {
                    VStack {
                        Spacer(minLength: 80)
                        
                        Image(systemName: "tray")
                            .font(.system(size: 40))
                            .foregroundColor(.gray)
                            .padding()
                        
                        Text("No data")
                            .font(.headline)
                            .foregroundColor(.gray)
                        
                        Spacer()
                    }
                    .frame(maxWidth: .infinity, minHeight: 300)
                }
            }
            .padding(.bottom, 20)
        }
    }
}

// Карточка для SOL Balance Change
struct SolBalanceCardView: View {
    let account: AccountData
    let viewModel: TransactionViewModel
    
    private var balanceBefore: Double {
        let currentBalance = Double(account.nativeBalanceChange) / 1_000_000_000.0
        return currentBalance < 0 ? abs(currentBalance) : 0
    }
    
    private var balanceAfter: Double {
        let currentBalance = Double(account.nativeBalanceChange) / 1_000_000_000.0
        return currentBalance > 0 ? currentBalance : 0
    }
    
    private var change: Double {
        Double(account.nativeBalanceChange) / 1_000_000_000.0
    }
    
    private var changeColor: Color {
        change > 0 ? .green : .red
    }
    
    private var changeValue: String {
        "$56.97" // Фиксированное значение для примера
    }
    
    private var accountTags: [String] {
        var tags: [String] = []
        if account.account == "11111111111111111111111111111111" {
            tags.append("PROGRAM")
            return tags
        }
        if abs(change) > 0 {
            tags.append("WRITABLE")
        }
        return tags
    }
    
    private var isSystemProgram: Bool {
        account.account == "11111111111111111111111111111111"
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Адрес и метки
            VStack(alignment: .leading, spacing: 8) {
                // Заголовок с адресом/именем
                HStack(spacing: 6) {
                    if isSystemProgram {
                        Image(systemName: "terminal.fill")
                            .foregroundColor(.blue)
                        Text("System Program")
                            .font(.system(size: 16, weight: .medium))
                    } else {
                        Text(formatWalletAddress(account.account))
                            .font(.system(size: 16, weight: .medium))
                    }
                    
                    Spacer()
                    
                    // Иконка копирования только для не-системных программ
                    if !isSystemProgram {
                        Button(action: {
                            UIPasteboard.general.string = account.account
                            viewModel.showToast(message: "Address copied")
                        }) {
                            Image(systemName: "doc.on.doc")
                                .foregroundColor(.white.opacity(0.5))
                                .font(.system(size: 14))
                        }
                    }
                }
                
                // Теги
                HStack {
                    ForEach(accountTags, id: \.self) { tag in
                        Text(tag)
                            .font(.caption2)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(tagBackground(for: tag))
                            .foregroundColor(tagForeground(for: tag))
                            .cornerRadius(4)
                    }
                }
                
                // Полный адрес
                if !isSystemProgram {
                    Text(account.account)
                        .font(.system(size: 12))
                        .foregroundColor(.white.opacity(0.5))
                }
            }
            
            Divider()
                .background(Color.gray.opacity(0.3))
            
            // Изменение баланса
            VStack(spacing: 12) {
                HStack {
                    Text("Balance Before")
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                    Spacer()
                    Text(String(format: "%.9f", balanceBefore))
                        .font(.system(size: 14))
                }
                
                HStack {
                    Text("Balance After")
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                    Spacer()
                    Text(String(format: "%.9f", balanceAfter))
                        .font(.system(size: 14))
                }
                
                HStack {
                    Text("Change (SOL)")
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                    Spacer()
                    HStack(spacing: 2) {
                        Text(change >= 0 ? "+" : "-")
                            .foregroundColor(changeColor)
                        Text(String(format: "%.9f", abs(change)))
                            .foregroundColor(changeColor)
                    }
                    .font(.system(size: 14, weight: .medium))
                }
                
                HStack {
                    Text("Change Value")
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                    Spacer()
                    Text(changeValue)
                        .font(.system(size: 14))
                }
            }
        }
        .padding(16)
        .background(Color.white.opacity(0.02))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(
                    LinearGradient(
                        gradient: Gradient(colors: [Color.white.opacity(0.2), Color.white.opacity(0.1)]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 0.5
                )
        )
        .padding(.horizontal, 20)
    }
    
    private func tagBackground(for tag: String) -> Color {
        switch tag {
        case "WRITABLE":
            return Color.blue.opacity(0.2)
        case "SIGNER":
            return Color.purple.opacity(0.2)
        case "FEE PAYER":
            return Color.orange.opacity(0.2)
        case "PROGRAM":
            return Color.green.opacity(0.2)
        default:
            return Color.gray.opacity(0.2)
        }
    }
    
    private func tagForeground(for tag: String) -> Color {
        switch tag {
        case "WRITABLE":
            return Color.blue
        case "SIGNER":
            return Color.purple
        case "FEE PAYER":
            return Color.orange
        case "PROGRAM":
            return Color.green
        default:
            return Color.gray
        }
    }
}

// Представление для таба Token Balance Change
struct TokenBalanceChangeTabView: View {
    let transaction: DetailedTransaction
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Заголовок раздела
                Text("Token Balance Changes")
                    .font(.system(size: 18, weight: .medium))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 20)
                    .padding(.top, 10)
                
                // Показ сообщения "Нет данных"
                VStack {
                    Spacer(minLength: 80)
                    
                    Image(systemName: "tray")
                        .font(.system(size: 40))
                        .foregroundColor(.gray)
                        .padding()
                    
                    Text("No data")
                        .font(.headline)
                        .foregroundColor(.gray)
                    
                    Spacer()
                }
                .frame(maxWidth: .infinity, minHeight: 300)
            }
            .padding(.bottom, 20)
        }
    }
}

// Компонент для отображения операции перевода
struct TransferActionView: View {
    let from: String
    let to: String
    let amount: String
    let programName: String
    
    var body: some View {
        VStack(spacing: 20) {
            VStack(alignment: .leading, spacing: 20) {
                VStack(alignment: .leading) {
                    Text("Interact with instruction TRANSFER on")
                        .foregroundStyle(Color.gray)
                        .font(.caption)
                    HStack {
                        ZStack {
                            Circle()
                                .foregroundStyle(Color.blue.opacity(0.2))
                                .frame(width: 20, height: 20)
                            if programName == "System Program" {
                                Image(systemName: "gearshape.fill")
                                    .foregroundStyle(Color.blue)
                                    .font(.system(size: 10))
                            } else {
                                // Для других программ можно добавить другие иконки
                                Image(systemName: "cube.fill")
                                    .foregroundStyle(Color.gray)
                                    .font(.system(size: 10))
                            }
                        }
                        Text(programName)
                            .foregroundStyle(.white)
                            .font(.subheadline)
                    }
                    
                }
                
                HStack {
                    VStack(alignment: .leading) {
                        Text("Transfer from")
                            .foregroundStyle(Color.gray)
                            .font(.caption)
                        Text(from)
                            .foregroundStyle(.white)
                            .font(.subheadline)
                    }
                    .frame(width: 160, alignment: .leading)
                    
                    VStack(alignment: .leading) {
                        Text("to")
                            .foregroundStyle(Color.gray)
                            .font(.caption)
                        Text(to)
                            .foregroundStyle(.white)
                            .font(.subheadline)
                    }
                    .frame(width: 160, alignment: .leading)
                    
                }
                
                HStack {
                    Text("for")
                        .foregroundStyle(.white)
                        .font(.subheadline)
                    Text(amount)
                        .foregroundStyle(.white)
                        .font(.subheadline)
                    TokenLogoView(
                        logoUrl: "https://light.dangervalley.com/static/sol.png",
                        symbol: "SOL",
                        size: 16
                    )
                    Text("SOL")
                        .foregroundStyle(.white)
                        .font(.subheadline)
                    
                    // Примерная конвертация в USD
                    Text("($" + String(format: "%.2f", (Double(amount) ?? 0) * 50) + ")")
                        .foregroundStyle(.gray)
                        .font(.subheadline)
                }
                
            }
            .padding(10)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
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
}

#Preview {
    TransactionDetails()
        .environmentObject(NavigationCoordinator())
}
