//
//  CarrierCardView.swift
//  Travel Schedule
//
//  Created by Ульта on 20.10.2025.
//

import SwiftUI

struct CarrierCardView: View {
    let trip: TripInfo
    
    var body: some View {
        VStack(spacing: 16) {
            HStack(alignment: .top) {
                // Информация о перевозчике
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 12) {
                        // Логотип перевозчика
                        if let logo = trip.carrier.logo, let url = URL(string: logo) {
                            AsyncImage(url: url) { image in
                                ZStack {
                                    // Фон
                                    RoundedRectangle(cornerRadius: 4)
                                        .fill(Color("GrayUniversal"))
                                        .frame(width: 38, height: 38)
                                    
                                    // Изображение, обрезанное справа
                                    image
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: 38, height: 38) // Уменьшаем логотип
                                        .offset(x: 100) // Сдвигаем влево на 80px, чтобы показать левую часть
                                        .clipped()
                                }
                                .clipShape(RoundedRectangle(cornerRadius: 4))
                            } placeholder: {
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(Color("GrayUniversal"))
                                    .frame(width: 38, height: 38)
                            }
                        } else {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color("GrayUniversal"))
                                .frame(width: 38, height: 38)
                        }
                        
                        Text(trip.carrier.title)
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(Color("BlackUniversal"))
                    }
                    
                    // Дополнительная информация (пересадки)
                    if let transferInfo = trip.transferInfo {
                        Text(transferInfo)
                            .font(.system(size: 12))
                            .foregroundColor(Color("RedUniversal"))
                    }
                }
                
                Spacer()
                
                // Дата
                Text(trip.date)
                    .font(.system(size: 17, weight: .medium))
                    .foregroundColor(Color("BlackUniversal"))
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
            
            // Время и длительность
            HStack {
                // Время отправления
                Text(trip.departureTime)
                    .font(.system(size: 17, weight: .medium))
                    .foregroundColor(Color("BlackUniversal"))
                
                // Линия с длительностью
                HStack {
                    Rectangle()
                        .fill(Color("GrayUniversal"))
                        .frame(height: 1)
                    
                    Text(trip.duration)
                        .font(.system(size: 12))
                        .foregroundColor(Color("BlackUniversal"))
                        .padding(.horizontal, 8)
                    
                    Rectangle()
                        .fill(Color("GrayUniversal"))
                        .frame(height: 1)
                }
                
                // Время прибытия
                Text(trip.arrivalTime)
                    .font(.system(size: 17, weight: .medium))
                    .foregroundColor(Color("BlackUniversal"))
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
        }
        .background(Color("LightGray"))
        .cornerRadius(24)
        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
}

#Preview {
    CarrierCardView(trip: TripInfo(
        carrier: CarrierInfo(
            title: "РЖД",
            logo: nil,
            code: 1
        ),
        departureTime: "22:30",
        arrivalTime: "08:15",
        duration: "20 ч",
        date: "14 января",
        hasTransfers: true,
        transferInfo: "С пересадкой в Костроме",
        sortDate: Date()
    ))
    .padding()
    .background(Color("White"))
}
