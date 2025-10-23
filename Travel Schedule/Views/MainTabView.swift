//
//  MainTabView.swift
//  Travel Schedule
//
//  Created by Ульта on 22.10.2025.
//

import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 0
    @State private var showServerError = false
    @State private var showNoInternet = false
    @StateObject private var networkMonitor = NetworkMonitor()
    @StateObject private var sessionManager = SessionManager()
    
    var body: some View {
        VStack(spacing: 0) {
            // Основной контент с NavigationStack
            if selectedTab == 0 {
                NavigationStack {
                    MainScreenView(
                        sessionManager: sessionManager,
                        onServerError: { showServerError = true },
                        onNoInternet: { showNoInternet = true }
                    )
                }
            } else {
                NavigationStack {
                    SettingsScreenView()
                }
            }
            
            // Tab Bar с правильным дизайном
            VStack(spacing: 0) {
                Divider()
                    .background(Color("GrayUniversal"))
                
                HStack {
                    Button(action: {
                        selectedTab = 0
                    }) {
                        VStack(spacing: 4) {
                            Image("Schedule")
                                .renderingMode(Image.TemplateRenderingMode.template)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 30, height: 30)
                                .foregroundColor(selectedTab == 0 ? Color("Black") : Color("GrayUniversal"))
                        }
                    }
                    .frame(maxWidth: .infinity)
                    
                    Button(action: {
                        selectedTab = 1
                    }) {
                        VStack(spacing: 4) {
                            Image("Settings")
                                .renderingMode(Image.TemplateRenderingMode.template)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 30, height: 30)
                                .foregroundColor(selectedTab == 1 ? Color("Black") : Color("GrayUniversal"))
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
                .padding(.vertical, 8)
                .background(Color("White"))
            }
        }
        .background(Color("White"))
        .fullScreenCover(isPresented: $showServerError) {
            ServerErrorView()
        }
        .fullScreenCover(isPresented: $showNoInternet) {
            NoInternetView()
        }
        .onChange(of: networkMonitor.isConnected) { isConnected in
            if !isConnected {
                showNoInternet = true
            } else if isConnected && showNoInternet {
                // Автоматически скрываем экран "Нет интернета" при восстановлении соединения
                showNoInternet = false
            }
        }
    }
}

#Preview {
    MainTabView()
}
