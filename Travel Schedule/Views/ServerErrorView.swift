//
//  ServerErrorView.swift
//  Travel Schedule
//
//  Created by Ульта on 22.10.2025.
//

import SwiftUI

struct ServerErrorView: View {
    let onTabSelected: (Int) -> Void
    
    var body: some View {
        VStack(spacing: 0) {
         
            VStack(spacing: 20) {
                Spacer()
                
                Image("ServerError")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 223, height: 223)
                
                Text("Ошибка сервера")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(Color("AppBlack"))
                    .multilineTextAlignment(.center)
                
                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color("AppWhite"))
            
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
                                .foregroundColor(Color("AppBlack"))
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
                .background(Color("AppWhite"))
            }
        }
        .background(Color("AppWhite"))
    }
}

#Preview {
    ServerErrorView(onTabSelected: { _ in })
}
