//
//  ServerErrorView.swift
//  Travel Schedule
//
//  Created by Ульта on 22.10.2025.
//

import SwiftUI

struct ServerErrorView: View {
    var body: some View {
        VStack(spacing: 0) {
            // Основной контент
            VStack(spacing: 20) {
                Spacer()
                
                // Иконка ошибки сервера
                Image("ServerError")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 223, height: 223)
                
                // Текст ошибки
                Text("Ошибка сервера")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(Color("Black"))
                    .multilineTextAlignment(.center)
                
                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color("White"))
        }
    }
}

#Preview {
    ServerErrorView()
}
