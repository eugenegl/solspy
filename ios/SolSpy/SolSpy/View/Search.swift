//
//  Search.swift
//  SolSpy
//
//  Created by Евгений Голота on 28.04.2025.
//

import SwiftUI

struct Search: View {
    @State private var isShowing: Bool = false
    var background: Color = Color(red: 0.027, green: 0.035, blue: 0.039)
    
    var body: some View {
        ZStack {
            
            // Основной фон
            background.ignoresSafeArea()
            
            VStack {
                
                Text("solspy")
                    .font(.system(size: 22, weight: .regular))
                    .foregroundStyle(Color(red: 0.247, green: 0.918, blue: 0.286))
                
                Spacer()
                
                Text("search input")
                    .font(.system(size: 22, weight: .regular))
                    .foregroundStyle(Color(red: 0.247, green: 0.918, blue: 0.286))
                
                Spacer()
                
                Button(action: {
                    //
                }) {
                    HStack {
                        Text("Search")
                            .font(.system(size: 16, weight: .regular))
                            .foregroundStyle(.black)
                    }
                    .frame(width: 90, height: 60)
                    .background(Color(red: 0.247, green: 0.918, blue: 0.286))
                    .cornerRadius(20)
                    .padding(.bottom, 10)
                }
                
                
                
            }
            
        }
    }
}

#Preview {
    Search()
}
