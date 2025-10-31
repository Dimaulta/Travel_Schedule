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
    @State private var showNoInternetDebounce: DispatchWorkItem?
    @State private var hideNoInternetDebounce: DispatchWorkItem?
    @AppStorage("isDarkModeEnabled") private var isDarkModeEnabled = false
    
    var body: some View {
        VStack(spacing: 0) {
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
                                .foregroundColor(selectedTab == 0 ? Color("AppBlack") : Color("GrayUniversal"))
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
                                .foregroundColor(selectedTab == 1 ? Color("AppBlack") : Color("GrayUniversal"))
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
                .padding(.vertical, 8)
                .background(Color("AppWhite"))
            }
        }
        .background(Color("AppWhite"))
        .overlay(alignment: .center) {
            if showServerError {
                ServerErrorView(onTabSelected: { tabIndex in
                    selectedTab = tabIndex
                    withAnimation(.easeInOut(duration: 0.25)) { showServerError = false }
                })
                .ignoresSafeArea(edges: .top)
                .transition(.move(edge: .bottom).combined(with: .opacity))
                .zIndex(1000)
            }
        }
        .overlay(alignment: .center) {
            if showNoInternet {
                NoInternetView(onTabSelected: { tabIndex in
                    selectedTab = tabIndex
                    withAnimation(.easeInOut(duration: 0.25)) { showNoInternet = false }
                })
                .ignoresSafeArea(edges: .top)
                .transition(.move(edge: .bottom).combined(with: .opacity))
                .zIndex(1000)
            }
        }
        .onChange(of: networkMonitor.isConnected) { isConnected in
            if !isConnected {
                
                hideNoInternetDebounce?.cancel()
                showNoInternetDebounce?.cancel()
                let work = DispatchWorkItem {
                    if networkMonitor.isConnected == false {
                        withAnimation(.easeInOut(duration: 0.25)) { showNoInternet = true }
                    }
                }
                showNoInternetDebounce = work
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4, execute: work)
            } else {
                showNoInternetDebounce?.cancel()
                hideNoInternetDebounce?.cancel()
                let work = DispatchWorkItem {
                    if networkMonitor.isConnected == true {
                        withAnimation(.easeInOut(duration: 0.25)) { showNoInternet = false }
                    }
                }
                hideNoInternetDebounce = work
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: work)
            }
        }
        .preferredColorScheme(isDarkModeEnabled ? .dark : .light)
    }
}

#Preview {
    MainTabView()
}
