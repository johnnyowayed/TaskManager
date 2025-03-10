//
//  LaunchScreen.swift
//  TaskManager
//
//  Created by Johnny Owayed on 10/03/2025.
//

import SwiftUI

struct LaunchScreen: View {
    @Binding var showLaunchScreen: Bool
    @State private var scale: CGFloat = 0.7
    @State private var opacity: Double = 0
    @State private var loadingDots: Int = 0
    
    let timer = Timer.publish(every: 0.4, on: .main, in: .common).autoconnect()
    
    var body: some View {
        ZStack {
            Color(UIColor.systemBackground)
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                Image("app_logo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 120, height: 120)
                    .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                    .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
                
                Text("Task Manager")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                // Custom loading animation
                HStack(spacing: 8) {
                    ForEach(0..<3) { index in
                        Circle()
                            .fill(Color.accentColor)
                            .frame(width: 10, height: 10)
                            .scaleEffect(loadingDots >= index + 1 ? 1 : 0.5)
                            .animation(.easeInOut(duration: 0.3), value: loadingDots)
                    }
                }
                .padding(.top, 20)
            }
            .scaleEffect(scale)
            .opacity(opacity)
            .onReceive(timer) { _ in
                // Cycle the loading animation
                loadingDots = (loadingDots + 1) % 4
            }
            .onAppear {
                withAnimation(.easeInOut(duration: 0.7)) {
                    self.scale = 1.0
                    self.opacity = 1.0
                }
                
                // Dismiss the launch screen after a delay
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    withAnimation(.easeOut(duration: 0.5)) {
                        self.opacity = 0
                        self.scale = 1.1
                    }
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        self.showLaunchScreen = false
                    }
                }
            }
        }
    }
}

#Preview {
    LaunchScreen(showLaunchScreen: .constant(true))
}
