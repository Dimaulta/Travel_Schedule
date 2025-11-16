//
//  SettingsScreenView.swift
//  Travel Schedule
//
//  Created by Ульта on 18.10.2025. 
//

import SwiftUI

struct SettingsScreenView: View {
    @StateObject private var viewModel = SettingsViewModel()
    @State private var showUserAgreement = false
    @AppStorage("storiesViewedIndices") private var storiesViewedIndices = ""
    
    var body: some View {
        VStack(spacing: 0) {

            VStack(spacing: 0) {
                HStack(spacing: 12) {
                    Text("Темная тема")
                        .font(.system(size: 17))
                        .foregroundColor(Color("AppBlack"))
                    Spacer()
                    Toggle("", isOn: $viewModel.isDarkModeEnabled)
                        .labelsHidden()
                        .tint(Color("BlueUniversal"))
                }
                .padding(.horizontal, 16)
                .frame(height: 56)
                
                
                Button(action: { showUserAgreement = true }) {
                    HStack(spacing: 12) {
                        Text("Пользовательское соглашение")
                            .font(.system(size: 17))
                            .foregroundColor(Color("AppBlack"))
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(Color("AppBlack"))
                    }
                    .contentShape(Rectangle())
                }
                .padding(.horizontal, 16)
                .frame(height: 56)
            }
            .background(Color("AppWhite"))
            .padding(.top, 8)
            
            Spacer()
            
            VStack(spacing: 6) {
                 /* Button(action: {
                     storiesViewedIndices = ""
                     viewModel.resetStoriesViewed()
                 }) {
                     Text("Сбросить сторис")
                         .font(.system(size: 13, weight: .semibold))
                         .foregroundColor(Color("BlueUniversal"))
                 }
                 .padding(.bottom, 8) */
                Text("Приложение использует API «Яндекс.Расписания»")
                    .font(.system(size: 12))
                    .foregroundColor(Color("GrayUniversal"))
                Text("Версия 1.0 (beta)")
                    .font(.system(size: 12))
                    .foregroundColor(Color("GrayUniversal"))
            }
            .padding(.bottom, 12)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color("AppWhite"))
        .fullScreenCover(isPresented: $showUserAgreement) {
            UserAgreementView(onBack: { showUserAgreement = false })
        }
    }
}

#Preview {
    SettingsScreenView()
}
