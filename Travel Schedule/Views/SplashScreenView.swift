//
//  SplashScreenView.swift
//  Travel Schedule
//
//  Created by Ульта on 18.10.2025.
//

import SwiftUI

struct SplashScreenView: View {
    @StateObject private var viewModel = SplashScreenViewModel()
    
    var body: some View {
        if viewModel.isActive {
            MainScreenView()
        } else {
            Image("Splash")
                .resizable()
                .ignoresSafeArea()
                .onAppear {
                    viewModel.startTimer()
                }
        }
    }
}

#Preview {
    SplashScreenView()
}

