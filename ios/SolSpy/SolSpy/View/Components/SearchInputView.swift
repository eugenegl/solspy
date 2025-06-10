import SwiftUI

struct SearchInputView: View {
    @Binding var searchText: String
    let onPaste: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            // Текстовое поле
            HStack(spacing: 12) {
                // Иконка поиска
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(.white.opacity(0.5))
                
                // Поле ввода
                TextField("", text: $searchText)
                    .placeholder(when: searchText.isEmpty) {
                        Text("Search")
                            .font(.system(size: 15, weight: .regular))
                            .foregroundStyle(.white.opacity(0.4))
                    }
                    .font(.system(size: 15, weight: .regular))
                    .foregroundStyle(.white)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                
                // Кнопка очистки
                if !searchText.isEmpty {
                    Button(action: {
                        searchText = ""
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 16))
                            .foregroundStyle(.white.opacity(0.5))
                    }
                }
                
                // Кнопка вставки
                Button(action: onPaste) {
                    Text("Paste")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(Color(red: 0.247, green: 0.918, blue: 0.286))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            RoundedRectangle(cornerRadius: 6)
                                .fill(Color(red: 0.247, green: 0.918, blue: 0.286).opacity(0.15))
                        )
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.black.opacity(0.4))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(
                                searchText.isEmpty ? 
                                Color.white.opacity(0.1) : 
                                Color(red: 0.247, green: 0.918, blue: 0.286).opacity(0.5),
                                lineWidth: 1
                            )
                    )
            )
            .padding(.horizontal, 20)
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
    VStack(spacing: 20) {
        SearchInputView(
            searchText: .constant(""),
            onPaste: {}
        )
        
        SearchInputView(
            searchText: .constant("5RA6TFaKbS7ofN9m..."),
            onPaste: {}
        )
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color(red: 0.027, green: 0.035, blue: 0.039))
} 