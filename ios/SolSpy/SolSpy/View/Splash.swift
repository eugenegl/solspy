//
//  Splash.swift
//  SolSpy
//
//  Created by Евгений Голота on 28.04.2025.
//

import SwiftUI

struct Splash: View {
    
    @State private var isShowing: Bool = false
    var background: Color = Color(red: 0.027, green: 0.035, blue: 0.039)
    
    var body: some View {
        ZStack {
            
            // Основной фон
            background.ignoresSafeArea()
            
            VStack {

                HStack {
                    Text("S")
                        .font(.system(size: 500, weight: .regular))
                        .foregroundStyle(Color(red: 0.247, green: 0.918, blue: 0.286))
                    Text(".")
                        .font(.system(size: 500, weight: .regular))
                        .foregroundStyle(Color(red: 0.247, green: 0.918, blue: 0.286))
                }
                .offset(x: -100)
                
                Spacer()
                
                HStack {
                    Text("solspy")
                        .font(.system(size: 22, weight: .regular))
                        .foregroundStyle(Color(red: 0.247, green: 0.918, blue: 0.286))
                    Text("/ solana explorer")
                        .font(.system(size: 22, weight: .regular))
                        .foregroundStyle(Color.gray.opacity(0.3))
                }
                
                Spacer()
                
            }
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    withAnimation {
                        isShowing = true
                    }
                }
            }
        }
    }
}

#Preview {
    Splash()
}
