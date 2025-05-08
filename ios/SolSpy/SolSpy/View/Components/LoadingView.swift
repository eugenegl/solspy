import SwiftUI

struct LoadingView: View {
    @State private var isAnimating = false
    private let dotCount = 3
    private let dotSize: CGFloat = 10
    private let dotSpacing: CGFloat = 8
    private let animationDuration: Double = 0.6
    
    var body: some View {
        HStack(spacing: dotSpacing) {
            ForEach(0..<dotCount, id: \.self) { index in
                Circle()
                    .fill(Color.white)
                    .frame(width: dotSize, height: dotSize)
                    .scaleEffect(isAnimating ? 1.2 : 0.5)
                    .opacity(isAnimating ? 1.0 : 0.3)
                    .animation(
                        Animation.easeInOut(duration: animationDuration)
                            .repeatForever(autoreverses: true)
                            .delay(Double(index) * (animationDuration / Double(dotCount))),
                        value: isAnimating
                    )
            }
        }
        .padding(30)
        .cornerRadius(15)
        .onAppear {
            isAnimating = true
        }
    }
}

struct ShimmerLoadingView: View {
    @State private var isAnimating = false
    
    var body: some View {
        ZStack {
            // Основной фон
            RoundedRectangle(cornerRadius: 15)
                .fill(Color.gray.opacity(0.2))
                .frame(height: 120)
            
            // Градиент для эффекта шиммера
            RoundedRectangle(cornerRadius: 15)
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color.clear,
                            Color.white.opacity(0.2),
                            Color.clear
                        ]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(height: 120)
                .offset(x: isAnimating ? 200 : -200)
        }
        .mask(
            // Маска в виде контента
            VStack(alignment: .leading, spacing: 15) {
                RoundedRectangle(cornerRadius: 5)
                    .frame(width: 150, height: 20)
                
                RoundedRectangle(cornerRadius: 5)
                    .frame(height: 30)
                
                HStack {
                    RoundedRectangle(cornerRadius: 5)
                        .frame(width: 80, height: 15)
                    
                    Spacer()
                    
                    RoundedRectangle(cornerRadius: 5)
                        .frame(width: 60, height: 15)
                }
            }
            .padding()
        )
        .onAppear {
            withAnimation(Animation.linear(duration: 1.5).repeatForever(autoreverses: false)) {
                isAnimating = true
            }
        }
    }
}

#Preview {
    VStack(spacing: 30) {
        LoadingView()
        ShimmerLoadingView()
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color.black)
} 
