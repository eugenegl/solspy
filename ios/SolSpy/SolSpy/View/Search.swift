//
//  Search.swift
//  SolSpy
//
//  Created by Евгений Голота on 28.04.2025.
//

import SwiftUI

struct Search: View {
    @State private var isShowing: Bool = false
    @State private var searchText: String = ""
    @State private var isSearching: Bool = false
    var background: Color = Color(red: 0.027, green: 0.035, blue: 0.039)
    
    var body: some View {
        ZStack {
            
            // Основной фон
            background.ignoresSafeArea()
            
            VStack {
                
                Text("solspy")
                    .font(.system(size: 22, weight: .regular))
                    .foregroundStyle(Color(red: 0.247, green: 0.918, blue: 0.286))
                    .padding(.top, 10)
                
                Spacer()
                
                // Строка поиска
                HStack {
                    TextField("", text: $searchText)
                        .placeholder(when: searchText.isEmpty) {
                            Text("search")
                                .font(.system(size: 16, weight: .regular))
                                .foregroundStyle(.white.opacity(0.3))
                            
                        }
                        .font(.system(size: 16, weight: .regular))
                        .foregroundStyle(.white)
                        .padding(.vertical, 12)
                        .cornerRadius(15)
                    
                    Button(action: {
                        pasteFromClipboard()
                    }) {
                        Text("paste")
                            .font(.system(size: 16, weight: .regular))
                            .foregroundStyle(Color(red: 0.247, green: 0.918, blue: 0.286))
                    }
                }
                .padding(.horizontal, 20)
                
                

                Spacer()
                
                // Отображение процесса поиска внутри кнопки
                Button(action: {
                    performSearch()
                }) {
                    HStack {
                        if isSearching {
                            // Показываем индикатор загрузки внутри кнопки
                            LoadingView()
                                .scaleEffect(0.7)
                        } else {
                            // Показываем иконку лупы
                            Image(systemName: "magnifyingglass")
                                .font(.system(size: 20, weight: .regular))
                                .foregroundStyle(.black)
                        }
                    }
                    .frame(width: 90, height: 60)
                    .background(Color(red: 0.247, green: 0.918, blue: 0.286))
                    .cornerRadius(20)
                    .padding(.bottom, 10)
                }
            }
        }
    }
    
    // Функция для вставки текста из буфера обмена
    private func pasteFromClipboard() {
        if let string = UIPasteboard.general.string {
            searchText = string
        }
    }
    
    // Функция для выполнения поиска
    private func performSearch() {
        guard !searchText.isEmpty else { return }
        
        // Симуляция поиска
        isSearching = true
        
        // Здесь должна быть реальная логика поиска
        // Например, вызов API или поиск в локальной базе данных
        
        // Для демонстрации просто отключим индикатор загрузки через 2 секунды
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            isSearching = false
            // Здесь должна быть обработка результатов поиска
        }
    }
}

// Расширение для создания placeholder в TextField
extension View {
    func placeholder<Content: View>(
        when shouldShow: Bool,
        alignment: Alignment = .leading,
        @ViewBuilder placeholder: () -> Content) -> some View {
        
        ZStack(alignment: alignment) {
            placeholder().opacity(shouldShow ? 1 : 0)
            self
        }
    }
}

#Preview {
    Search()
}
