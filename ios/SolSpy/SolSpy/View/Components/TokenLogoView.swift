import SwiftUI

struct TokenLogoView: View {
    let logoUrl: String?
    let symbol: String
    let size: CGFloat
    
    init(logoUrl: String?, symbol: String, size: CGFloat = 20) {
        self.logoUrl = logoUrl
        self.symbol = symbol
        self.size = size
    }
    
    var body: some View {
        AsyncImage(url: URL(string: logoUrl ?? "")) { image in
            image.resizable()
                .aspectRatio(contentMode: .fill)
        } placeholder: {
            Circle()
                .fill(Color.white.opacity(0.1))
                .overlay(
                    Text(symbol.prefix(1))
                        .font(.system(size: size * 0.4))
                        .foregroundColor(.white)
                )
        }
        .frame(width: size, height: size)
        .clipShape(Circle())
    }
}

#Preview {
    VStack(spacing: 20) {
        TokenLogoView(logoUrl: "https://light.dangervalley.com/static/sol.png", symbol: "SOL")
        TokenLogoView(logoUrl: nil, symbol: "USDC")
    }
    .padding()
    .background(Color.black)
} 