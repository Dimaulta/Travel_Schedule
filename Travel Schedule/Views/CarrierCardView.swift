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
        VStack(spacing: 0) {
            HStack(alignment: .top) {
                // Информация о перевозчике
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 8) {
                        // Логотип перевозчика
                        if let logo = trip.carrier.logo, let url = URL(string: logo) {
                            AsyncImage(url: url) { image in
                                image.resizable().scaledToFit()
                            } placeholder: {
                                RoundedRectangle(cornerRadius: 4).fill(Color("GrayUniversal"))
                            }
                            .frame(width: 38, height: 38)
                            .clipShape(RoundedRectangle(cornerRadius: 4))
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
            .padding(.horizontal, 16)
            .padding(.top, 16)
            
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
                        .foregroundColor(Color("GrayUniversal"))
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
            .padding(.horizontal, 16)
            .padding(.bottom, 16)
        }
        .background(Color("LightGray"))
        .frame(height: 104)
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
        transferInfo: "С пересадкой в Костроме"
    ))
    .padding()
    .background(Color("White"))
}
