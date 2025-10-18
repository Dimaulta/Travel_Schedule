//
//  SplashScreenViewModel.swift
//  Travel Schedule
//
//  Created by Ульта on 18.10.2025.
//

import Foundation

final class SplashScreenViewModel: ObservableObject {
    @Published var isActive = false
    
    func startTimer() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.isActive = true
        }
    }
}

