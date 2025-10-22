//
//  NoInternetView.swift
//  Travel Schedule
//
//  Created by Ульта on 22.10.2025.
//

import SwiftUI

struct NoInternetView: View {
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
        }
    }
}

#Preview {
    NoInternetView()
}
