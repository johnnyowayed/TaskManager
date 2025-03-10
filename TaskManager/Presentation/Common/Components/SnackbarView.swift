//
//  SnackbarView.swift
//  TaskManager
//
//  Created by Johnny Owayed on 10/03/2025.
//

import SwiftUI
import Combine

struct SnackbarView: View {
    let message: String
    let actionLabel: String
    let action: () -> Void
    let secondsRemaining: Int
    
    var body: some View {
        HStack {
            Text(message)
                .foregroundColor(.white)
            
            Spacer()
            
            // Show remaining time
            Text("\(secondsRemaining)s")
                .foregroundColor(.white.opacity(0.7))
                .padding(.horizontal, 8)
            
            Button(action: action) {
                Text(actionLabel)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
            }
        }
        .padding()
        .background(Color.black.opacity(0.8))
        .cornerRadius(8)
        .padding(.horizontal)
        .padding(.bottom, 8)
        .transition(.move(edge: .bottom).combined(with: .opacity))
    }
}
