//
//  ContentView.swift
//  SolSpy
//
//  Created by Евгений Голота on 28.04.2025.
//

import SwiftUI

struct ContentView: View {
    
    @State private var showSplash: Bool = false
    
    var body: some View {
        VStack {
           
            if showSplash {
                Search()
            } else {
                Splash()
            }
            
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
                withAnimation {
                    showSplash = true
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
