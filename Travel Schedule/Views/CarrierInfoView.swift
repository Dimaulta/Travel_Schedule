//
//  CarrierInfoView.swift
//  Travel Schedule
//
//  Created by Ульта on 22.10.2025.
//

import SwiftUI

struct CarrierInfoView: View {
    let onBack: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            // Навигационная панель
            VStack(spacing: 0) {
                Color("White").frame(height: 12).ignoresSafeArea(edges: .top)
                
                // Навбар с заголовком по центру и кнопкой назад слева
                ZStack {
                    Text("Информация о перевозчике")
                        .font(.system(size: 17, weight: .bold))
                        .foregroundColor(Color("Black"))
                        .multilineTextAlignment(.center)
                    
                    HStack {
                        Button(action: onBack) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(Color("Black"))
                        }
                        .padding(.leading, 16)
                        
                        Spacer()
                    }
                }
                .padding(.vertical, 12)
                .padding(.top, 8)
                .padding(.bottom, 16)
            }
            .background(Color("White"))
            
            // Основной контент (пока пустой)
            Spacer()
        }
        .background(Color("White"))
        .navigationBarHidden(true)
        .toolbar(.hidden, for: .tabBar)
    }
}

#Preview {
    CarrierInfoView(onBack: {})
}
