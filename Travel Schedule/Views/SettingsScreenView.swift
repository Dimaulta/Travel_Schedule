//
//  SettingsScreenView.swift
//  Travel Schedule
//
//  Created by Ульта on 18.10.2025. 
//

import SwiftUI

struct SettingsScreenView: View {
    var body: some View {
        VStack {
            Spacer()
            
            // Заголовок по центру
            Text("Настройки")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(Color("AppBlack"))
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color("AppWhite"))
    }
}

#Preview {
    SettingsScreenView()
}
