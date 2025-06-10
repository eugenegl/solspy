import SwiftUI

struct TokenImageView: View {
    let token: TopToken
    let size: CGFloat
    
    @State private var currentURLIndex = 0
    @State private var isLoading = true
    
    var body: some View {
        AsyncImage(url: URL(string: token.logoURL ?? "")) { phase in
            switch phase {
            case .success(let image):
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            case .failure(_), .empty:
                // Если логотип не загрузился - показываем красивую заглушку
                fallbackView
            @unknown default:
                fallbackView
            }
        }
        .frame(width: size, height: size)
        .clipShape(Circle())
    }
    
    private var currentURL: URL? {
        guard currentURLIndex < allURLs.count else { return nil }
        return URL(string: allURLs[currentURLIndex])
    }
    
    private var allURLs: [String] {
        var urls: [String] = []
        
        // Сначала пробуем URL из API
        if let logoURL = token.logoURL, !logoURL.isEmpty {
            urls.append(logoURL)
        }
        
        // Затем fallback URL-ы
        urls.append(contentsOf: token.fallbackLogoURLs)
        
        return urls
    }
    
    private var fallbackView: some View {
        Circle()
            .fill(LinearGradient(
                colors: gradientColors,
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ))
            .overlay(
                Text(String(token.symbol.prefix(1)))
                    .font(.system(size: size * 0.5, weight: .bold))
                    .foregroundStyle(.white)
            )
    }
    
    private var gradientColors: [Color] {
        switch token.symbol {
        case "JUP":
            return [Color(red: 0.9, green: 0.4, blue: 0.1), Color(red: 1.0, green: 0.6, blue: 0.0)]
        case "PYTH":
            return [Color(red: 0.5, green: 0.2, blue: 0.9), Color(red: 0.7, green: 0.4, blue: 1.0)]
        case "JTO":
            return [Color(red: 0.1, green: 0.8, blue: 0.3), Color(red: 0.2, green: 1.0, blue: 0.5)]
        case "RAY":
            return [Color(red: 0.2, green: 0.4, blue: 0.9), Color(red: 0.4, green: 0.6, blue: 1.0)]
        case "ORCA":
            return [Color(red: 0.9, green: 0.2, blue: 0.5), Color(red: 1.0, green: 0.4, blue: 0.7)]
        default:
            return [Color(red: 0.6, green: 0.6, blue: 0.6), Color(red: 0.8, green: 0.8, blue: 0.8)]
        }
    }
    
    private func tryNextURL() {
        currentURLIndex += 1
        isLoading = true
    }
}

#Preview {
    HStack(spacing: 20) {
        TokenImageView(
            token: TopToken.mockTokens[0],
            size: 20
        )
        
        TokenImageView(
            token: TopToken.mockTokens[1],
            size: 32
        )
        
        TokenImageView(
            token: TopToken.mockTokens[2],
            size: 48
        )
    }
    .padding()
    .background(Color.black)
} 