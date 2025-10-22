//
//  SettingsScreenView.swift
//  Travel Schedule
//
//  Created by Ульта on 18.10.2025.
//

import SwiftUI

struct SettingsScreenView: View {
    @StateObject private var networkMonitor = NetworkMonitor()
    @State private var showNoInternet = false
    
    var body: some View {
        VStack {
            Spacer()
            
            // Заголовок по центру
            Text("Настройки")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(Color("Black"))
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color("White"))
        .onChange(of: networkMonitor.isConnected) { isConnected in
            if !isConnected {
                showNoInternet = true
            } else if isConnected && showNoInternet {
                // Автоматически скрываем экран "Нет интернета" при восстановлении соединения
                showNoInternet = false
            }
        }
        .fullScreenCover(isPresented: $showNoInternet) {
            NoInternetView()
        }
    }
}

#Preview {
    SettingsScreenView()
}
