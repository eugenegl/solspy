import SwiftUI

struct PulseAnimation: View {
    @State private var animating = false
    
    var body: some View {
        ZStack {
            // Внешний круг с пульсацией
            Circle()
                .stroke(Color.white.opacity(0.3), lineWidth: 2)
                .scaleEffect(animating ? 1.5 : 0.8)
                .opacity(animating ? 0 : 1)
            
            // Средний круг с пульсацией
            Circle()
                .stroke(Color.white.opacity(0.6), lineWidth: 2)
                .scaleEffect(animating ? 1.2 : 0.9)
                .opacity(animating ? 0.5 : 1)
            
            // Внутренний круг
            Circle()
                .fill(Color.white)
                .scaleEffect(0.5)
        }
        .onAppear {
            withAnimation(Animation.easeInOut(duration: 1.2).repeatForever(autoreverses: true)) {
                animating = true
            }
        }
    }
}

#Preview {
    PulseAnimation()
        .frame(width: 50, height: 50)
        .background(Color.black)
} 