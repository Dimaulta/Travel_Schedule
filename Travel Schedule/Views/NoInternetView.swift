//
//  NoInternetView.swift
//  Travel Schedule
//
//  Created by Ульта on 22.10.2025.
//

import SwiftUI

struct NoInternetView: View {
    let onTabSelected: (Int) -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            // Основной контент
            VStack(spacing: 20) {
                Spacer()
                
                // Иконка отсутствия интернета
                Image("NoInternet")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 223, height: 223)
                
                // Текст отсутствия интернета
                Text("Нет интернета")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(Color("Black"))
                    .multilineTextAlignment(.center)
                
                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color("White"))
            
            // Tab Bar
            VStack(spacing: 0) {
                Divider()
                    .background(Color("GrayUniversal"))
                
                HStack {
                    Button(action: {
                        onTabSelected(0)
                    }) {
                        VStack(spacing: 4) {
                            Image("Schedule")
                                .renderingMode(Image.TemplateRenderingMode.template)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 30, height: 30)
                                .foregroundColor(Color("Black"))
                        }
                    }
                    .frame(maxWidth: .infinity)
                    
                    Button(action: {
                        onTabSelected(1)
                    }) {
                        VStack(spacing: 4) {
                            Image("Settings")
                                .renderingMode(Image.TemplateRenderingMode.template)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 30, height: 30)
                                .foregroundColor(Color("GrayUniversal"))
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
                .padding(.vertical, 8)
                .background(Color("White"))
            }
        }
        .background(Color("White"))
    }
}

#Preview {
    NoInternetView(onTabSelected: { _ in })
}
