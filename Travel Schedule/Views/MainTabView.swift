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
                        onNoInternet: { showNoInternet = true },
                        onTabSelected: { tabIndex in
                            selectedTab = tabIndex
                        }
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
            ServerErrorView(onTabSelected: { tabIndex in
                selectedTab = tabIndex
                showServerError = false
            })
        }
        .fullScreenCover(isPresented: $showNoInternet) {
            NoInternetView(onTabSelected: { tabIndex in
                selectedTab = tabIndex
                showNoInternet = false
            })
            .onAppear {
                print("🔍 MainTabView: NoInternetView появился")
            }
            .onDisappear {
                print("🔍 MainTabView: NoInternetView исчез")
            }
        }
        .onChange(of: showNoInternet) { newValue in
            print("🔍 MainTabView: showNoInternet изменился на: \(newValue)")
        }
        .onChange(of: networkMonitor.isConnected) { isConnected in
            print("🔍 MainTabView: onChange сработал, isConnected = \(isConnected)")
            print("🔍 MainTabView: showNoInternet = \(showNoInternet)")
            if !isConnected {
                print("🔍 MainTabView: Показываем экран 'Нет интернета'")
                showNoInternet = true
            } else if isConnected && showNoInternet {
                print("🔍 MainTabView: Скрываем экран 'Нет интернета'")
                // Автоматически скрываем экран "Нет интернета" при восстановлении соединения
                showNoInternet = false
            }
        }
        .onAppear {
            print("🔍 MainTabView: onAppear вызван")
        }
    }
}

#Preview {
    MainTabView()
}
