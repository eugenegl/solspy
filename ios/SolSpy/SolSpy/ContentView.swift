//
//  ContentView.swift
//  SolSpy
//
//  Created by Евгений Голота on 28.04.2025.
//

import SwiftUI

struct ContentView: View {
    
    @State private var showSplash: Bool = true
    @EnvironmentObject private var coordinator: NavigationCoordinator
    
    var body: some View {
        VStack {
           
            if showSplash {
                Splash()
            } else {
                Search()
                    .environmentObject(coordinator)
            }
            
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
                withAnimation {
                    showSplash = false
                }
            }
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(NavigationCoordinator())
}
